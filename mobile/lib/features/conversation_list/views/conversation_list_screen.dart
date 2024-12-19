import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';
import 'widgets/conversation_item.dart';
import 'widgets/conversation_search_bar.dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/shared/widgets/bottom_navigation.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  _ConversationListScreenState createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allConversations = [];
  List<Map<String, dynamic>> filteredConversations = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    context.read<ConversationBloc>().add(LoadConversationsFromCacheEvent());
    Future.delayed(const Duration(milliseconds: 300), () {
      context.read<ConversationBloc>().add(LoadConversationsEvent());
    });
  }

  void _filterConversations(String query) {
    final results = allConversations
        .where((conv) => conv['usersName']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    setState(() {
      filteredConversations = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Tło z obrazem
          Positioned.fill(
            child: Container(decoration: AppStyles.backgroundDecoration),
          ),
          Positioned.fill(
            child: Container(color: AppStyles.filterColor.withOpacity(0.75)),
          ),
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: AppStyles.transparentWhite,
                    child: Column(
                      children: [
                        ConversationSearchBar(
                          searchController: searchController,
                          onSearch: _filterConversations,
                          onAddPressed: () {
                            print("Add new conversation");
                          },
                        ),
                        Expanded(
                          child: BlocConsumer<ConversationBloc, ConversationState>(
                            listener: (context, state) {
                              if (state is ConversationLoaded) {
                                allConversations = state.conversations;
                                filteredConversations = allConversations;
                                isLoading = false;
                              } else if (state is ConversationError) {
                                errorMessage = state.message;
                                isLoading = false;
                              } else if (state is ConversationLoading) {
                                isLoading = true;
                              }
                              setState(() {});
                            },
                            builder: (context, state) {
                              if (isLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (errorMessage != null) {
                                return Center(
                                  child: Text(
                                    errorMessage!,
                                    style:
                                        const TextStyle(color: Colors.red),
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: filteredConversations.length,
                                itemBuilder: (context, index) {
                                  final conversation =
                                      filteredConversations[index];
                                  final conversationId =
                                      conversation['id'] as int? ?? 0;
                                  final conversationName =
                                      conversation['usersName'] ?? 'No name';

                                  return ConversationItem(
                                    name: conversationName,
                                    onTap: () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setInt('conversationId',
                                          conversationId);
                                      Navigator.pushNamed(
                                        context,
                                        '/chat',
                                        arguments: {
                                          'conversationName':
                                              conversationName
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                BottomNavigation(onTap: (index) {
                  print("Tapped index: $index");
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
