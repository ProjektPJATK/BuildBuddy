import 'package:flutter/material.dart';
import 'package:mobile/features/calendar/views/calendar_screen.dart';
import 'package:mobile/features/chats/views/chat_list_screen.dart';
import 'package:mobile/features/construction_calendar/views/construction_calendar_screen.dart';
import 'package:mobile/features/construction_home/views/construction_home_screen.dart';
import 'package:mobile/features/construction_inventory/views/inventory_screen.dart';
import 'package:mobile/features/construction_team/views/team_screen.dart';
import 'package:mobile/features/profile/views/user_profile_screen.dart';
import '../../features/home/views/home_screen.dart';

import '../state/app_state.dart' as appState;

class NavigationConfig {
  static List<Map<String, dynamic>> getNavItems(bool isConstructionMode) {
    return isConstructionMode
        ? [
            {'icon': Icons.calendar_today, 'label': 'Kalendarz', 'route': '/construction_calendar'},
            {'icon': Icons.people, 'label': 'Zespół', 'route': '/construction_team'},
            {'icon': Icons.home, 'label': 'Home', 'route': '/home'},
            {'icon': Icons.construction, 'label': 'Budowa', 'route': '/construction_home'},
            {'icon': Icons.inventory, 'label': 'Inwentarz', 'route': '/construction_inventory'},
          ]
        : [
            {'icon': Icons.calendar_today, 'label': 'Kalendarz', 'route': '/calendar'},
            {'icon': Icons.chat, 'label': 'Czat', 'route': '/chats'},
            {'icon': Icons.home, 'label': 'Home', 'route': '/home'},
            {'icon': Icons.person, 'label': 'Profil', 'route': '/profile'},
          ];
  }

  static Widget getDestinationScreen(String route) {
    switch (route) {
      case '/calendar':
        return CalendarScreen();
      case '/construction_calendar':
        return ConstructionCalendarScreen();
      case '/construction_team':
        return TeamScreen();
      case '/construction_home':
        return ConstructionHomeScreen();
      case '/construction_inventory':
        return InventoryScreen();
      case '/chats':
        return ChatListScreen();
      case '/home':
        appState.isConstructionContext = false;
        return HomeScreen();
      case '/profile':
        return UserProfileScreen();
      default:
        return HomeScreen();
    }
  }
}
