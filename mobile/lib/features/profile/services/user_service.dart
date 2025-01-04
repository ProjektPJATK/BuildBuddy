import 'package:mobile/features/profile/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';

class UserService {
  // Pobieranie profilu użytkownika z API
  Future<User> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('User ID not found in preferences');
    }

    final url = AppConfig.getProfileEndpoint(userId);
    print('Generated URL: $url');
    final response = await http.get(Uri.parse(url), headers: {
      'accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  // Edycja profilu użytkownika
  Future<void> editUserProfile(User updatedProfile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('User ID not found in preferences');
    }

    final url = AppConfig.getProfileEndpoint(userId);
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode(updatedProfile.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  // Cache'owanie profilu użytkownika
  Future<void> cacheUserProfile(User profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(profile.toJson());
    print('Caching Profile: $jsonData');
    await prefs.setString('cachedProfile', jsonData);
  }

  // Pobieranie profilu z pamięci cache
  Future<User?> getCachedUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedProfile = prefs.getString('cachedProfile');
    if (cachedProfile != null) {
      return User.fromJson(jsonDecode(cachedProfile));
    }
    return null;
  }

  // Wylogowanie użytkownika (czyści dane użytkownika)
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
