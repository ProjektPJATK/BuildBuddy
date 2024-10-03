import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart'; // Import the BottomNavigation widget
import '../app_state.dart' as appState;
import '../styles.dart';

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
    appState.currentPage = 'chats'; // Set current page to 'chats'
  }

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
          // Main screen content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Expanded(
                  flex: 8, // Adjusted to fit content properly
                  child: Container(
                    color: AppStyles.transparentWhite, // White translucent background for chat list
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
                                    fillColor: Colors.white.withOpacity(0.9),
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
                                  // Add functionality here
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
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12.0),
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
                ),
                // Bottom Navigation in its own container
                BottomNavigation(
                  onTap: (_) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
