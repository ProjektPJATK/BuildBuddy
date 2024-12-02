import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/build_option.dart';
import '../widgets/notification_item.dart';
import '../widgets/bottom_navigation.dart';
import '../styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> teams = [];
  bool isLoading = true;
  bool hasError = false;
  int? userId;

  // Determine backend URL
  String getBackendUrl() {
    const backendIP = "10.0.2.2"; // Replace for Android emulator or with your IP
    const backendPort = "5007";
    return "http://$backendIP:$backendPort/api/Team/$userId/teams";
  }

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  // Initialize userId from SharedPreferences and fetch teams
  Future<void> _initializeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });
    if (userId != null) {
      fetchTeams();
    } else {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // Fetch team data from backend
  Future<void> fetchTeams() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final url = getBackendUrl();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Pass token for authentication
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          teams = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching teams: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // Save teamId and placeId to SharedPreferences with console logs
  Future<void> _saveSelectedTeam(int teamId, int placeId) async {
    final prefs = await SharedPreferences.getInstance();

    // Save the teamId and placeId
    await prefs.setInt('teamId', teamId);
    await prefs.setInt('placeId', placeId);

    // Console logs to debug
    print('Saved teamId: $teamId');
    print('Saved placeId: $placeId');
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
          // Small logo
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SizedBox(
                width: 45,
                height: 45,
                child: Image.asset('assets/logo_small.png'),
              ),
            ),
          ),
          // Main screen content
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: const BoxDecoration(
                      color: AppStyles.transparentWhite,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: const Text(
                            'Wybierz budowę',
                            style: AppStyles.headerStyle,
                          ),
                        ),
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : hasError
                                  ? const Center(child: Text('Błąd podczas ładowania danych.'))
                                  : ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: teams.length,
                                      itemBuilder: (context, index) {
                                        final team = teams[index];
                                        return BuildOption(
                                          title: team['name'],
                                          onTap: () async {
                                            // Save the selected team's data
                                            await _saveSelectedTeam(team['id'], team['placeId']);

                                            // Navigate to the next screen
                                            Navigator.pushNamed(context, '/construction_home', arguments: {
                                              'teamId': team['id'],
                                              'placeId': team['placeId'],
                                            });
                                          },
                                        );
                                      },
                                    ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(thickness: 1, color: Colors.white, height: 10),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    color: AppStyles.transparentWhite,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: const Text(
                            'Powiadomienia',
                            style: AppStyles.headerStyle,
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: const [
                              NotificationItem(title: 'Powiadomienie 1: Nowa aktualizacja budowy w Gdańsku'),
                              NotificationItem(title: 'Powiadomienie 2: Termin zakończenia budowy w Warszawie przesunięty'),
                              NotificationItem(title: 'Powiadomienie 3: Zmiana w planie budowy w Krakowie'),
                              NotificationItem(title: 'Powiadomienie 4: Spotkanie z inwestorem w Gdańsku'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
