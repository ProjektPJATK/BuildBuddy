import 'package:flutter/material.dart';
import '../app_state.dart' as appState;

class BottomNavigation extends StatelessWidget {
  final Function(int) onTap;
  final bool noBackground;

  BottomNavigation({super.key, required this.onTap, this.noBackground = false});

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.calendar_today, 'label': 'Kalendarz', 'page': 'calendar'},
    {'icon': Icons.chat, 'label': 'Czat', 'page': 'chat'},
    {'icon': Icons.home, 'label': 'Home', 'page': 'home'}, // Home na trzecim miejscu
    {'icon': Icons.person, 'label': 'Profil', 'page': 'profile'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: noBackground ? Colors.transparent : Colors.white.withOpacity(0.7), // Właściwe białe tło z przezroczystością
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
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (appState.currentPage != item['page']) {
                      onTap(index); // Poprawiono indeksy nawigacji
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: Colors.transparent, // Przezroczysty kontener
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'],
                          size: 20,
                          color: appState.currentPage == item['page']
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : Colors.black,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'],
                          style: TextStyle(
                            fontSize: 12,
                            color: appState.currentPage == item['page']
                                ? Colors.red
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
