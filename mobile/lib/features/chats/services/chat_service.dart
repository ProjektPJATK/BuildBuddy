import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  Future<List<String>> fetchTeammates(int teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Brak tokena uwierzytelniającego.');
    }

    // Generowanie dynamicznego endpointu
    final url = AppConfig.getTeammatesEndpoint(teamId);
    print('Requesting Teammates URL: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<String>((item) => item['name'] as String).toList();
    } else {
      throw Exception('Failed to fetch teammates: ${response.statusCode}');
    }
  }
}
