import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TeamService {

 Future<String> getRoleName(int roleId) async {
     print("[TeamService] feczuje role dla roleId: $roleId"); // Logowanie odpowiedzi
  final url = AppConfig.getRoleInfoEndpoint(roleId);
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print("[TeamService] Role fetched: $data"); // Logowanie odpowiedzi
    return data['name'];
  } else {
    throw Exception('Failed to fetch role');
  }
}

 Future<String> fetchUserImage(int userId) async {
    final url = AppConfig.getUserImageEndpoint(userId);

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List && data.isNotEmpty && data[0] is String) {
          final imageUrl = data[0];
          return imageUrl;
        } else {
          throw Exception('Invalid JSON structure');
        }
      } else {
        throw Exception('Failed to fetch image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      return ''; // Zwraca pusty string w razie błędu
    }
  }


  Future<List<Map<String, dynamic>>> getTeamMembers() async {
  final prefs = await SharedPreferences.getInstance();
  final teamId = prefs.getInt('placeId') ?? 0;

  final url = AppConfig.getTeammByAddressIdEndpoint(teamId);
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print("[TeamService] Data fetched from API: $data"); // Dodajemy logowanie

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
    print("[TeamService] Error fetching team members. Status: ${response.statusCode}");
    throw Exception('Failed to load team members');
  }
}

}
