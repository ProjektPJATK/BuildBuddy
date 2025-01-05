import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterService {
  static const String backendIP = "10.0.2.2";
  static const String backendPort = "5007";

  static Future<bool> registerUser({
    required String name,
    required String surname,
    required String email,
    required String telephoneNr,
    required String password,
  }) async {
    const url = "http://$backendIP:$backendPort/api/User/register";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode({
          "id": 0,
          "name": name,
          "surname": surname,
          "mail": email,
          "telephoneNr": telephoneNr,
          "password": password,
          "userImageUrl": "string",
          "teamId": 0,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }
}
