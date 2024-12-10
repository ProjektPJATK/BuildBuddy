import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/shared/widgets/bottom_navigation.dart';
import 'widgets/chat_item.dart';
import 'widgets/chat_search_bar.dart';


class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<String> chatNames = ['Marta Nowak', 'Jan Kowalski', 'Piotr Malinowski', 'Anna Wiśniewska'];
  List<String> filteredChatNames = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredChatNames = chatNames;
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
          Container(decoration: AppStyles.backgroundDecoration),
          Container(color: AppStyles.filterColor.withOpacity(0.75)),
          Column(
            children: [
              Expanded(
                child: Container(
                  color: AppStyles.transparentWhite,
                  child: Column(
                    children: [
                      ChatSearchBar(
                        searchController: searchController,
                        onSearch: _filterChats,
                        onAddPressed: () {
                          // Add new chat logic
                        },
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredChatNames.length,
                          itemBuilder: (context, index) {
                            return ChatItem(
                              name: filteredChatNames[index],
                              onTap: () {
                                // Navigate to specific chat
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BottomNavigation(onTap: (_) {}),
            ],
          ),
        ],
      ),
    );
  }
}
