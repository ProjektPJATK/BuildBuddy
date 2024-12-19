import '../models/chat_message_model.dart';

abstract class ChatEvent {}

class ConnectChatEvent extends ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String text;
  SendMessageEvent(this.text);
}

class ReceiveMessageEvent extends ChatEvent {
  final ChatMessage message;
  ReceiveMessageEvent({required this.message});
}