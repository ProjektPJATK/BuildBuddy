import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart';

class ChatHubService {
  WebSocketChannel? _channel;
  bool _connected = false;

  Future<void> connect({
    required String baseUrl,
    required int conversationId,
    required int userId,
    required void Function(Map<String, dynamic>) onMessageReceived,
    required void Function(List<Map<String, dynamic>>) onHistoryReceived,
  }) async {
    final url = '$baseUrl/Chat?conversationId=$conversationId&userId=$userId';
    print("[ChatHubService] Connecting to $url");

    _channel = HtmlWebSocketChannel.connect(Uri.parse(url));
    _connected = true;

    _channel!.stream.listen((event) {
      print("[ChatHubService] Message from server: $event");
      final Map<String, dynamic> message = jsonDecode(event);
      final method = message['method'];
      final params = message['params'];

      if (method == "ReceiveMessage") {
        onMessageReceived(params);
      } else if (method == "ReceiveHistory") {
        onHistoryReceived(List<Map<String, dynamic>>.from(params));
      }
    }, onError: (error) {
      print("[ChatHubService] WebSocket error: $error");
      _connected = false;
    }, onDone: () {
      print("[ChatHubService] WebSocket connection closed.");
      _connected = false;
    });
  }

  Future<void> sendMessage(int senderId, int conversationId, String text) async {
    if (_connected && _channel != null) {
      try {
        final message = jsonEncode({
          "method": "SendMessage",
          "params": [senderId, conversationId, text]
        });
        _channel!.sink.add(message);
        print("[ChatHubService] Message sent: $text");
      } catch (e) {
        print("[ChatHubService] Error sending message: $e");
      }
    } else {
      print("[ChatHubService] Not connected to WebSocket.");
    }
  }

  void disconnect() {
    if (_connected && _channel != null) {
      _channel!.sink.close();
      _connected = false;
      print("[ChatHubService] Disconnected from WebSocket.");
    }
  }
}
