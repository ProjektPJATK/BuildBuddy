import 'package:flutter/material.dart';
import 'screens/construction_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/gdansk': (context) => ConstructionScreen(),
         '/calendar': (context) => CalendarScreen(), // Ekran kalendarza
      },
    );
  }
}
