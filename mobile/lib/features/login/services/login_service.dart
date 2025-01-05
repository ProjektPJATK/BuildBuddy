import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_response.dart';


class LoginService {
  Future<LoginResponse> login(String email, String password) async {
  final url = AppConfig.getLoginEndpoint();
    print('Sending POST request to $url with email: $email');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final token = json.decode(response.body)['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userToken', token);
        final data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        throw Exception('Failed to log in: ${response.body}');
      }
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    }
  }
}
