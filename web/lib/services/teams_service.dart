import 'package:universal_io/io.dart';
import 'dart:convert';
import 'package:web/config/config.dart';

class TeamsService {

Future<List<Map<String, dynamic>>> fetchTeamsWithMembers(int userId, int loggedInUserId) async {
  final client = HttpClient();
  try {
    final teamsUrl = AppConfig.getTeamsEndpoint(userId);
    final request = await client.getUrl(Uri.parse(teamsUrl));
    request.headers.set('Accept', 'application/json');

    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final List<dynamic> data = jsonDecode(responseBody);

      final List<Map<String, dynamic>> teams = [];

      for (var team in data) {
        final addressId = team['addressId'];
        final address = await fetchAddress(addressId);

        final members = await fetchTeamMembers(team['id'], loggedInUserId);

        teams.add({
          'id': team['id'],
          'name': team['name'],
          'address': address,
          'members': members, // Dodajemy członków zespołu
        });
      }

      return teams;
    } else {
      throw Exception('Failed to fetch teams: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching teams: $e');
    rethrow;
  } finally {
    client.close();
  }
}


Future<Map<String, String>> fetchAddress(int addressId) async {
  final client = HttpClient();
  try {
    final addressUrl = AppConfig.getAddressEndpoint(addressId);
    final request = await client.getUrl(Uri.parse(addressUrl));
    request.headers.set('Accept', 'application/json');

    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> data = jsonDecode(responseBody);

      return {
        'city': data['city'],
        'country': data['country'],
        'street': data['street'],
        'houseNumber': data['houseNumber'],
        'localNumber': data['localNumber'],
        'postalCode': data['postalCode'],
      };
    } else {
      throw Exception('Failed to fetch address: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching address with addressId $addressId: $e');
    return {
      'city': 'Unknown',
      'country': 'Unknown',
      'street': '',
      'houseNumber': '',
      'localNumber': '',
      'postalCode': '',
    };
  } finally {
    client.close();
  }
}


  Future<List<Map<String, String>>> fetchTeamMembers(int teamId, int loggedInUserId) async {
  final client = HttpClient();
  try {
    final membersUrl = AppConfig.getTeammatesEndpoint(teamId);
    final request = await client.getUrl(Uri.parse(membersUrl));
    request.headers.set('Accept', 'application/json');

    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final List<dynamic> data = jsonDecode(responseBody);

      final futures = data
          .where((member) => member['id'] != loggedInUserId)
          .map<Future<Map<String, String>>>((member) async {
        final roleName = await fetchRoleName(member['roleId']);
        return {
          'name': '${member['name']} ${member['surname']}',
          'role': roleName,
        };
      }).toList();

      return await Future.wait(futures);
    } else {
      throw Exception('Failed to fetch team members: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching team members for team $teamId: $e');
    return [];
  } finally {
    client.close();
  }
}

  Future<String> fetchRoleName(int roleId) async {
    final client = HttpClient();
    try {
      final roleUrl = AppConfig.getRoleEndpoint(roleId);
      final request = await client.getUrl(Uri.parse(roleUrl));
      request.headers.set('Accept', 'application/json');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(responseBody);

        return data['name'] ?? 'Unknown Role';
      } else {
        throw Exception('Failed to fetch role name: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching role name for roleId $roleId: $e');
      return 'Unknown Role';
    } finally {
      client.close();
    }
  }
}
