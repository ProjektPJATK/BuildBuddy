import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget {
  final String conversationName;
  final VoidCallback onBackPressed;

  const ChatHeader({
    super.key,
    required this.conversationName,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Kontener udający AppBar
        Container(
          color: Colors.white.withOpacity(0.7), // Tło podobne do AppBar
          padding: const EdgeInsets.only(left: 8, right: 8, top: 40, bottom: 10), // Dostosowanie do ekranu z notchem
          child: Row(
            children: [
              // Ikona strzałki wstecz
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: onBackPressed,
              ),
              // Tytuł konwersacji
              Expanded(
                child: Text(
                  conversationName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Divider poniżej
        const Divider(
          color: Colors.white,
          height: 1,
        ),
      ],
    );
  }
}
