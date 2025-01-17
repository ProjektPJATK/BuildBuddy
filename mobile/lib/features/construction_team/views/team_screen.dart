import 'package:flutter/material.dart';
import 'package:mobile/features/construction_team/services/team_service.dart';
import 'package:mobile/shared/config/config.dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/shared/widgets/bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/state/app_state.dart' as appState;
import 'widgets/team_member_card.dart';
import 'package:http/http.dart' as http;

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  _TeamScreenState createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final TeamService teamService = TeamService();
  List<Map<String, dynamic>> teamMembers = [];
  bool isLoading = true;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    appState.currentPage = 'construction_team';
    _loadTeamMembers();
  }

  Future<void> _loadTeamMembers() async {
    try {
      final members = await teamService.getTeamMembers();
       final prefs = await SharedPreferences.getInstance();
      currentUserId = prefs.getInt('userId');

      for (var member in members) {
        final role = member['roles'].isEmpty
            ? 'Brak roli'
            : await teamService.getRoleName(member['roles'][0]['roleId']);
        member['role'] = role;
      }

      setState(() {
        teamMembers = members;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading team members: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showTeamMemberDialog(Map<String, dynamic> member) {
  final teamService = TeamService();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: FutureBuilder<String>(
          future: teamService.fetchUserImage(member['id']),
          builder: (context, snapshot) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(), // Indykator ładowania
                        )
                      : (snapshot.hasError || snapshot.data?.isEmpty == true)
                          ? const Icon(Icons.person, size: 50) // Ikona zastępcza
                          : Image.network(
                              snapshot.data!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                ),
                const SizedBox(height: 10), // Odstęp
                Text(
                  member['name'] ?? 'Nieznane imię i nazwisko',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rola: ${member['role'] ?? 'Brak roli'}'),
            Text('Email: ${member['email'] ?? 'Brak emaila'}'),
            Text('Telefon: ${member['phone'] ?? 'Brak telefonu'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Zamknij'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: AppStyles.backgroundDecoration),
          Container(color: AppStyles.filterColor.withOpacity(0.75)),
          Column(
            children: [
              Container(
                width: double.infinity,
                color: AppStyles.transparentWhite,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
                child: Text(
                  'Zespół budowy',
                  style: AppStyles.headerStyle.copyWith(color: Colors.black, fontSize: 22),
                ),
              ),
              Expanded(
                child: Container(
                  color: AppStyles.transparentWhite,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: teamMembers.length,
                          itemBuilder: (context, index) {
                            final member = teamMembers[index];
                            final isCurrentUser = member['id'] == currentUserId;
                            return TeamMemberCard(
                              name: isCurrentUser ? '${member['name']} (ja)' : member['name'],
                              role: member['role'],
                              phone: member['phone'],
                              onInfoPressed: isCurrentUser
                                  ? null
                                  : () {
                                      _showTeamMemberDialog(member);
                                    },
                            );
                          },
                        ),
                ),
              ),
              BottomNavigation(onTap: (_) {}),
            ],
          ),
        ],
      ),
    );
  }
}
