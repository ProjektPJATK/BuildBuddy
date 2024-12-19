import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';

class ChatService {
  late HubConnection _connection;

  // Inicjalizacja połączenia
  Future<void> initializeConnection() async {
    _connection = HubConnectionBuilder()
        .withUrl('http://http://localhost:5007/chatHub')  // Podaj właściwy URL do swojego Huba
        .build();

    _connection.onclose((error) {
      print("Połączenie zamknięte: $error");
    });

    await _connection.start();
    print("Połączono z SignalR");
  }

  // Funkcja wysyłania wiadomości
  Future<void> sendMessage(int senderId, int conversationId, String text) async {
    await _connection.invoke('SendMessage', args: [senderId, conversationId, text]);
  }

  // Funkcja odbioru wiadomości
  void onReceiveMessage(Function(String, int) handleMessage) {
    _connection.on('ReceiveMessage', (arguments) {
      final senderId = arguments![0] as int;
      final text = arguments[1] as String;
      handleMessage(text, senderId);
    });
  }

  // Zamykanie połączenia
  Future<void> closeConnection() async {
    await _connection.stop();
  }
}
