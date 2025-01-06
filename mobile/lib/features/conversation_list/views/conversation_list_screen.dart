import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/chat/bloc/chat_bloc.dart';
import 'package:mobile/features/new_message/new_message_screen.dart';
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
  _ConversationListScreenState createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allConversations = [];
  List<Map<String, dynamic>> filteredConversations = [];
  bool isLoading = true;
  String? errorMessage;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    context.read<ConversationBloc>().add(LoadConversationsFromCacheEvent());
    Future.delayed(const Duration(milliseconds: 500), () {
      context.read<ConversationBloc>().add(LoadConversationsEvent());
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
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
                          onAddPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final userId = prefs.getInt('userId');
                            if (userId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    final chatBloc =
                                        BlocProvider.of<ChatBloc>(context);
                                    return NewMessageScreen(chatBloc: chatBloc);
                                  },
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Błąd: Brak userId.')),
                              );
                            }
                          },
                        ),
                        Expanded(
                          child: BlocConsumer<ConversationBloc,
                              ConversationState>(
                            listener: (context, state) {
                              if (state is ConversationLoaded) {
                                allConversations = state.conversations;
                                filteredConversations = allConversations;
                                isLoading = false;
                              } else if (state is ConversationError) {
                                errorMessage = state.message;
                                isLoading = false;
                              } else if (state is ConversationLoading) {
                                isLoading = allConversations.isEmpty;
                              }
                              setState(() {});
                            },
                            builder: (context, state) {
                              if (isLoading && allConversations.isEmpty) {
                                return ListView.builder(
                                  itemCount: 10,
                                  itemBuilder: (context, index) {
                                    return _buildSkeletonLoader();
                                  },
                                );
                              }

                              if (allConversations.isNotEmpty) {
                                return ListView.builder(
                                  itemCount: filteredConversations.length,
                                  itemBuilder: (context, index) {
                                    final conversation =
                                        filteredConversations[index];
                                    final conversationId =
                                        conversation['id'] as int? ?? 0;

                                    // Lista użytkowników
                                    final List<dynamic> users =
                                        conversation['users'] ?? [];

                                    // Mapujemy na listę uczestników
                                    final List<Map<String, dynamic>> participants = users
                                        .map((user) => {
                                              'id': user['id'],
                                              'name':
                                                  '${user['name']} ${user['surname']}',
                                            })
                                        .toList();

                                  String conversationName = '';
                                  String participantsList = '';

                                  // Log przed rozpoczęciem operacji
                                  print('[ChatScreen] Lista uczestników: $participants');
                                  if (participants.length == 2) {
                                    // Jeśli są dwie osoby, wyświetl imię tej, która nie jest tobą
                                    final otherUser = participants
                                        .firstWhere((p) => p['id'] != userId, orElse: () => participants.first);
                                    conversationName = otherUser['name'];
                                    print('[ChatScreen] Czat z jedną osobą, wyświetlam imię: $conversationName');
                                  } else {
                                    // Jeśli są więcej niż 2 osoby, wyświetl "Konwersacja grupowa"
                                    conversationName = 'Konwersacja grupowa';
                                    participantsList = participants
                                        .where((p) => p['id'] != userId)  // Usuwamy siebie z listy
                                        .map((p) => p['name'])
                                        .join(', ');

                                    // Log do sprawdzenia listy uczestników
                                    print('[ChatScreen] Więcej niż dwóch uczestników, konwersacja grupowa');
                                    print('[ChatScreen] Lista uczestników (bez siebie): $participantsList');
                                  }

                                      return ConversationItem(
                                          name: conversationName,
                                          onTap: () async {
                                            final prefs = await SharedPreferences.getInstance();
                                            await prefs.setInt('conversationId', conversationId);

                                            Navigator.pushNamed(
                                              context,
                                              '/chat',
                                              arguments: {
                                                'conversationName': conversationName,
                                                'participants': participants,  // Przekazujemy listę uczestników
                                                'participantsList': participantsList, // Przekazujemy listę uczestników
                                              },
                                            );
                                          },
                                          participantsList: participantsList, // Dodajemy listę uczestników tutaj
                                        );
                                  },
                                );
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

                              return const Center(
                                  child: Text('Brak konwersacji.'));
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

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
