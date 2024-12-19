import 'package:mobile/features/chat/bloc/chat_event.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../models/chat_message_model.dart';
import '../bloc/chat_bloc.dart'; // Importujemy bloc

class ChatHubService {
  late HubConnection _hubConnection;
  bool _connected = false;

  Function(ChatMessage)? onMessageReceived;
  Function(List<ChatMessage>)? onHistoryReceived;

   Future<void> connect({
  required String baseUrl,
  required int conversationId,
  required ChatBloc chatBloc,
}) async {
  if (_connected) return;

  final hubUrl = '$baseUrl/Chat?conversationId=$conversationId';
  _hubConnection = HubConnectionBuilder()
      .withUrl(hubUrl, options: HttpConnectionOptions())
      .build();

  _hubConnection.onclose(({Exception? error}) {
    _connected = false;
    print("[ChatHubService] Connection closed: $error");
  });

  _hubConnection.on("ReceiveMessage", (params) {
    if (params != null && params.length >= 3) {
      final message = ChatMessage(
        senderId: params[0] as int,
        text: params[1] as String,
        timestamp: DateTime.parse(params[2] as String),
        conversationId: conversationId,
      );
      print("[ChatHubService] Received message: ${message.text}");
      chatBloc.add(ReceiveMessageEvent(message: message));
    }
  });

  _hubConnection.on("ReceiveHistory", (params) {
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

      print("[ChatHubService] History parsed: ${history.length} messages");
      chatBloc.add(ReceiveHistoryEvent(messages: history));
    } else {
      print("[ChatHubService] Empty history received");
    }
  });

  try {
    await _hubConnection.start();
    _connected = true;
    print("[ChatHubService] Connected to SignalR Hub");

    // Fetch history
    await fetchHistory(conversationId);
  } catch (e) {
    print("[ChatHubService] Error connecting: $e");
    rethrow;
  }
}

  Future<void> fetchHistory(int conversationId) async {
    if (_connected) {
      try {
        await _hubConnection.invoke("FetchHistory", args: [conversationId]);
        print("[ChatHubService] FetchHistory invoked for conversationId: $conversationId");
      } catch (e) {
        print("[ChatHubService] Error fetching history: $e");
      }
    } else {
      print("[ChatHubService] Connection is not active.");
    }
  }

  Future<void> sendMessage(int senderId, int conversationId, String text) async {
    if (_connected) {
      await _hubConnection.invoke("SendMessage", args: [senderId, conversationId, text]);
      print("[ChatHubService] Message sent: $text");
    } else {
      print("[ChatHubService] Connection is not active.");
    }
  }

  Future<void> dispose() async {
    if (_connected) {
      await _hubConnection.stop();
      _connected = false;
      print("[ChatHubService] Disconnected from SignalR Hub");
    }
  }
}
