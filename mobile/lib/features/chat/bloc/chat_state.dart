import '../models/chat_message_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatConnecting extends ChatState {}

class ChatConnected extends ChatState {}

class ChatHistoryLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  ChatLoaded(this.messages) {
    print("[ChatState] ChatLoaded with ${messages.length} messages");
  }
}

class ChatError extends ChatState {
  final String errorMessage;

  ChatError(this.errorMessage);
}

