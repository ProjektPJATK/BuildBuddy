import 'package:flutter/material.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_field.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.75)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white.withOpacity(0.7),
              child: Column(
                children: [
                  AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(10),
                      children: const [
                        ChatBubble(
                          message: 'Cześć. Jak idą dzisiaj prace?',
                          isSentByMe: true,
                          sender: '',
                          time: '9:50 AM',
                        ),
                        ChatBubble(
                          message: 'Cześć. Wyślę zdjęcia niedługo.',
                          isSentByMe: false,
                          sender: 'MARTA',
                          time: '10:00 AM',
                        ),
                        ChatBubble(
                          message: 'Ok. Czekam.',
                          isSentByMe: true,
                          sender: '',
                          time: '10:05 AM',
                        ),
                        ChatBubble(
                          message: 'Skrzynka elektryczna będzie dzisiaj gotowa.',
                          isSentByMe: false,
                          sender: 'MARTA',
                          time: '10:35 AM',
                        ),
                      ],
                    ),
                  ),
                  ChatInputField(
                    controller: messageController,
                    onSendPressed: () {
                      // Handle send message
                      print('Send message: ${messageController.text}');
                      messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
