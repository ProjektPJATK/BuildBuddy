import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String _baseUrl = "http://10.0.2.2:5007/api";

  static Future<Map<String, dynamic>> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final url = '$_baseUrl/User/$userId';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
