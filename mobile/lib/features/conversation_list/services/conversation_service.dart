import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationService {
  ConversationService();

  /// Zwraca surowe (Map<String, dynamic>) konwersacje z backendu
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    // Załóżmy, że userId pobieramy tutaj z SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    final endpoint = AppConfig.getChatListEndpoint(userId);
    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((c) => c as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load conversations');
      }
    } catch (e) {
      throw Exception('Error fetching conversations: $e');
    }
  }

  /// Zapisuje surowe konwersacje do cache (SharedPreferences).
  Future<void> saveConversationsToCache(List<Map<String, dynamic>> conversations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(conversations);
    await prefs.setString('conversations_cache', jsonData);
  }

  /// Odczytuje surowe konwersacje z cache (SharedPreferences).
  Future<List<Map<String, dynamic>>> loadConversationsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('conversations_cache');
    if (cachedData != null) {
      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  /// Przetwarza dane konwersacji na listę nazw uczestników (bez aktualnego użytkownika).
  Future<List<String>> processConversations(List<Map<String, dynamic>> conversations) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getInt('userId') ?? 0;

    return conversations.map<String>((conversation) {
      final participants = conversation['users']
          .where((user) => user['id'] != currentUserId)
          .map<String>((user) => '${user['name']} ${user['surname']}')
          .join(', ');

      return participants.isNotEmpty ? participants : 'Brak uczestników';
    }).toList();
  }
}
