import 'package:flutter/material.dart';
import '../widgets/build_option.dart';
import '../widgets/notification_item.dart';
import '../widgets/bottom_navigation.dart';
import '../app_state.dart' as appState;
import '../styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
                      color: AppStyles.transparentWhite, // Białe przezroczyste tło
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
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              BuildOption(
                                title: 'Budowa w Gdańsku',
                                onTap: () {
                                  appState.selectedConstructionName = 'Budowa w Gdańsku';
                                  appState.isConstructionContext = true;
                                  Navigator.pushNamed(context, '/construction_home');
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
                    color: AppStyles.transparentWhite, // Białe przezroczyste tło dla powiadomień
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
                // Bottom Navigation w głównym kontenerze
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
