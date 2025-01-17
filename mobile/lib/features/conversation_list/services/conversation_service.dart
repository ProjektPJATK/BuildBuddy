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

  try {
    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((c) => c as Map<String, dynamic>).toList();
    } else if (response.statusCode == 404) {
      // Return an empty list for 404 responses
      return [];
    } else {
      throw Exception('Failed to load conversations');
    }
  } catch (e) {
    throw Exception('Error fetching conversations: $e');
  }
}


  /// Zapisuje surowe konwersacje do cache
  Future<void> saveConversationsToCache(List<Map<String, dynamic>> conversations) async {
  //  print("[conversation_service] saveConversationsToCache -> saving ${conversations.length} items to cache");
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(conversations);
    await prefs.setString('conversations_cache', jsonData);
   // print("[conversation_service] saveConversationsToCache -> cache updated");
  }

  /// Odczytuje surowe konwersacje z cache
  Future<List<Map<String, dynamic>>> loadConversationsFromCache() async {
    //print("[conversation_service] loadConversationsFromCache -> loading...");
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('conversations_cache');
    if (cachedData != null) {
      final List<dynamic> decoded = jsonDecode(cachedData);
      final List<Map<String, dynamic>> result =
          decoded.map((item) => item as Map<String, dynamic>).toList();
      //print("[conversation_service] loadConversationsFromCache -> loaded ${result.length} items from cache");
      return result;
    }
   // print("[conversation_service] loadConversationsFromCache -> cache is empty");
    return [];
  }

}
