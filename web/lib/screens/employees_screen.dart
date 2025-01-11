import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import 'dart:convert';

class TeamsScreen extends StatefulWidget {
  final int loggedInUserId;

  TeamsScreen({required this.loggedInUserId});

  @override
  _TeamsScreenState createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  List<Map<String, dynamic>> teams = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    final client = HttpClient();
    try {
      final teamsUrl = 'http://localhost:5159/api/User/${widget.loggedInUserId}/teams';
      final request = await client.getUrl(Uri.parse(teamsUrl));
      request.headers.set('Accept', 'application/json');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = jsonDecode(responseBody);

        List<Map<String, dynamic>> allTeams = [];

        for (var team in data) {
          final teamId = team['id'];
          final teamName = team['name'];

          final members = await _fetchTeamMembers(teamId);

          allTeams.add({
            'id': teamId,
            'name': teamName,
            'members': members,
          });
        }

        if (mounted) {
          setState(() {
            teams = allTeams;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isError = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
      print('Error fetching teams: $e');
    } finally {
      client.close();
    }
  }

  Future<List<Map<String, String>>> _fetchTeamMembers(int teamId) async {
    final client = HttpClient();
    try {
      final membersUrl = 'http://localhost:5159/api/Team/$teamId/users';
      final request = await client.getUrl(Uri.parse(membersUrl));
      request.headers.set('Accept', 'application/json');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = jsonDecode(responseBody);

        List<Map<String, String>> members = [];

        for (var member in data) {
          if (member['id'] != widget.loggedInUserId) {
            final roleName = await _fetchRoleName(member['roleId']);

            members.add({
              'name': '${member['name']} ${member['surname']}',
              'role': roleName,
            });
          }
        }

        return members;
      }
    } catch (e) {
      print('Error fetching team members for team $teamId: $e');
    } finally {
      client.close();
    }

    return [];
  }

  Future<String> _fetchRoleName(int roleId) async {
    final client = HttpClient();
    try {
      final roleUrl = 'http://localhost:5159/api/Roles/$roleId';
      final request = await client.getUrl(Uri.parse(roleUrl));
      request.headers.set('Accept', 'application/json');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(responseBody);

        return data['name'] ?? 'Unknown Role';
      }
    } catch (e) {
      print('Error fetching role name for roleId $roleId: $e');
    } finally {
      client.close();
    }

    return 'Unknown Role';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? const Center(
                  child: Text(
                    'Failed to load teams.',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return ExpansionTile(
                      title: Text(team['name']),
                      children: (team['members'] as List<Map<String, String>>)
                          .map(
                            (member) => ListTile(
                              title: Text(member['name']!),
                              subtitle: Text(member['role']!),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
    );
  }
}
