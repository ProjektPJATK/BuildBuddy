import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamService {
  // Wspólna funkcja do wykonywania żądań HTTP
  Future<http.Response> _makeRequest(String url, String method,
      {String? token, String? body}) async {
    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (body != null) 'Content-Type': 'application/json',
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(Uri.parse(url), headers: headers);
      case 'POST':
        return await http.post(Uri.parse(url), headers: headers, body: body);
      default:
        throw Exception('[TeamService] Unsupported HTTP method: $method');
    }
  }

  // Pobierz nazwę roli na podstawie ID
  Future<String> getRoleName(int roleId) async {
    print("[TeamService] Fetching role name for roleId: $roleId");
    final url = AppConfig.getRoleInfoEndpoint(roleId);

    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("[TeamService] Role fetched: $data");
        return data['name'];
      } else {
        throw Exception(
            '[TeamService] Failed to fetch role. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("[TeamService] Error fetching role: $e");
      throw Exception('[TeamService] Error fetching role. Error: $e');
    }
  }

  // Pobierz obraz użytkownika na podstawie ID
  Future<String> fetchUserImage(int userId) async {
    print("[TeamService] Fetching image for userId: $userId");
    final url = AppConfig.getUserImageEndpoint(userId);

    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty && data[0] is String) {
          final imageUrl = data[0];
          print("[TeamService] Image URL fetched: $imageUrl");
          return imageUrl;
        } else {
          throw Exception(
              '[TeamService] Invalid JSON structure: Expected a non-empty list of strings.');
        }
      } else {
        throw Exception(
            '[TeamService] Failed to fetch image. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("[TeamService] Error fetching user image: $e");
      return ''; // Zwracamy pusty string w razie błędu
    }
  }

  // Pobierz listę członków zespołu na podstawie adresu
  Future<List<Map<String, dynamic>>> getTeamMembers() async {
    print("[TeamService] Fetching team members...");
    final prefs = await SharedPreferences.getInstance();
    final teamId = prefs.getInt('placeId') ?? 0;

    final url = AppConfig.getTeammByAddressIdEndpoint(teamId);
    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("[TeamService] Data fetched from API: $data");

        return data.map<Map<String, dynamic>>((member) {
          return {
            'id': member['id'],
            'name': '${member['name']} ${member['surname']}',
            'phone': member['telephoneNr'],
            'email': member['mail'],
            'roles': member['rolesInTeams'],
          };
        }).toList();
      } else {
        throw Exception(
            '[TeamService] Failed to load team members. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("[TeamService] Error fetching team members: $e");
      throw Exception('[TeamService] Error fetching team members. Error: $e');
    }
  }
}
