import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/conversation_list/bloc/conversation_bloc.dart';
import 'package:mobile/features/conversation_list/bloc/conversation_event.dart';
import 'package:mobile/features/conversation_list/bloc/conversation_state.dart';
import 'package:mobile/features/conversation_list/views/widgets/conversation_item.dart';
import 'package:mobile/features/conversation_list/views/widgets/conversation_search_bar.dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/shared/widgets/bottom_navigation.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  _ConversationListScreenState createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final TextEditingController searchController = TextEditingController();

  List<String> allConversations = [];
  List<String> filteredConversations = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    context.read<ConversationBloc>().add(LoadConversationsEvent());
  }

  void _filterConversations(String query) {
    final results = allConversations
        .where((conv) => conv.toLowerCase().contains(query.toLowerCase()))
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
          Positioned.fill(
            child: Container(decoration: AppStyles.backgroundDecoration),
          ),
          Positioned.fill(
            child: Container(color: AppStyles.filterColor.withOpacity(0.75)),
          ),
          Column(
            children: [
              Expanded(
                child: Container(
                  color: AppStyles.transparentWhite,
                  child: Column(
                    children: [
                      ChatSearchBar(
                        searchController: searchController,
                        onSearch: _filterConversations,
                        onAddPressed: () {
                          // Dodawanie nowej konwersacji
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
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (errorMessage != null) {
                              return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)));
                            }
                            return ListView.builder(
                              itemCount: filteredConversations.length,
                              itemBuilder: (context, index) {
                                return ChatItem(
                                  name: filteredConversations[index],
                                  onTap: () {
                                    // Nawigacja do szczegółów konwersacji
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
              // BottomNavigation
              BottomNavigation(onTap: (index) {
                // obsługa bottom navigation
              }),
            ],
          ),
        ],
      ),
    );
  }
}
