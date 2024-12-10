import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;
  final String sender;
  final String time;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.sender,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isSentByMe)
            Text(
              sender,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSentByMe
                  ? Colors.white.withOpacity(0.8)
                  : Colors.grey[700]!.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message,
              style: TextStyle(color: isSentByMe ? Colors.black : Colors.white),
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
