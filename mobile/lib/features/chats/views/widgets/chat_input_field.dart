import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      color: Colors.white.withOpacity(0.9),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              // Add photo functionality
            },
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Napisz wiadomość...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onSendPressed,
          ),
        ],
      ),
    );
  }
}
