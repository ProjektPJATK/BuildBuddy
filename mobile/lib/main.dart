import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) =>  const SplashScreen(),
        '/home': (context) =>  HomeScreen(),
        '/chat': (context) => ChatScreen(),
         '/calendar': (context) =>  const CalendarScreen(), // Ekran kalendarza
         '/profile': (context) => UserProfileScreen(),
      },
    );
  }
}
