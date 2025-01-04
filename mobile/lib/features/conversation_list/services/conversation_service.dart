import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationService {
  ConversationService();

  /// Pobiera surowe dane z endpointu, dodaje klucz 'usersName' i zwraca listę konwersacji.
 Future<List<Map<String, dynamic>>> fetchConversations() async {
  final prefs = await SharedPreferences.getInstance();
  final currentUserId = prefs.getInt('userId') ?? 0;

  final endpoint = AppConfig.getChatListEndpoint(currentUserId);
  print("[conversation_service] fetchConversations -> userId=$currentUserId, endpoint=$endpoint");

  try {
    final response = await http.get(Uri.parse(endpoint));
    print("[conversation_service] fetchConversations -> response.statusCode=${response.statusCode}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print("[conversation_service] fetchConversations -> raw API data: $data");

      final conversations = data.map((c) => c as Map<String, dynamic>).toList();

      for (var conv in conversations) {
        final List<dynamic> users = conv['users'] ?? [];
        print("[conversation_service] fetchConversations -> users: $users");

        final participants = users.where((u) => u['id'] != currentUserId).toList();
        print("[conversation_service] fetchConversations -> participants: $participants");

        final String joinedNames = participants.map((u) {
          final String name = u['name'] ?? 'Nieznany';
          final String surname = u['surname'] ?? '';
          print("[conversation_service] fetchConversations -> name: $name, surname: $surname");
          return '$name $surname'.trim();
        }).join(', ');

        conv['usersName'] = joinedNames.isNotEmpty ? joinedNames : 'Brak uczestników';
        print("[conversation_service] fetchConversations -> usersName: ${conv['usersName']}");
      }

      print("[conversation_service] fetchConversations -> finalConversations=$conversations");
      return conversations;
    } else {
      print("[conversation_service] fetchConversations -> statusCode=${response.statusCode}, body=${response.body}");
      throw Exception('Failed to load conversations');
    }
  } catch (e) {
    print("[conversation_service] fetchConversations -> error=$e");
    throw Exception('Error fetching conversations: $e');
  }
}

  /// Zapisuje surowe konwersacje do cache
  Future<void> saveConversationsToCache(List<Map<String, dynamic>> conversations) async {
    print("[conversation_service] saveConversationsToCache -> saving ${conversations.length} items to cache");
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(conversations);
    await prefs.setString('conversations_cache', jsonData);
    print("[conversation_service] saveConversationsToCache -> cache updated");
  }

  /// Odczytuje surowe konwersacje z cache
  Future<List<Map<String, dynamic>>> loadConversationsFromCache() async {
    print("[conversation_service] loadConversationsFromCache -> loading...");
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('conversations_cache');
    if (cachedData != null) {
      final List<dynamic> decoded = jsonDecode(cachedData);
      final List<Map<String, dynamic>> result =
          decoded.map((item) => item as Map<String, dynamic>).toList();
      print("[conversation_service] loadConversationsFromCache -> loaded ${result.length} items from cache");
      return result;
    }
    print("[conversation_service] loadConversationsFromCache -> cache is empty");
    return [];
  }
}
