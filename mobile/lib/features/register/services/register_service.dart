import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterService {
  static const String backendIP = "10.0.2.2"; // Emulator IP
  static const String backendPort = "5159";

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
          "userImageUrl": "placeholder_image_url", // Placeholder for image
          "preferredLanguage": "en", // Placeholder for language
        }),
      );

      // Debugging: Log response details
      print('Request URL: $url');
      print('Request Body: ${jsonEncode({
        "id": 0,
        "name": name,
        "surname": surname,
        "mail": email,
        "telephoneNr": telephoneNr,
        "password": password,
        "userImageUrl": "placeholder_image_url",
        "preferredLanguage": "en",
      })}');
      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Registration failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }
}
