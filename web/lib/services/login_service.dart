import 'dart:convert';
import 'package:universal_io/io.dart';
import 'package:universal_html/html.dart' as html;
import 'package:web/config/config.dart';
import 'package:web/models/login_response.dart';

class LoginService {
  Future<LoginResponse> login(String email, String password) async {
    final loginUrl = AppConfig.getLoginEndpoint();
    final client = HttpClient();

    try {
      final request = await client.postUrl(Uri.parse(loginUrl));
      request.headers.set('Content-Type', 'application/json');
      request.add(utf8.encode(jsonEncode({'email': email, 'password': password})));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);
        print('Response data: $data');

        final token = data['token'] ?? '';
        final userId = int.tryParse(data['id']?.toString() ?? '0') ?? 0;
        setLoginCookie(token, userId);

        final rolesInTeams = data['rolesInTeams'] as List<dynamic>;
        final List<Map<String, dynamic>> teamsWithPowerLevels = [];

        bool hasValidRole = false;

        for (var roleData in rolesInTeams) {
          final teamId = roleData['teamId'];
          final roleId = roleData['roleId'];
          final powerLevel = await _fetchPowerLevel(roleId);

          if (powerLevel == 2 || powerLevel == 3) {
            hasValidRole = true;
          }

          teamsWithPowerLevels.add({
            'teamId': teamId,
            'powerLevel': powerLevel,
          });
        }
        print(teamsWithPowerLevels);
        if (!hasValidRole) {
          throw Exception('Access denied: No valid powerLevel found.');
        }

        // Zapisanie listy ról w localStorage
        html.window.localStorage['teamsWithPowerLevels'] = jsonEncode(teamsWithPowerLevels);

        return LoginResponse(
          token: token,
          userId: userId,
          rolesInTeams: teamsWithPowerLevels, // Dodajemy listę ról z powerLevel
        );
      } else {
        throw Exception('Failed to log in: ${response.statusCode}');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  void setLoginCookie(String token, int userId) {
    final tokenCookie = 'userToken=$token; path=/; max-age=3600'; // Ważność 1 godzina
    final userIdCookie = 'userId=$userId; path=/; max-age=3600';

    html.document.cookie = tokenCookie;
    html.document.cookie = userIdCookie;

    print('Cookie set: $tokenCookie');
    print('Cookie set: $userIdCookie');
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
