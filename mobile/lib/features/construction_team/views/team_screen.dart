import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/shared/widgets/bottom_navigation.dart';
import 'widgets/team_member_card.dart';
import '../../../shared/state/app_state.dart' as appState;

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
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: teamMembers.length,
                    itemBuilder: (context, index) {
                      final member = teamMembers[index];
                      return TeamMemberCard(
                        name: member['name']!,
                        role: member['role']!,
                        phone: member['phone']!,
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
