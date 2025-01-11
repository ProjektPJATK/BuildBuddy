import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeService {
  // Fetch teams for a user
  Future<List<dynamic>> fetchTeams(int userId) async {
    print('Fetching teams for userId: $userId');

    // Pobierz token z SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print('[HomeService] Token not found. Resetting user data...');
      // Jeśli nie ma tokena, zresetuj dane użytkownika
      await _resetUserData();
      throw Exception('Brak tokena użytkownika. Użytkownik jest wylogowany.');
    }

    // Dynamiczny URL
    final url = AppConfig.getTeamsEndpoint(userId);
    print('Requesting URL: $url');

    try {
      // Wykonaj żądanie HTTP GET
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Zwróć dane w postaci listy
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to fetch teams: ${response.body}');
      }
    } catch (e) {
      print('Error during fetchTeams: $e');
      throw Exception('Błąd podczas pobierania zespołów: $e');
    }
  }

  // Funkcja resetująca dane użytkownika w SharedPreferences
  Future<void> _resetUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('token'); // Usuwamy token użytkownika
    print('[HomeService] User data reset.');
  }
}
