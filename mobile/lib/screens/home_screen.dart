import 'package:flutter/material.dart';
import '../widgets/build_option.dart';
import '../widgets/notification_item.dart';
import '../widgets/bottom_navigation.dart';
import '../app_state.dart' as appState;
import '../styles.dart'; // Import stylów

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    appState.currentPage = 'home'; // Ustawiamy stronę Home jako aktualną
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
          // Screen content
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
                    decoration: BoxDecoration(
                      color: AppStyles.transparentWhite,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            'Wybierz budowę',
                            style: AppStyles.headerStyle,
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              BuildOption(
                                title: 'Budowa w Gdańsku',
                                onTap: () {
                                  Navigator.pushNamed(context, '/gdansk');
                                },
                              ),
                              BuildOption(
                                title: 'Budowa w Warszawie',
                                onTap: () {
                                  Navigator.pushNamed(context, '/warszawa');
                                },
                              ),
                              BuildOption(
                                title: 'Budowa w Krakowie',
                                onTap: () {
                                  Navigator.pushNamed(context, '/krakow');
                                },
                              ),
                            ],
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
                          child: Text(
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
                  onTap: (index) {
                    if (index == 0) {
                      Navigator.pushNamed(context, '/calendar'); // Kalendarz
                    } else if (index == 1) {
                      Navigator.pushNamed(context, '/chat'); // Czat
                    } else if (index == 2) {
                      Navigator.pushNamed(context, '/home'); // Home
                    } else if (index == 3) {
                      Navigator.pushNamed(context, '/profile'); // Profil
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
