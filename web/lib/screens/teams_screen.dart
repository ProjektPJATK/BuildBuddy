import 'package:flutter/material.dart';
import 'package:web/services/teams_service.dart';

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

  Future<void> _fetchTeams() async {
    try {
      final fetchedTeams =
          await _teamsService.fetchTeamsWithMembers(widget.loggedInUserId, widget.loggedInUserId);

      if (mounted) {
        setState(() {
          teams = fetchedTeams;
          _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Teams and Projects',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Dodaj logikę dodawania projektu
                print("Dodaj Projekt clicked");
              },
              icon: Icon(Icons.apartment, size: 24), // Ikonka budynku
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
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
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
                              TextButton.icon(
                                onPressed: () {
                                  // Dodaj logikę dodawania pracownika do zespołu
                                  print("Dodaj pracownika do teamu ${team['name']}");
                                },
                                icon: Icon(Icons.add, color: Colors.blue),
                                label: Text(
                                  "Dodaj Pracownika",
                                  style: TextStyle(color: Colors.blue, fontSize: 14),
                                ),
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
                                          // Dodaj logikę edycji danych użytkownika
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
                ),
    );
  }
}
