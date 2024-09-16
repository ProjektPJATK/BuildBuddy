import 'package:flutter/material.dart';

// Definicja klasy TaskItem
class TaskItem extends StatelessWidget {
  final String title;
  const TaskItem(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7), // Opcjonalnie: Zmniejszona przezroczystość
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.circle, size: 8, color: Colors.black),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
