import 'package:universal_io/io.dart';
import 'dart:convert';
import 'package:web/config/config.dart';

class TeamsService {

Future<void> updateTeam(int teamId, String name, int addressId) async {
  final client = HttpClient();
  try {
    final teamUrl = '${AppConfig.getBaseUrl()}/api/Team/$teamId';
    final request = await client.putUrl(Uri.parse(teamUrl));
    request.headers.set('Content-Type', 'application/json');
    request.add(utf8.encode(jsonEncode({
      'name': name,
      'addressId': addressId,
    })));

    final response = await request.close();

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Sukces
      print('Team updated successfully.');
      return;
    } else {
      throw Exception('Failed to update team: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updating team: $e');
    rethrow;
  } finally {
    client.close();
  }
}


Future<void> updateAddress(int addressId, Map<String, String> addressData) async {
  final client = HttpClient();
  try {
    final addressUrl = '${AppConfig.getBaseUrl()}/api/Address/$addressId';
    final request = await client.putUrl(Uri.parse(addressUrl));
    request.headers.set('Content-Type', 'application/json');
    request.add(utf8.encode(jsonEncode(addressData)));

    final response = await request.close();

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Sukces
      print('Address updated successfully.');
      return;
    } else {
      throw Exception('Failed to update address: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updating address: $e');
    rethrow;
  } finally {
    client.close();
  }
}

  
 Future<int> createAddress(Map<String, String> addressData) async {
    final client = HttpClient();
    try {
      final addressUrl = '${AppConfig.getBaseUrl()}/api/Address';
      final request = await client.postUrl(Uri.parse(addressUrl));
      request.headers.set('Content-Type', 'application/json');
      request.add(utf8.encode(jsonEncode(addressData)));

      final response = await request.close();

      if (response.statusCode == 201) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);
        return data['id'];
      } else {
        throw Exception('Failed to create address: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating address: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<int> createTeam(String teamName, int addressId) async {
    final client = HttpClient();
    try {
      final teamUrl = '${AppConfig.getBaseUrl()}/api/Team';
      final request = await client.postUrl(Uri.parse(teamUrl));
      request.headers.set('Content-Type', 'application/json');
      request.add(utf8.encode(jsonEncode({
        'name': teamName,
        'addressId': addressId,
      })));

      final response = await request.close();

      if (response.statusCode == 201) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);
        return data['id'];
      } else {
        throw Exception('Failed to create team: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating team: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

 Future<void> addUserToTeam(int teamId, int userId) async {
  final client = HttpClient();
  try {
    final addUserUrl = '${AppConfig.getBaseUrl()}/api/Team/$teamId/users/$userId';
    final request = await client.postUrl(Uri.parse(addUserUrl));
    request.headers.set('Content-Type', 'application/json');

    final response = await request.close();

    if (response.statusCode == 204 || response.statusCode == 200 || response.statusCode == 201) {
      print('User $userId successfully added to team $teamId');
      return; // Sukces
    } else {
      throw Exception('Failed to add user to team: ${response.statusCode}');
    }
  } catch (e) {
    print('Error adding user to team: $e');
    rethrow;
  } finally {
    client.close();
  }
}

Future<List<Map<String, dynamic>>> fetchAllUsers() async {
  final client = HttpClient();
  try {
    final usersUrl = '${AppConfig.getBaseUrl()}/api/User';
    final request = await client.getUrl(Uri.parse(usersUrl));
    request.headers.set('Accept', 'application/json');

    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final List<dynamic> data = jsonDecode(responseBody);

      return data.map<Map<String, dynamic>>((user) {
        return {
          'id': user['id'],
          'name': user['name'],
          'surname': user['surname'],
          'email': user['mail'],
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching users: $e');
    rethrow;
  } finally {
    client.close();
  }
}


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
          'addressId': team['addressId'], // Dodaj addressId do danych zespołu
          'address': address,
          'members': members,
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
        // Szukanie rangi przypisanej dla aktualnego teamId
        final rolesInTeams = member['rolesInTeams'] as List<dynamic>;
        final roleData = rolesInTeams.firstWhere(
          (role) => role['teamId'] == teamId,
          orElse: () => null,
        );

        // Pobranie roleId lub domyślnie 0, jeśli brak
        final roleId = roleData != null ? roleData['roleId'] as int : 0;

        // Pobranie nazwy rangi
        final roleName = await fetchRoleName(roleId);

        return {
          'name': '${member['name']} ${member['surname']}',
          'role': roleName.isNotEmpty ? roleName : 'Brak rangi',
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
  if (roleId == 0) {
    return 'Brak rangi'; // Obsługa domyślnej rangi
  }

  final client = HttpClient();
  try {
    final roleUrl = AppConfig.getRoleEndpoint(roleId);
    final request = await client.getUrl(Uri.parse(roleUrl));
    request.headers.set('Accept', 'application/json');

    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> data = jsonDecode(responseBody);

      return data['name']?.toString() ?? 'Brak rangi';
    } else {
      throw Exception('Failed to fetch role name: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching role name for roleId $roleId: $e');
    return 'Brak rangi';
  } finally {
    client.close();
  }
}


}
