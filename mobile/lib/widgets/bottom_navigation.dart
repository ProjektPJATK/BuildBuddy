import 'package:flutter/material.dart';
import '../app_state.dart' as appState;

class BottomNavigation extends StatelessWidget {
  final Function(int)? onTap;

  const BottomNavigation({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Zestaw elementów paska nawigacji dla normalnego kontekstu i kontekstu budowy
    final List<Map<String, dynamic>> navItems = appState.isConstructionContext
        ? [
            {'icon': Icons.home, 'label': 'Budowa', 'route': '/construction_home'},
            {'icon': Icons.people, 'label': 'Zespół', 'route': '/construction_team'},
            {'icon': Icons.inventory, 'label': 'Inwentarz', 'route': '/construction_inventory'},
            {'icon': Icons.calendar_today, 'label': 'Kalendarz', 'route': '/calendar'},
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
              // Usuń '/' z route podczas porównania
              final bool isCurrentPage = appState.currentPage == item['route'].replaceAll('/', '');

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    print('Current page before tap: ${appState.currentPage}');
                    print('Attempting to navigate to: ${item['route']}');

                    if (!isCurrentPage) {
                      appState.currentPage = item['route'].replaceAll('/', '');
                      print('Current page after tap: ${appState.currentPage}');

                      Navigator.of(context).pushNamedAndRemoveUntil(
                        item['route'],
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'],
                          size: 20,
                          color: isCurrentPage
                              ? Colors.white // Biały kolor dla wybranego elementu
                              : Colors.black,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isCurrentPage
                                ? Colors.white // Biały kolor dla wybranego tekstu
                                : Colors.black,
                          ),
                        ),
                      ],
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
