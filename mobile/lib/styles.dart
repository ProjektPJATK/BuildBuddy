// lib/styles.dart
import 'package:flutter/material.dart';

class AppStyles {
  // Tła
  static const BoxDecoration backgroundDecoration = BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/background.png'),
      fit: BoxFit.cover,
    ),
  );

  // Filtr z przezroczystością
  static const Color filterColor = Colors.black87;

  // Jasne tło z przezroczystością
  static const Color transparentWhite = Colors.white70;

  // Styl nagłówka
  static const TextStyle headerStyle = TextStyle(
    color: Color.fromARGB(255, 49, 49, 49),
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // Styl tekstu
  static const TextStyle textStyle = TextStyle(
    color: Colors.black,
    fontSize: 12,
  );
}
