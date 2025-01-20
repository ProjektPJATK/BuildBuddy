import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:web/themes/styles.dart';
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
      _showAlert(context, "you dont have access", "you dont have access, to do it.");
      return;
    }

    final List<dynamic> teamsWithPowerLevels = jsonDecode(teamsJson);

    final hasPermission = teamsWithPowerLevels.any((team) => team['powerLevel'] == 3);

    if (!hasPermission) {
      _showAlert(context, "you dont have access", "you dont have access, to do it.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddProjectDialog(
        onCancel: () {
          Navigator.pop(context);
        },
        onSuccess: (projectData) {
          print('Project added: $projectData');
          _showSuccessNotification(context, 'Project added succesfully.');
          _fetchTeams(); // Odświeżenie danych zespołów
        },
      ),
    );
  }

  void _handleUnauthorizedAction(BuildContext context) {
    _showAlert(context, "you dont have access", "you dont have access, to do it.");
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
              content: Text('Succesfully added worker.'),
              backgroundColor: Colors.green,
            ),
          );

          // Odśwież widok zespołów
          await _fetchTeams();

        } catch (e) {
          print('Błąd podczas dodawania użytkowników: $e');
          scaffoldMessengerContext.showSnackBar(
            SnackBar(
              content: Text('Filed to add worker.'),
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
              content: Text('Team was updated.'),
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
        backgroundColor: const Color.fromARGB(148, 49, 50, 51),
        title: Row(
          children: [
            Text(
              'Teams and Projects',
              style: AppStyles.headerStyle.copyWith(color: Colors.white),
            ),
            SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddProjectDialog(context),
              icon: const Icon(Icons.apartment, size: 24, color: Colors.white),
              label: Text(
                "Add project",
                style: AppStyles.textStyle.copyWith(color: Colors.white),
              ),
              style: AppStyles.buttonStyle().copyWith(
                backgroundColor: MaterialStateProperty.all(AppStyles.primaryBlue),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: AppStyles.backgroundDecoration,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _isError
                ? const Center(
                    child: Text(
                      'Failed to load teams.',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final address = team['address'] as Map<String, String>;
                      final members = team['members'] as List<Map<String, String>>;

                      return Card(
                        color: AppStyles.transparentWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                team['name'],
                                style: AppStyles.headerStyle,
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color.fromARGB(255, 2, 2, 2)),
                                    onPressed: hasPermissionForTeam(team['id'], 3)
                                        ? () => _showEditTeamDialog(context, team)
                                        : () => _handleUnauthorizedAction(context),
                                  ),
                                  TextButton.icon(
                                    onPressed: hasPermissionForTeam(team['id'], 3)
                                        ? () => _showAddUserDialog(
                                              context,
                                              team['id'],
                                              team['members']
                                                      ?.map<int>((member) => int.parse(member['id'].toString()))
                                                      ?.toList() ??
                                                  [],
                                            )
                                        : () => _handleUnauthorizedAction(context),
                                    icon: const Icon(Icons.add, color: AppStyles.primaryBlue),
                                    label: Text(
                                      "Add worker",
                                      style: AppStyles.textStyle.copyWith(color: AppStyles.primaryBlue),
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
                                style: AppStyles.textStyle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Description: ${address['description']}',
                                style: AppStyles.textStyle.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                          children: members
                              .map(
                                (member) => ListTile(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        member['name']!,
                                        style: AppStyles.textStyle,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Color.fromARGB(255, 0, 0, 0)),
                                        onPressed: () => _showEditUserDialog(
                                          context,
                                          int.tryParse(member['id'] ?? '0') ?? 0,
                                          int.tryParse(team['id']?.toString() ?? '0') ?? 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    member['role']!,
                                    style: AppStyles.textStyle.copyWith(color: Colors.black54),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

}