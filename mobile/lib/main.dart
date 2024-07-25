import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Tło
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'), // Dodaj obraz tła do folderu assets
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Filtr
          Container(
            color: Colors.black.withOpacity(0.9), // Możesz dostosować poziom przezroczystości
          ),
          // Logo na środku
          Center(
             child: SizedBox(
            width: 100, // Zmniejsz szerokość o połowę
              height: 100, // Zmniejsz wysokość o połowę
              child: Image.asset('assets/logo_small.png'), // Zmniejsz wysokość o połowę
               ),
          ),
        ],
      ),
    );
  }
}
