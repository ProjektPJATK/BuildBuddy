import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../services/chat_hub_service.dart';
import '../models/chat_message_model.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatHubService chatHubService;
  final List<ChatMessage> _messages = [];

  bool _connected = false;

  ChatBloc({required this.chatHubService}) : super(ChatInitial()) {
    on<ConnectChatEvent>(_onConnectChat);
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveMessageEvent>(_onReceiveMessage);
  }

  Future<void> _onConnectChat(ConnectChatEvent event, Emitter<ChatState> emit) async {
    emit(ChatConnecting());
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;
      final conversationId = prefs.getInt('conversationId') ?? 0;
      final baseUrl = AppConfig.getChatUrl();

      await chatHubService.connect(baseUrl: baseUrl, conversationId: conversationId);

      chatHubService.onMessageReceived = (message) {
        add(ReceiveMessageEvent(message: message));
      };

      final history = await chatHubService.fetchHistory(conversationId);
      _messages
        ..clear()
        ..addAll(history);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      _connected = true;
      emit(ChatLoaded(List.from(_messages)));
    } catch (e) {
      emit(ChatError('Failed to connect and load chat history: $e'));
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    final conversationId = prefs.getInt('conversationId') ?? 0;

    try {
      await chatHubService.sendMessage(userId, conversationId, event.text);
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }

  void _onReceiveMessage(ReceiveMessageEvent event, Emitter<ChatState> emit) {
    _messages.add(event.message);
    emit(ChatLoaded(List.from(_messages)));
  }
}
