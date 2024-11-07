import 'package:flutter/material.dart';
import 'package:mobile/screens/chat_screen.dart';
import 'package:mobile/screens/constructionHome_screen.dart';
import 'package:mobile/screens/constructionInventory_screen.dart';
import 'package:mobile/screens/constructionTeam_screen.dart';
import 'package:mobile/screens/register_screen.dart';
import 'screens/chatList_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/splash_screen.dart';

import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/newMessage_screen.dart';

void main() {
  runApp(const BuildBuddyApp());
}

class BuildBuddyApp extends StatelessWidget {
  const BuildBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',  // Start at the SplashScreen
      routes: {
        '/': (context) => const SplashScreen(), // Show splash screen first
        '/home': (context) => HomeScreen(),
        '/chats': (context) => ChatListScreen(),
        '/calendar': (context) => const CalendarScreen(), // Calendar screen
        '/profile': (context) => const UserProfileScreen(),
        '/newMessage': (context) => NewMessageScreen(),
        '/construction_home': (context) => ConstructionHomeScreen(),
        '/construction_team': (context) => TeamScreen(),
        '/construction_inventory': (context) => InventoryScreen(),
        '/chat': (context) => ChatScreen(),
        '/register': (context) => RegisterScreen(onRegister: () {  },),
      },
    );
  }
}
