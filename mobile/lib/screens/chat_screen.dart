import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with transparency
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay to darken the background slightly
          Container(
            color: Colors.black.withOpacity(0.75),
          ),
          // Main chat container with a white background and proper layout
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white.withOpacity(0.7),
              child: Column(
                children: [
                  // Back button at the top
                  AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Cofanie do poprzedniego ekranu
                      },
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        buildChatBubble(
                          message: 'Cześć. Jak idą dzisiaj prace?',
                          isSentByMe: true,
                          time: '9:50 AM',
                          sender: '',
                        ),
                        buildChatBubble(
                          message: 'Cześć. Wyślę zdjęcia niedługo.',
                          isSentByMe: false,
                          sender: 'MARTA',
                          time: '10:00 AM',
                        ),
                        buildChatBubble(
                          message: 'Ok. Czekam.',
                          isSentByMe: true,
                          time: '10:05 AM',
                          sender: '',
                        ),
                        buildChatBubble(
                          message: 'Skrzynka elektryczna będzie dzisiaj gotowa.',
                          isSentByMe: false,
                          sender: 'MARTA',
                          time: '10:35 AM',
                        ),
                      ],
                    ),
                  ),
                  // Message input field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    color: Colors.white.withOpacity(0.9),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () {},
                        ),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Napisz wiadomość...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build chat bubbles
  Widget buildChatBubble({
    required String message,
    required bool isSentByMe,
    required String sender,
    required String time,
  }) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isSentByMe)
            Text(
              sender,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
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
              style: TextStyle(
                color: isSentByMe ? Colors.black : Colors.white,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
