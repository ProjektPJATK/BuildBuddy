import 'package:flutter/material.dart';
import 'screens/construction_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile.dart';

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
        '/': (context) =>  SplashScreen(),
        '/home': (context) =>  HomeScreen(),
        '/gdansk': (context) => ConstructionScreen(),
         '/calendar': (context) =>  CalendarScreen(), // Ekran kalendarza
         '/profile': (context) => UserProfileScreen(),
      },
    );
  }
}
