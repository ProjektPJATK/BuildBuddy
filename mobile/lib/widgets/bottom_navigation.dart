import 'package:flutter/material.dart';
import '../app_state.dart' as appState; // Importujemy zmienną globalną

class BottomNavigation extends StatelessWidget {
  final Function(int) onTap;

  BottomNavigation({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.7), // Białe tło z przezroczystością 0.7
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            thickness: 1,
            color: Colors.white,
            height: 20, // Wysokość Dividera między kalendarzem a ikonami
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: InkWell(
                  onTap: appState.currentPage == 'calendar'
                      ? null // Dezaktywujemy możliwość klikania w kalendarz, jeśli to aktualna strona
                      : () => onTap(0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: appState.currentPage == 'calendar'
                            ? Colors.blue // Aktywna ikona zmienia kolor
                            : Colors.black,
                      ),
                      Text(
                        'Kalendarz',
                        style: TextStyle(
                          fontSize: 12,
                          color: appState.currentPage == 'calendar'
                              ? Colors.blue // Aktywny tekst zmienia kolor
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: appState.currentPage == 'chats'
                      ? null
                      : () => onTap(1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat,
                        size: 20,
                        color: appState.currentPage == 'chats'
                            ? Colors.blue
                            : Colors.black,
                      ),
                      Text(
                        'Czat',
                        style: TextStyle(
                          fontSize: 12,
                          color: appState.currentPage == 'chats'
                              ? Colors.blue
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: appState.currentPage == 'profile'
                      ? null
                      : () => onTap(2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        size: 20,
                        color: appState.currentPage == 'profile'
                            ? Colors.blue
                            : Colors.black,
                      ),
                      Text(
                        'Profil',
                        style: TextStyle(
                          fontSize: 12,
                          color: appState.currentPage == 'profile'
                              ? Colors.blue
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
