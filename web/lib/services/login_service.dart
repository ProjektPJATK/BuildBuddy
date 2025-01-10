import 'dart:convert';

import 'package:web/config/config.dart';

class LoginService {
  final LocalStorage storage = LocalStorage();

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
        await storage.setItem('userToken', token);
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

  Future<void> logout() async {
    print('Logging out user.');
    await storage.deleteItem('userToken');
  }

  Future<String?> getToken() async {
    return await storage.getItem('userToken');
  }
}
