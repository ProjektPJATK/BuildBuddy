import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import '../models/chat_message_model.dart';

class ChatHubService {
  late HubConnection _hubConnection;
  bool _connected = false;

  Function(List<ChatMessage>)? onHistoryReceived;
  Function(ChatMessage)? onMessageReceived;

  Future<void> connect({required String baseUrl, required int conversationId}) async {
    if (_connected) {
      print("[ChatHubService] Already connected -> skipping");
      return;
    }

    final hubUrl = '$baseUrl/Chat?conversationId=$conversationId';
    print("[ChatHubService] connect -> hubUrl=$hubUrl");

    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl, options: HttpConnectionOptions())
        .build();

    // Poprawiony handler onclose
    _hubConnection.onclose(({Exception? error}) {
      _connected = false;
      print("[ChatHubService] Connection closed -> error: ${error?.toString()}");
    });

    _hubConnection.on("ReceiveMessage", (params) {
      print("[ChatHubService] on(ReceiveMessage) -> params=$params");
      if (params != null && params.length >= 3) {
        final message = ChatMessage(
          senderId: params[0] as int,
          text: params[1] as String,
          timestamp: DateTime.parse(params[2].toString()),
          conversationId: conversationId,
        );
        onMessageReceived?.call(message);
      }
    });

    _hubConnection.on("ReceiveHistory", (params) {
      print("[ChatHubService] on(ReceiveHistory) -> params=$params");
      if (params != null && params.isNotEmpty) {
        final List<dynamic> rawMessages = params[0] as List<dynamic>;
        final history = rawMessages.map((e) {
          return ChatMessage(
            senderId: e['senderId'] as int,
            text: e['text'] as String,
            timestamp: DateTime.parse(e['dateTimeDate']),
            conversationId: conversationId,
          );
        }).toList();
        onHistoryReceived?.call(history);
      }
    });

    try {
      await _hubConnection.start();
      _connected = true;
      print("[ChatHubService] connect -> connected successfully!");
    } catch (e) {
      print("[ChatHubService] connect -> Failed to connect: $e");
      _connected = false;
      rethrow;
    }
  }

  Future<List<ChatMessage>> fetchHistory(int conversationId) async {
    print("[ChatHubService] fetchHistory -> conversationId=$conversationId");

    Completer<List<ChatMessage>> completer = Completer();

    _hubConnection.off("ReceiveHistory");
    _hubConnection.on("ReceiveHistory", (params) {
      print("[ChatHubService] on(ReceiveHistory) -> params=$params");

      if (params != null && params.isNotEmpty) {
        final List<dynamic> rawMessages = params[0] as List<dynamic>;
        final messages = rawMessages.map((e) {
          return ChatMessage(
            senderId: e['senderId'] as int,
            text: e['text'] as String,
            timestamp: DateTime.parse(e['dateTimeDate']),
            conversationId: conversationId,
          );
        }).toList();
        completer.complete(messages);
      } else {
        completer.completeError("Empty history received");
      }
    });

    await _hubConnection.invoke("FetchHistory", args: [conversationId]);
    return completer.future;
  }

  Future<void> sendMessage(int senderId, int conversationId, String text) async {
    print("[ChatHubService] sendMessage -> text=$text, senderId=$senderId, convId=$conversationId");
    if (_hubConnection.state != HubConnectionState.Connected) {
      print("[ChatHubService] sendMessage -> Hub not connected!");
      return;
    }

    await _hubConnection.invoke("SendMessage", args: [senderId, conversationId, text]);
    print("[ChatHubService] sendMessage -> invoked SendMessage");
  }

  Future<void> dispose() async {
    if (_connected) {
      _hubConnection.off("ReceiveMessage");
      _hubConnection.off("ReceiveHistory");
      await _hubConnection.stop();
      _connected = false;
      print("[ChatHubService] dispose -> connection closed");
    }
  }
}
