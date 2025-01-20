import 'package:universal_io/io.dart';
import 'dart:convert';
import 'package:web_app/config/config.dart';
import 'package:universal_html/html.dart' as html;

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

Future<void> deleteUserFromTeam(int teamId, int userId) async {
  final client = HttpClient();
  final deleteUrl = '${AppConfig.getBaseUrl()}/api/Team/$teamId/users/$userId';
  print('Deleting user $userId from team $teamId with URL: $deleteUrl');

  try {
    final request = await client.deleteUrl(Uri.parse(deleteUrl));
    request.headers.set('Content-Type', 'application/json');

    final response = await request.close();

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('User $userId successfully deleted from team $teamId.');
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Failed to delete user: ${response.statusCode}, Response: $responseBody');
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  } catch (e) {
    print('Error deleting user $userId from team $teamId: $e');
    rethrow;
  } finally {
    client.close();
  }
}

Future<void> updateUserRole(int userId, int teamId, int newPowerLevel, String newRoleName) async {
  final client = HttpClient();

  try {
    // Pobieranie bieżących ról użytkownika w danym zespole
    print('Fetching current roles for userId: $userId in teamId: $teamId');
    final userData = await getUserData(userId);
    final rolesInTeams = userData['rolesInTeams'] as List<dynamic>;
    final previousRole = rolesInTeams.firstWhere(
      (role) => role['teamId'] == teamId,
      orElse: () => null,
    );

    // Usuwanie poprzedniej rangi, jeśli istnieje
    if (previousRole != null) {
      final previousRoleId = previousRole['roleId'];
      print('Removing previous roleId: $previousRoleId from userId: $userId in teamId: $teamId');

      final deleteRoleRequest = await client.deleteUrl(
        Uri.parse('${AppConfig.getBaseUrl()}/api/Roles/$previousRoleId/users/$userId/teams/$teamId'),
      );
      final deleteRoleResponse = await deleteRoleRequest.close();

      if (deleteRoleResponse.statusCode != 200 && deleteRoleResponse.statusCode != 204) {
        final responseBody = await deleteRoleResponse.transform(utf8.decoder).join();
        throw Exception('Failed to remove previous role: ${deleteRoleResponse.statusCode}, Response: $responseBody');
      }

      print('Removed previous roleId: $previousRoleId from userId: $userId in teamId: $teamId');
    } else {
      print('No previous role found for userId: $userId in teamId: $teamId');
    }

    // Tworzenie nowej rangi
    print('Creating a new role with name: $newRoleName and powerLevel: $newPowerLevel');
    final createRoleRequest = await client.postUrl(Uri.parse('${AppConfig.getBaseUrl()}/api/Roles'));
    createRoleRequest.headers.set('Content-Type', 'application/json');
    createRoleRequest.add(utf8.encode(jsonEncode({
      'name': newRoleName,
      'powerLevel': newPowerLevel,
    })));

    final createRoleResponse = await createRoleRequest.close();

    if (createRoleResponse.statusCode != 201) {
      final responseBody = await createRoleResponse.transform(utf8.decoder).join();
      throw Exception('Failed to create role: ${createRoleResponse.statusCode}, Response: $responseBody');
    }

    final createRoleResponseBody = await createRoleResponse.transform(utf8.decoder).join();
    final createdRoleId = jsonDecode(createRoleResponseBody)['id'];
    print('Created role with id: $createdRoleId');

    // Przypisywanie nowej rangi do użytkownika
    print('Assigning roleId: $createdRoleId to userId: $userId in teamId: $teamId');
    final assignRoleRequest = await client.postUrl(
      Uri.parse('${AppConfig.getBaseUrl()}/api/Roles/$createdRoleId/users/$userId/teams/$teamId'),
    );
    assignRoleRequest.headers.set('Content-Type', 'application/json');
    final assignRoleResponse = await assignRoleRequest.close();

    if (assignRoleResponse.statusCode != 201 && assignRoleResponse.statusCode != 204 && assignRoleResponse.statusCode != 200) {
      final responseBody = await assignRoleResponse.transform(utf8.decoder).join();
      throw Exception('Failed to assign role: ${assignRoleResponse.statusCode}, Response: $responseBody');
    }

    print('Assigned roleId: $createdRoleId to userId: $userId in teamId: $teamId');
  } catch (e) {
    print('Błąd podczas aktualizacji rangi użytkownika: $e');
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
    print('Starting to add user $userId to team $teamId with URL: $addUserUrl');

    final request = await client.postUrl(Uri.parse(addUserUrl));
    request.headers.set('Content-Type', 'application/json');

    final response = await request.close();

    if (response.statusCode == 204 || response.statusCode == 200 || response.statusCode == 201) {
      print('User $userId successfully added to team $teamId');
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Failed to add user: ${response.statusCode}, Response: $responseBody');
      throw Exception('Failed to add user to team: ${response.statusCode}');
    }
  } catch (e) {
    print('Error adding user $userId to team $teamId: $e');
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

Future<void> addRoleToUserInTeam({
  required int userId,
  required int teamId,
  required int roleId,
}) async {
  final client = HttpClient();
  final url = '${AppConfig.getBaseUrl()}/api/Roles/$roleId/users/$userId/teams/$teamId';
  print('Attempting to add role: $roleId to user: $userId in team: $teamId with URL: $url');

  try {
    final request = await client.postUrl(Uri.parse(url));
    request.headers.set('Content-Type', 'application/json');

    final response = await request.close();

    if (response.statusCode == 201 || response.statusCode == 204 || response.statusCode == 200) {
      print('Role added successfully for user $userId in team $teamId.');

    } else {
      throw Exception('Failed to add role: ${response.statusCode}');
    }
  } catch (e) {
    print('Error adding role to user in team: $e');
    rethrow;
  } finally {
    client.close();
  }
}

Future<void> deleteTeam(int teamId) async {
  final client = HttpClient();
  try {
    final deleteUrl = '${AppConfig.getBaseUrl()}/api/Team/$teamId';
    final request = await client.deleteUrl(Uri.parse(deleteUrl));
    request.headers.set('Content-Type', 'application/json');

    final response = await request.close();

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Team $teamId deleted successfully.');
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Failed to delete team $teamId: ${response.statusCode}');
      print('Response body: $responseBody');
      throw Exception('Failed to delete team: ${response.statusCode}');
    }
  } catch (e) {
    print('Error deleting team $teamId: $e');
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
        'description': data['description'], // Dodano opis
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
          'id': member['id']?.toString() ?? '0',
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

Future<Map<String, dynamic>> getUserData(int userId) async {
  final client = HttpClient();
  final url = '${AppConfig.getBaseUrl()}/api/User/$userId';
  print('Fetching user data from: $url');

  try {
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('Accept', 'application/json');
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('User data response: $responseBody');
      return jsonDecode(responseBody);
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Failed to fetch user data: ${response.statusCode}');
      print('Response body: $responseBody');
      throw Exception('Failed to fetch user data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching user data: $e');
    rethrow;
  } finally {
    client.close();
  }
}


Future<Map<String, dynamic>> getRoleDetails(int roleId) async {
  final client = HttpClient();
  final url = '${AppConfig.getBaseUrl()}/api/Roles/$roleId';
  print('Fetching role details from: $url');

  try {
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('Accept', 'application/json');
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Role details response: $responseBody');
      return jsonDecode(responseBody);
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Failed to fetch role details: ${response.statusCode}');
      print('Response body: $responseBody');
      throw Exception('Failed to fetch role details: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching role details: $e');
    rethrow;
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