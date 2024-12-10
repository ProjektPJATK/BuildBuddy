import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team_member_model.dart';

class TeamService {
  static const String _baseUrl = "http://your-api-url.com/api"; // Podmień na URL swojego backendu

  static Future<List<TeamMemberModel>> fetchTeamMembers(String constructionId) async {
    final response = await http.get(Uri.parse('$_baseUrl/constructions/$constructionId/team'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => TeamMemberModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load team members');
    }
  }
}
