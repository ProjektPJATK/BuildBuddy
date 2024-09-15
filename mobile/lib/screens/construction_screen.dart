import 'package:flutter/material.dart';
import '../widgets/notification_item.dart';

class ConstructionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with transparency
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'), // Replace with your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay to darken the background slightly
          Container(
            color: Colors.black.withOpacity(0.75), // Adjust transparency here
          ),
          Align(
            alignment: Alignment.topCenter, // Wyśrodkowanie logo
            child: Padding(
              padding: const EdgeInsets.only(top: 30), // Margines od góry
              child: SizedBox(
                width: 45, // Zmniejszone wymiary logo
                height: 45,
                child: Image.asset('assets/logo_small.png'),
              ),
            ),
          ),
          // White semi-transparent background for the chat section
          Container(
            margin: const EdgeInsets.only(top: 120), // Start chat background below the logo
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7), // Set transparency for chat background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
          ),
          Column(
            children: [
              // Logo at the top of the screen
              Padding(
                padding: const EdgeInsets.only(top: 40), // Top padding for safe area
                child: Center(
                  child: SizedBox(
                    width: 80,
                    height: 80,
          
                  ),
                ),
              ),
              SizedBox(height: 20), // Spacer between logo and chat section
              // Chat section
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
                      sender: 'ANDRZEJ',
                      time: '10:35 AM',
                    ),
                  ],
                ),
              ),
              // Message input field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                color: Colors.white.withOpacity(0.9), // Slightly transparent input field background
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Napisz wiadomość...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
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
