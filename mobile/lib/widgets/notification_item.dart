import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final String title;

  const NotificationItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center, // Wyśrodkowanie elementu
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85, // Szerokość 85% szerokości ekranu
        margin: const EdgeInsets.symmetric(vertical: 4.0), // Zmniejszenie przerwy między powiadomieniami
        padding: const EdgeInsets.all(6.0), // Zmniejszony padding
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7), // Tło dla powiadomień
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4.0)], // Opcjonalny cień
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero, // Usunięcie domyślnego paddingu ListTile
          title: Text(
            title,
            style: const TextStyle(fontSize: 12), // Zmniejszona czcionka
          ),
        ),
      ),
    );
  }
}
