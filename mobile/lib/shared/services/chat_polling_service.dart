import 'dart:async';
import 'package:mobile/features/conversation_list/services/conversation_service.dart';
import 'package:mobile/shared/services/chat_hub_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPollingService {
  Timer? _timer;

  // Metoda do uruchamiania timer'a do sprawdzania nowych wiadomości co 30 sekund
  void startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      await backgroundFetchTask();  // Wywołanie funkcji pollingowej
    });
  }

  // Metoda do zatrzymywania timer'a
  void stopPolling() {
    _timer?.cancel();
  }

  // Funkcja pollingowa
  Future<void> backgroundFetchTask() async {
    print("Polling for new messages...");

    final conversationService = ConversationService();
    final conversations = await conversationService.fetchConversations();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    if (conversations.isNotEmpty) {
      final chatHubService = ChatHubService();

      // Dla każdej konwersacji, pobieramy historię
      for (var conversation in conversations) {
        final conversationId = conversation['id']; // Pobieramy ID konwersacji
        print("Fetching history for conversationId: $conversationId");
        await chatHubService.fetchHistory(conversationId, userId); // Fetch history
      }
    } else {
      print("No conversations found.");
    }
  }
}