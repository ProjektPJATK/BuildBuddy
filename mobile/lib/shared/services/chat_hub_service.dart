import 'package:http/http.dart' as http;
import 'package:mobile/features/chat/bloc/chat_event.dart';
import 'package:mobile/shared/config/config.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../features/chat/models/chat_message_model.dart';
import '../../features/chat/bloc/chat_bloc.dart';

class ChatHubService {
  late HubConnection _hubConnection;
  bool _connected = false;
  bool get isConnected => _connected;
  Future<void> connect({
  required String baseUrl,
  required int conversationId,
  required int userId,
  required ChatBloc chatBloc,
}) async {
  if (_connected) return;

  final hubUrl = '$baseUrl/Chat?conversationId=$conversationId&userId=$userId';
  _hubConnection = HubConnectionBuilder()
    .withUrl(hubUrl, options: HttpConnectionOptions())
    .build();

  _registerSignalRListeners(chatBloc, conversationId);

  _hubConnection.onclose(({Exception? error}) async {
    _connected = false;
    print("[ChatHubService] Connection closed: $error");
    await _retryConnection(baseUrl, conversationId, userId, chatBloc);
  });

  try {
    await _hubConnection.start();
    _connected = true;
    print("[ChatHubService] Connected to SignalR Hub");

    // Pobranie historii po połączeniu
    await fetchHistory(conversationId, userId);
  } catch (e) {
    print("[ChatHubService] Error connecting: $e");
    rethrow;
  }
}

void _registerSignalRListeners(ChatBloc chatBloc, int conversationId) {
  // Najpierw usuń istniejące nasłuchiwacze, jeśli istnieją
  _hubConnection.off("ReceiveMessage");
  _hubConnection.off("ReceiveHistory");

  print("[ChatHubService] Registering SignalR listeners...");

  _hubConnection.on("ReceiveMessage", (params) {
    print("[ChatHubService] ReceiveMessage triggered with params: $params");
    if (params != null && params.length >= 3) {
      final message = ChatMessage(
        senderId: params[0] as int,
        text: params[1] as String,
        timestamp: DateTime.parse(params[2] as String),
        conversationId: conversationId,
      );
      print("[ChatHubService] Received message: ${message.text}");
      chatBloc.add(ReceiveMessageEvent(message: message));
    } else {
      print("[ChatHubService] Invalid ReceiveMessage params: $params");
    }

    final hubUrl = '$baseUrl/Chat?conversationId=$conversationId';
    print("[ChatHubService] Attempting to connect to: $hubUrl");
    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl, options: HttpConnectionOptions())
        .build();

    _hubConnection.onclose(({Exception? error}) async {
      _connected = false;
      print("[ChatHubService] Connection closed: $error");
    });

    try {
      print("[ChatHubService] Starting connection...");
      await _hubConnection.start();
      _connected = true;
      print("[ChatHubService] Connected to SignalR Hub");

      // Register listeners after connection is successful
      _registerSignalRListeners(chatBloc, conversationId);

      // Check if history can be fetched
      await fetchHistory(conversationId, userId);
    } catch (e) {
      print("[ChatHubService] Error connecting: $e");
      rethrow;
    }
  }

  void _registerSignalRListeners(ChatBloc chatBloc, int conversationId) {
    print("[ChatHubService] Checking connection state before registering listeners...");

    if (_hubConnection.state != HubConnectionState.Connected) {
      print("[ChatHubService] Connection is not established. Aborting listener registration.");
      return;
    }

    print("[ChatHubService] Registering SignalR listeners...");

    // Remove any existing listeners to prevent duplicates
    _hubConnection.off("ReceiveMessage");
    _hubConnection.off("ReceiveHistory");

    _hubConnection.on("ReceiveMessage", (params) {
      print("[ChatHubService] ReceiveMessage triggered with params: $params");

      if (params != null && params.length >= 3) {
        final message = ChatMessage(
          senderId: params[0] as int,
          text: params[1] as String,
          timestamp: DateTime.parse(params[2] as String),
          conversationId: conversationId,
        );
        print("[ChatHubService] Received message: ${message.text}");
        chatBloc.add(ReceiveMessageEvent(message: message));
      } else {
        print("[ChatHubService] Invalid ReceiveMessage params: $params");
      }
    });

    _hubConnection.on("ReceiveHistory", (params) {
      print("[ChatHubService] ReceiveHistory triggered with params: $params");

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

        chatBloc.add(ReceiveHistoryEvent(messages: history));
      } else {
        print("[ChatHubService] Empty history received");
      }
    });
  }

  Future<void> fetchHistory(int conversationId, int userId) async {
 if (_connected) {
   try {
     print("[ChatHubService] FetchHistory invoked for conversationId: $conversationId and userId: $userId");
     final response = await _hubConnection.invoke("FetchHistory", args: [conversationId, userId]);
     print("[ChatHubService] History fetched: $response");
   } catch (e) {
     print("[ChatHubService] Error fetching history: $e");
   }
 } else {
   print("[ChatHubService] Connection is not active.");
 }

  }
  Future<void> sendMessage(int senderId, int conversationId, String text) async {
    if (_connected) {
      print("[ChatHubService] Sending message to conversationId: $conversationId from senderId: $senderId");
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

  Future<void> exitChat(int conversationId, int userId) async {
    final exitUrl = AppConfig.exitChatEndpoint(conversationId, userId);
    final response = await http.post(Uri.parse(exitUrl));

    if (response.statusCode == 200) {
      print("User exited chat: $conversationId");
      await _hubConnection.stop();
      _connected = false;  // Mark the connection as stopped after exiting
    } else {
      print("Error exiting chat: ${response.statusCode}");
    }
  }
}
