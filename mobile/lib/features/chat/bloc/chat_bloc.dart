import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/chat_hub_service.dart';
import '../models/chat_message_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatHubService chatHubService;
  final List<ChatMessage> _messages = [];

  ChatBloc({required this.chatHubService}) : super(ChatInitial()) {
    on<ConnectChatEvent>(_onConnectChat);
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveMessageEvent>(_onReceiveMessage);
    on<ReceiveHistoryEvent>(_onReceiveHistory);
  }

Future<void> _onConnectChat(ConnectChatEvent event, Emitter<ChatState> emit) async {
  emit(ChatConnecting());
  print("[ChatBloc] Emitting ChatConnecting");

  try {
    await chatHubService.connect(
      baseUrl: event.baseUrl,
      conversationId: event.conversationId,
      chatBloc: this,
    );
      
      chatHubService.onMessageReceived = (message) {
      print("[ChatBloc] New message received: ${message.text}");
      add(ReceiveMessageEvent(message: message));
    };
    
    chatHubService.onHistoryReceived = (history) {
  print("[ChatBloc] History received with ${history.length} messages");
  add(ReceiveHistoryEvent(messages: history));
    };

    print("[ChatBloc] Connection successful, waiting for history...");
  } catch (e) {
    emit(ChatError('Error connecting: $e'));
    print("[ChatBloc] Emitting ChatError");
  }
}


 Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
  try {
    await chatHubService.sendMessage(event.senderId, event.conversationId, event.text);
  } catch (e) {
    emit(ChatError('Error sending message: $e'));
  }
}


void _onReceiveMessage(ReceiveMessageEvent event, Emitter<ChatState> emit) {
  print("[ChatBloc] New message received: ${event.message.text}");
  _messages.add(event.message);
  emit(ChatLoaded(List.from(_messages)));
}


void _onReceiveHistory(ReceiveHistoryEvent event, Emitter<ChatState> emit) {
  _messages.clear();
  _messages.addAll(event.messages);
  print("[ChatBloc] History received with ${event.messages.length} messages: ${event.messages.map((m) => m.text).join(", ")}");
  print("[ChatBloc] Emitting ChatLoaded with ${_messages.length} messages");
  print("[ChatBloc] State is changing to ChatLoaded with ${_messages.length} messages");

emit(ChatLoaded(List.from(_messages)));
  print("[ChatBloc] ChatLoaded emitted with ${_messages.length} messages");

}

}
