// lib/widgets/bottom_navigation.dart
import 'package:flutter/material.dart';
import '../app_state.dart' as appState;

class BottomNavigation extends StatelessWidget {
  final Function(int) onTap;

  BottomNavigation({required this.onTap});

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.calendar_today, 'label': 'Kalendarz', 'page': 'calendar'},
    {'icon': Icons.chat, 'label': 'Czat', 'page': 'chats'},
    {'icon': Icons.person, 'label': 'Profil', 'page': 'profile'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            thickness: 1,
            color: Colors.white,
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _navItems.map((item) {
              int index = _navItems.indexOf(item);
              return Expanded(
                child: InkWell(
                  onTap: appState.currentPage == item['page']
                      ? null
                      : () => onTap(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'],
                        size: 20,
                        color: appState.currentPage == item['page']
                            ? Colors.blue
                            : Colors.black,
                      ),
                      Text(
                        item['label'],
                        style: TextStyle(
                          fontSize: 12,
                          color: appState.currentPage == item['page']
                              ? Colors.blue
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
