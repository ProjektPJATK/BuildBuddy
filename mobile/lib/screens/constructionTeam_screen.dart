import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../app_state.dart' as appState;
import '../styles.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  _TeamScreenState createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final List<Map<String, String>> teamMembers = [
    {'name': 'Marta Nowak', 'role': 'Kierownik budowy', 'phone': '+48 123 456 789'},
    {'name': 'Jan Kowalski', 'role': 'Elektryk', 'phone': '+48 987 654 321'},
    {'name': 'Piotr Malinowski', 'role': 'Ekipa wykończeniowa', 'phone': '+48 456 123 789'},
    {'name': 'Anna Wiśniewska', 'role': 'Projektant', 'phone': '+48 321 789 654'},
  ];

  @override
  void initState() {
    super.initState();
    appState.currentPage = 'construction_team';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          // Filter
          Container(
            color: AppStyles.filterColor.withOpacity(0.75),
          ),
          // Main content with semi-transparent white background covering the entire screen
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                // Full header background
                Container(
                  color: AppStyles.transparentWhite,
                  width: double.infinity, // Fill the full width
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
                  child: Text(
                    'Zespół budowy',
                    style: AppStyles.headerStyle.copyWith(color: Colors.black, fontSize: 22),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: AppStyles.transparentWhite,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: teamMembers.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.white.withOpacity(0.7),
                          child: ListTile(
                            title: Text(teamMembers[index]['name']!),
                            subtitle: Text('${teamMembers[index]['role']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.phone),
                              onPressed: () {
                                // Action for calling team member
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Bottom Navigation
                BottomNavigation(
                  onTap: (_) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
