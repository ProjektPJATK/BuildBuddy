import 'package:mobile/features/chats/models/mesage_model.dart';

import '../models/chat_model.dart';


class ChatService {
  // Mockowe dane czatów
  static Future<List<ChatModel>> fetchChats() async {
    await Future.delayed(const Duration(seconds: 1)); // Symulacja opóźnienia
    return [
      ChatModel(
        id: '1',
        name: 'Marta Nowak',
        lastMessage: 'Cześć, jak idą prace?',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatModel(
        id: '2',
        name: 'Jan Kowalski',
        lastMessage: 'Możemy spotkać się o 15:00?',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  // Mockowe dane wiadomości dla danego czatu
  static Future<List<MessageModel>> fetchMessages(String chatId) async {
    await Future.delayed(const Duration(seconds: 1)); // Symulacja opóźnienia
    return [
      MessageModel(
        id: '1',
        chatId: chatId,
        sender: 'Marta Nowak',
        content: 'Cześć! Jak idą prace?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      MessageModel(
        id: '2',
        chatId: chatId,
        sender: 'Ty',
        content: 'Dobrze, postępy są spore.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }
}
