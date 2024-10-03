import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart'; // Import the BottomNavigation widget
import '../app_state.dart' as appState;
import '../styles.dart';
import 'newMessage_screen.dart'; // Import your styles

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<String> chatNames = ['Marta Nowak', 'Jan Kowalski', 'Piotr Malinowski', 'Anna Wiśniewska'];
  List<String> filteredChatNames = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredChatNames = chatNames;
    appState.currentPage = 'chats'; // Set current page to 'chat'
  }

  // Filter chat list based on search query
  void _filterChats(String query) {
    final results = chatNames.where((name) => name.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      filteredChatNames = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          // Czarny filtr z przezroczystością 0.75
          Container(
            color: AppStyles.filterColor.withOpacity(0.75),
          ),
          // White semi-transparent filter over entire page using styles
          Container(
            color: AppStyles.transparentWhite, // Use transparentWhite from styles.dart
          ),
          // Main content of the page
          Column(
            children: [
              // Search and chat list container
              Expanded(
                child: Column(
                  children: [
                    // Search bar and add button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: _filterChats,
                              decoration: InputDecoration(
                                hintText: 'Szukaj po imieniu i nazwisku...',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9), // White background with opacity for the search bar
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: Colors.black),
                            onPressed: () {
                            Navigator.push(
                           context,
                                MaterialPageRoute(builder: (context) => NewMessageScreen()),
                             );
                            },
                          ),
                        ],
                      ),
                    ),
                    // List of chats
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        itemCount: filteredChatNames.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                             color: AppStyles.transparentWhite,
                              borderRadius: BorderRadius.circular(12.0), // Rounded corners for chat container
                            ),
                            child: ListTile(
                              title: Text(
                                filteredChatNames[index],
                                style: TextStyle(color: Colors.black),
                              ),
                              onTap: () {
                                // Navigate to the specific chat screen
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom navigation without additional white background
              BottomNavigation(
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushNamed(context, '/calendar'); // Calendar
                  } else if (index == 1) {
                    Navigator.pushNamed(context, '/chats'); // Chat
                  } else if (index == 2) {
                    Navigator.pushNamed(context, '/home'); // Home
                  } else if (index == 3) {
                    Navigator.pushNamed(context, '/profile'); // Profile
                  }
                },
                noBackground: true, // Ensure no additional background in bottom navigation
              ),
            ],
          ),
        ],
      ),
    );
  }
}
