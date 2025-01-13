import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:web/widgets/add_project_dialog.dart';
import 'package:web/services/teams_service.dart';
import 'package:web/widgets/add_user_dialog.dart';
import 'package:web/widgets/edit_item_dialog.dart';

class TeamsScreen extends StatefulWidget {
  final int loggedInUserId;

  TeamsScreen({required this.loggedInUserId});

  @override
  _TeamsScreenState createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final TeamsService _teamsService = TeamsService();
  List<Map<String, dynamic>> teams = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool hasPermissionForTeam(int teamId, int requiredPowerLevel) {
    final teamsJson = html.window.localStorage['teamsWithPowerLevels'];
    if (teamsJson == null) return false;

    final List<dynamic> teamsWithPowerLevels = jsonDecode(teamsJson);

    // Znajdź team i sprawdź powerLevel
    final team = teamsWithPowerLevels.firstWhere(
      (team) => team['teamId'] == teamId,
      orElse: () => null,
    );

    if (team == null) return false;

    return team['powerLevel'] >= requiredPowerLevel;
  }

  void _showAddProjectDialog(BuildContext context) {
    final teamsJson = html.window.localStorage['teamsWithPowerLevels'];
    if (teamsJson == null) {
      _showAlert(context, "Brak uprawnień", "Nie masz odpowiednich uprawnień do dodawania projektu.");
      return;
    }

    final List<dynamic> teamsWithPowerLevels = jsonDecode(teamsJson);

    final hasPermission = teamsWithPowerLevels.any((team) => team['powerLevel'] == 3);

    if (!hasPermission) {
      _showAlert(context, "Brak uprawnień", "Nie masz odpowiednich uprawnień do dodawania projektu.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddProjectDialog(
        onCancel: () {
          Navigator.pop(context);
        },
        onSuccess: (projectData) {
          print('Projekt dodany: $projectData');
          _showSuccessNotification(context, 'Projekt został pomyślnie dodany.');
          _fetchTeams(); // Odświeżenie danych zespołów
        },
      ),
    );
  }

  void _handleUnauthorizedAction(BuildContext context) {
    _showAlert(context, "Brak uprawnień", "Nie masz wystarczających uprawnień, aby wykonać tę akcję.");
  }

  Future<void> _fetchTeams() async {
    setState(() {
      _isLoading = true; // Pokazuje loader podczas odświeżania
    });

    try {
      final fetchedTeams = await _teamsService.fetchTeamsWithMembers(widget.loggedInUserId, widget.loggedInUserId);

      if (mounted) {
        setState(() {
          teams = fetchedTeams;
          _isLoading = false; // Ukrywa loader po odświeżeniu
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
      print('Error fetching teams: $e');
    }
  }
  
  void _showAddUserDialog(BuildContext context, int teamId) {
  showDialog(
    context: context,
    builder: (context) => AddUserDialog(
      teamId: teamId,
      onCancel: () {
        Navigator.pop(context);
      },
      onSuccess: (userId) {
        _showSuccessNotification(context, 'Użytkownik został pomyślnie dodany do zespołu.');
        _fetchTeams(); // Odśwież widok zespołów
      },
    ),
  );
}

void _showEditTeamDialog(BuildContext context, Map<String, dynamic> team) {
  showDialog(
    context: context,
    builder: (context) => EditTeamDialog(
      teamName: team['name'],
      addressData: team['address'] as Map<String, String>,
      onSubmit: (updatedName, updatedAddress) async {
        final teamId = team['id'];
        final addressId = team['addressId'];

        try {
          await _teamsService.updateAddress(addressId, updatedAddress);
          await _teamsService.updateTeam(teamId, updatedName, addressId);

          _showSuccessNotification(context, 'Team został pomyślnie zaktualizowany.');
          _fetchTeams(); // Odświeżenie listy zespołów
        } catch (e) {
          print('Error updating team or address: $e');
          _showAlert(context, 'Błąd', 'Nie udało się zaktualizować zespołu.');
        }
      },
      onCancel: () {
        Navigator.pop(context);
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Teams and Projects',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 16), // Odstęp między tekstem a przyciskiem
            ElevatedButton.icon(
              onPressed: () => _showAddProjectDialog(context),
              icon: Icon(Icons.apartment, size: 24),
              label: Text(
                "Dodaj Projekt",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
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
              : Center(
                  child: ListView.builder(
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final address = team['address'] as Map<String, String>;
                      final members = team['members'] as List<Map<String, String>>;

                      return ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              team['name'],
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.orange),
                                  onPressed: hasPermissionForTeam(team['id'], 3)
                                      ? () {
                                          print("Edytuj zespół: ${team['name']}");
                                          print('Team data: ${team.toString()}');
                                          _showEditTeamDialog(context, team);
                                        }
                                      : () => _handleUnauthorizedAction(context),
                                ),
                                TextButton.icon(
                                  onPressed: hasPermissionForTeam(team['id'], 3)
                                      ? () {
                                          print("Dodaj pracownika do teamu ${team['name']}");
                                          _showAddUserDialog(context, team['id']);
                                        }
                                      : () => _handleUnauthorizedAction(context),
                                       icon: Icon(Icons.add, color: Colors.blue),
                                        label: Text(
                                          "Dodaj Pracownika",
                                          style: TextStyle(color: Colors.blue),
                                ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '${address['street']} ${address['houseNumber']}, ${address['city']}, ${address['country']}, ${address['postalCode']}',
                        ),
                        children: members
                            .map(
                              (member) => ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(member['name']!),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.orange),
                                      onPressed: () {
                                        print("Edytuj dane użytkownika ${member['name']}");
                                      },
                                    ),
                                  ],
                                ),
                                subtitle: Text(member['role']!),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ),
    );
  }
}
