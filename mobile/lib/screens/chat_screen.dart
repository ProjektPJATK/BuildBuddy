import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart'; // Import the BottomNavigation widget
import '../app_state.dart' as appState; // Import appState to manage the current page state

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set the current page to 'chat' when this screen is built
    appState.currentPage = 'chat';

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'), // Replace with your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent filter for the whole page
          Container(
            color: Colors.black.withOpacity(0.75), // Adjust the opacity to match your design
          ),
          // Main content area
          Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.transparent, // Ensure content background is consistent
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 100), // Add bottom padding for input field
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
              ),
              // Message input field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                color: Colors.white.withOpacity(0.9), // Adjust transparency for input field
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
        ],
      ),
      // Ensure bottom navigation has no background
      bottomNavigationBar: BottomNavigation(
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/calendar');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/chats');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        noBackground: true, // Always use true to keep the background transparent
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
                  : Colors.grey[700]!.withOpacity(0.8), // Set transparency for chat bubbles
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
