import 'package:mobile/features/profile/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:http_parser/http_parser.dart';


class UserService {
  // Fetch user profile from API
  

  Future<void> editUserProfile(User updatedProfile) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');

  if (userId == null) {
    throw Exception('User ID not found in preferences');
  }

  final url = AppConfig.patchUserEndpoint(userId);
  print('Updating profile at: $url');

  // Create JSON Patch document
  final patchDoc = [
    {"op": "replace", "path": "/name", "value": updatedProfile.name},
    {"op": "replace", "path": "/surname", "value": updatedProfile.surname},
    {"op": "replace", "path": "/mail", "value": updatedProfile.email},
    {"op": "replace", "path": "/telephoneNr", "value": updatedProfile.telephoneNr},
    {"op": "replace", "path": "/preferredLanguage", "value": updatedProfile.preferredLanguage},
  ];

  final response = await http.patch(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json-patch+json',
      'accept': 'application/json',
    },
    body: jsonEncode(patchDoc),
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 204 || response.statusCode == 200) {
    print('Profile updated successfully!');
  } else {
    throw Exception('Failed to update profile: ${response.body}');
  }
}


  // Upload user image
Future<void> uploadUserImage(int userId, File image) async {
  final url = AppConfig.uploadUserImageEndpoint(userId);
  print('Uploading image to: $url');

  try {
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',  // Ensure this matches the backend's expected field name
        image.path,
        contentType: MediaType('image', 'jpeg'),  // Adjust format (png, webp, etc.)
      ),
    );

    request.headers.addAll({
      'accept': '*/*',
      'Content-Type': 'multipart/form-data',
    });

    var response = await request.send();
    final responseString = await response.stream.bytesToString();

    print('Upload response status: ${response.statusCode}');
    print('Upload response body: $responseString');

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Image uploaded successfully!');
    } else {
      throw Exception('Failed to upload image: $responseString');
    }
  } catch (e) {
    print('Error during image upload: $e');
    throw Exception('Error uploading image.');
  }
}


  // Cache user profile locally
  Future<void> cacheUserProfile(User profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(profile.toJson());
    print('Caching Profile: $jsonData');
    await prefs.setString('cachedProfile', jsonData);
  }

  // Logout user and clear cache
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('User logged out and preferences cleared.');
  }

  // Retrieve cached user profile
  Future<User?> getCachedUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedProfile = prefs.getString('cachedProfile');

    if (cachedProfile != null) {
      final user = User.fromJson(jsonDecode(cachedProfile));

      // Fetch latest user image from the API
      user.userImageUrl = await getUserImage(user.id);

      return user;
    }
    return null;
  }
  Future<User> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('User ID not found in preferences');
    }

    final url = AppConfig.getProfileEndpoint(userId);
    print('Fetching profile from: $url');

    final response = await http.get(Uri.parse(url), headers: {
      'accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final user = User.fromJson(jsonDecode(response.body));
      return user;
    } else {
      throw Exception('Failed to fetch profile.');
    }
  }

  Future<String> getUserImage(int userId) async {
    final url = AppConfig.getUserImageEndpoint(userId);
    print('Fetching user image from: $url');

    final response = await http.get(Uri.parse(url), headers: {
      'accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final List<dynamic> images = jsonDecode(response.body);
      return images.isNotEmpty ? images[0] : '';
    } else {
      throw Exception('Failed to fetch user image.');
    }
  }
}
