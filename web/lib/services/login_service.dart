import 'dart:convert';
import 'dart:html'; // Używamy do localStorage
import 'package:http/http.dart' as http;
import 'package:web/config/config.dart';
import 'package:web/models/login_response.dart';

class LoginService {
  Future<LoginResponse> login(String email, String password) async {
    final loginUrl = AppConfig.getLoginEndpoint();
    print('Sending POST request to $loginUrl with email: $email');

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userId = data['userId'];
        final roleId = data['roleId'];

        // Fetch role details
        final powerLevel = await _fetchPowerLevel(roleId);

        if (powerLevel == 2 || powerLevel == 3) {
          // Save to localStorage
          window.localStorage['userToken'] = token;
          window.localStorage['userId'] = userId.toString();
          window.localStorage['powerLevel'] = powerLevel.toString();

          return LoginResponse.fromJson(data);
        } else {
          throw Exception('Access denied: insufficient power level.');
        }
      } else {
        throw Exception('Failed to log in: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<int> _fetchPowerLevel(int roleId) async {
    final roleUrl = AppConfig.getRoleEndpoint(roleId);
    final response = await http.get(Uri.parse(roleUrl), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['powerLevel'];
    } else {
      throw Exception('Failed to fetch role details: ${response.body}');
    }
  }

  void logout() {
    window.localStorage.remove('userToken');
    window.localStorage.remove('userId');
    window.localStorage.remove('powerLevel');
  }

  String? getToken() => window.localStorage['userToken'];
}
