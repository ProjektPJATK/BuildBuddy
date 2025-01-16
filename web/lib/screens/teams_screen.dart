import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:web/widgets/add_project_dialog.dart';
import 'package:web/services/teams_service.dart';
import 'package:web/widgets/add_user_dialog.dart';
import 'package:web/widgets/edit_team_dialog.dart';
import 'package:web/widgets/edit_user_dialog.dart';

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
late BuildContext _messengerContext;
  @override
  void initState() {
    super.initState();
    _fetchTeams();
    _messengerContext = context;
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
  
void _showAddUserDialog(BuildContext context, int teamId, List<int> existingUserIds) {
  final scaffoldMessengerContext = ScaffoldMessenger.of(context);

  showDialog(
    context: context,
    builder: (context) => AddUserDialog(
      teamId: teamId,
      existingUserIds: existingUserIds,
      onCancel: () {
        Navigator.pop(context);
      },
      onSuccess: (List<int> userIds) async {
        try {
          for (final userId in userIds) {
            print('Dodawanie użytkownika $userId do zespołu $teamId');
            await _teamsService.addUserToTeam(teamId, userId);
          }

          // Wyświetl komunikat o sukcesie
          scaffoldMessengerContext.showSnackBar(
            SnackBar(
              content: Text('Użytkownicy zostali pomyślnie dodani do zespołu.'),
              backgroundColor: Colors.green,
            ),
          );

          // Odśwież widok zespołów
          await _fetchTeams();

        } catch (e) {
          print('Błąd podczas dodawania użytkowników: $e');
          scaffoldMessengerContext.showSnackBar(
            SnackBar(
              content: Text('Nie udało się dodać użytkowników do zespołu.'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          Navigator.pop(context);
        }
      },
    ),
  );
}



void _showEditTeamDialog(BuildContext context, Map<String, dynamic> team) {
  final scaffoldMessengerContext = ScaffoldMessenger.of(context);

  showDialog(
    context: context,
    builder: (context) => EditTeamDialog(
      teamId: team['id'], // Przekazanie teamId
      teamName: team['name'],
      addressData: team['address'] as Map<String, String>,
      onSubmit: (updatedName, updatedAddress) async {
        final addressId = team['addressId'];

        try {
          await _teamsService.updateAddress(addressId, updatedAddress);
          await _teamsService.updateTeam(team['id'], updatedName, addressId);

          // Wyświetl komunikat o sukcesie
          scaffoldMessengerContext.showSnackBar(
            SnackBar(
              content: Text('Team został pomyślnie zaktualizowany.'),
              backgroundColor: Colors.green,
            ),
          );

          // Odśwież widok zespołów
          await _fetchTeams();

        } catch (e) {
          print('Error updating team or address: $e');
          scaffoldMessengerContext.showSnackBar(
            SnackBar(
              content: Text('Nie udało się zaktualizować zespołu.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      onCancel: () {
        Navigator.pop(context);
      },
      onTeamDeleted: _fetchTeams,
    ),
  );
}

void _showEditUserDialog(BuildContext context, int userId, int teamId) {
  showDialog(
    context: context,
    builder: (context) => EditUserDialog(
      userId: userId,
      teamId: teamId,
      onCancel: () {
        Navigator.pop(context);
      },
      onSubmit: (newPowerLevel, newRoleName) async {
        try {
          // Aktualizacja roli użytkownika
          await _teamsService.updateUserRole(userId, teamId, newPowerLevel, newRoleName);
          print('Rola użytkownika zaktualizowana pomyślnie');

          // Odświeżenie widoku zespołów
          _fetchTeams();
        } catch (e) {
          print('Błąd podczas aktualizacji rangi użytkownika: $e');
        }
      },
      onDelete: () {
    _fetchTeams(); // Odświeżenie widoku po usunięciu użytkownika
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
                                    _showAddUserDialog(
                                    context,
                                    team['id'],
                                    team['members']?.map<int>((member) => int.parse(member['id'].toString()))?.toList() ?? [], // Lista istniejących użytkowników
                                  );
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${address['street']} ${address['houseNumber']}, ${address['city']}, ${address['country']}, ${address['postalCode']}',
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Opis: ${address['description']}', // Wyświetlanie opisu
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
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
                              print("Edytuj dane użytkownika ${member['name']}, ID: ${member['id']}");
                            _showEditUserDialog(
                              context,
                              int.tryParse(member['id'] ?? '0') ?? 0,
                              int.tryParse(team['id']?.toString() ?? '0') ?? 0,
                            );
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