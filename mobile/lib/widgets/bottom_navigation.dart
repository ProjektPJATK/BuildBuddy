import 'package:flutter/material.dart';
import '../screens/calendar_screen.dart';
import '../screens/constructionTeam_screen.dart';
import '../screens/constructionHome_screen.dart';
import '../screens/constructionInventory_screen.dart';
import '../screens/chatlist_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../app_state.dart' as appState;

class BottomNavigation extends StatelessWidget {
  final Function(int)? onTap;

  BottomNavigation({super.key, this.onTap});

  // Funkcja tworząca animację przesuwania i fade-in/out w stylu Messenger
  PageRouteBuilder<dynamic> _createPageRoute(
      BuildContext context, String route, bool isRight) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200), // Szybsza animacja
      pageBuilder: (context, animation, secondaryAnimation) {
        return _getDestinationScreen(route);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        var slideTween = Tween(
          begin: Offset(isRight ? 0.1 : -0.1, 0), // Małe przesunięcie
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));
        
        var fadeTween = Tween<double>(begin: 0.2, end: 1.0); // Fade-in/out
        
        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  // Funkcja zwracająca odpowiedni ekran na podstawie trasy
  Widget _getDestinationScreen(String route) {
    switch (route) {
      case '/calendar':
        return CalendarScreen();
      case '/construction_team':
        return TeamScreen();
      case '/construction_home':
        return ConstructionHomeScreen();
      case '/construction_inventory':
        return InventoryScreen();
      case '/chats':
        return ChatListScreen();
      case '/home':
        return HomeScreen();
      case '/profile':
        return UserProfileScreen();
      default:
        return HomeScreen(); // Domyślny ekran
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> navItems = appState.isConstructionContext
        ? [
            {'icon': Icons.calendar_today, 'label': 'Kalendarz', 'route': '/calendar'},
            {'icon': Icons.people, 'label': 'Zespół', 'route': '/construction_team'},
            {'icon': Icons.home, 'label': 'Budowa', 'route': '/construction_home'},
            {'icon': Icons.inventory, 'label': 'Inwentarz', 'route': '/construction_inventory'},
          ]
        : [
            {'icon': Icons.calendar_today, 'label': 'Kalendarz', 'route': '/calendar'},
            {'icon': Icons.chat, 'label': 'Czat', 'route': '/chats'},
            {'icon': Icons.home, 'label': 'Home', 'route': '/home'},
            {'icon': Icons.person, 'label': 'Profil', 'route': '/profile'},
          ];

    return Container(
      color: Colors.white.withOpacity(0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            thickness: 1,
            color: Colors.white,
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final bool isCurrentPage = appState.currentPage == item['route'].replaceAll('/', '');

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!isCurrentPage) {
                      bool isRight = index > navItems.indexWhere((navItem) =>
                          navItem['route'].replaceAll('/', '') == appState.currentPage);

                      appState.currentPage = item['route'].replaceAll('/', '');

                      Navigator.of(context).push(
                        _createPageRoute(context, item['route'], isRight),
                      );
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Container(
                      key: ValueKey(isCurrentPage),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'],
                            size: 20,
                            color: isCurrentPage ? Colors.white : Colors.black,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['label'],
                            style: TextStyle(
                              fontSize: 12,
                              color: isCurrentPage ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
