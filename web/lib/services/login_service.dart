import 'dart:convert';
import 'package:universal_io/io.dart';
import 'package:universal_html/html.dart' as html;
import 'package:web/config/config.dart';
import 'package:web/models/login_response.dart';

class LoginService {

  Future<LoginResponse> login(String email, String password) async {
    final loginUrl = AppConfig.getLoginEndpoint();
   // print('Sending POST request to $loginUrl with email: $email');

    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse(loginUrl));
      request.headers.set('Content-Type', 'application/json');
      request.add(utf8.encode(jsonEncode({'email': email, 'password': password})));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);
        print('Response data: $data'); // Log response data for debugging

        final token = data['token'] ?? '';
        final userId = int.tryParse(data['id']?.toString() ?? '0') ?? 0;
        final roleId = int.tryParse(data['roleId']?.toString() ?? '0') ?? 0;
        print('Setting userId in localStorage: $userId');
        html.window.localStorage['userId'] = userId.toString();
        if (roleId == 0) {
          throw Exception('Invalid roleId returned by the server.');
        }
        final powerLevel = await _fetchPowerLevel(roleId);
        if (powerLevel == 2 || powerLevel == 3) {
          // Ustawienie ciasteczka
          setLoginCookie(token);

          return LoginResponse(
            token: token,
            userId: userId,
            roleId: roleId,
          );
        } else {
          throw Exception('Access denied: insufficient power level.');
        }
      } else {
        throw Exception('Failed to log in: ${response.statusCode}');
      }
    } catch (e) {
      //print('Login error: $e');
      rethrow;
    } finally {
      client.close();
    }
  }


 void setLoginCookie(String token) {
  final cookie = 'userToken=$token; path=/; max-age=3600'; // Ważność 1 godzina
  html.document.cookie = cookie;

  // Debugowanie: wyświetlenie wszystkich ciasteczek
  print('Cookie set: $cookie');
  print('Current cookies: ${html.document.cookie}');
}

 bool isLoggedIn() {
    final cookies = html.document.cookie?.split('; ') ?? [];
    return cookies.any((cookie) => cookie.startsWith('userToken='));
  }

  Future<int> _fetchPowerLevel(int roleId) async {
    final roleUrl = AppConfig.getRoleEndpoint(roleId);
    print('Fetching role details from $roleUrl');

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(roleUrl));
      request.headers.set('Content-Type', 'application/json');
      final response = await request.close();

      print('Response status: ${response.statusCode}'); // Log response status

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);
        return int.tryParse(data['powerLevel']?.toString() ?? '0') ?? 0;
      } else if (response.statusCode == 404) {
        throw Exception('Role not found for roleId: $roleId');
      } else {
        throw Exception('Failed to fetch role details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching role details: $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}
