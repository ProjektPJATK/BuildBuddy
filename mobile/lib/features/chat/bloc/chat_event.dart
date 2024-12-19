import 'package:mobile/features/chat/models/chat_message_model.dart';

abstract class ChatEvent {}

class ConnectChatEvent extends ChatEvent {
  final String baseUrl;
  final int conversationId;

  ConnectChatEvent({required this.baseUrl, required this.conversationId});
}

class SendMessageEvent extends ChatEvent {
  final int senderId;
  final int conversationId;
  final String text;

  SendMessageEvent({
    required this.senderId,
    required this.conversationId,
    required this.text,
  });
}

class ReceiveMessageEvent extends ChatEvent {
  final ChatMessage message;

  ReceiveMessageEvent({required this.message});
}

class ReceiveHistoryEvent extends ChatEvent {
  final List<ChatMessage> messages;

  ReceiveHistoryEvent({required this.messages});
}
