import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web/screens/chat_screen.dart';
import 'package:web/services/conversations_service.dart';
import 'package:universal_html/html.dart' as html;

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final ConversationsService _service = ConversationsService();
  List<Map<String, dynamic>> conversations = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredConversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _service.fetchConversations();
      setState(() {
        conversations = data;
        filteredConversations = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String _getConversationName(Map<String, dynamic> conversation, int? userIdFromCookie) {
    // Pobieramy participants lub users, jeśli participants nie istnieje
    final participants = conversation['participants'] as List<dynamic>? ?? conversation['users'] as List<dynamic>? ?? [];
    print('[ConversationsScreen] Original Participants: $participants');

    // Filtrujemy, aby usunąć zalogowanego użytkownika
    final filteredParticipants = participants.where((participant) => participant['id'] != userIdFromCookie).toList();
    print('[ConversationsScreen] Filtered Participants: $filteredParticipants');

    // Jeśli teamId nie jest nullem, użyj nazwy konwersacji
    if (conversation['teamId'] != null) {
      final name = conversation['name'] ?? 'Unknown Group';
      print('[ConversationsScreen] Group conversation with teamId, name: $name');
      return name;
    }

    // Jeśli tylko dwie osoby, ustawiamy nazwę drugiej osoby
    if (filteredParticipants.length == 1) {
      final otherUser = filteredParticipants.first;
      final name = '${otherUser['name']} ${otherUser['surname']}';
      print('[ConversationsScreen] Two participants, name: $name');
      return name;
    }

    // Jeśli to konwersacja grupowa bez teamId
    print('[ConversationsScreen] Group conversation without teamId');
    return 'Konwersacja grupowa';
  }

  void _filterConversations(String query) {
    final userId = int.tryParse(
        (html.document.cookie?.split('; ') ?? [])
            .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
            .split('=')[1]);

    setState(() {
      filteredConversations = conversations.where((conversation) {
        final conversationName = _getConversationName(conversation, userId).toLowerCase();
        return conversationName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = int.tryParse(
        (html.document.cookie?.split('; ') ?? [])
            .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
            .split('=')[1]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations, // Wywołanie odświeżania
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    'Error: $errorMessage',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _ConversationSearchBar(
                        searchController: _searchController,
                        onSearch: _filterConversations,
                        onAddPressed: () {
                          print('Navigate to new conversation screen');
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredConversations.length,
                        itemBuilder: (context, index) {
                          final conversation = filteredConversations[index];

                          // Jeśli teamId nie jest nullem, użyj nazwy konwersacji
                          final conversationName = _getConversationName(conversation, userId);

                          final participants = (conversation['participants'] as List<dynamic>? ?? conversation['users'])
                              .where((participant) => participant['id'] != userId) // Usunięcie zalogowanego użytkownika
                              .toList();

                          // Lista uczestników tylko dla konwersacji grupowych (teamId == null lub więcej niż 2 osoby)
                          final participantNames =
                              (conversation['teamId'] == null && participants.length > 1) ||
                                      (conversation['teamId'] != null && participants.length > 0)
                                  ? participants
                                      .map((participant) => '${participant['name']} ${participant['surname']}')
                                      .join(', ')
                                  : '';

                          return _ConversationItem(
                            name: conversationName,
                            participantsList: participantNames,
                            onTap: () {
                                final conversationId = conversation['id'];

                                // Upewnienie się, że participants ma odpowiedni typ
                                final participants = (conversation['participants'] as List<dynamic>? ?? conversation['users'] as List<dynamic>? ?? [])
                                    .where((participant) => participant['id'] != userId) // Usunięcie zalogowanego użytkownika
                                    .map((participant) => Map<String, dynamic>.from(participant)) // Konwersja do Map<String, dynamic>
                                    .toList();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      conversationName: conversationName,
                                      participants: participants, // Przekazanie listy z prawidłowym typem
                                      conversationId: conversationId,
                                    ),
                                  ),
                                );
                              },

                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _ConversationItem extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final String participantsList;

  const _ConversationItem({
    required this.name,
    required this.onTap,
    required this.participantsList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(color: Colors.black),
        ),
        subtitle: participantsList.isNotEmpty
            ? Text(
                participantsList,
                style: const TextStyle(color: Colors.black54),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _ConversationSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback onAddPressed;

  const _ConversationSearchBar({
    required this.searchController,
    required this.onSearch,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Szukaj po nazwie...',
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add, color: Colors.blue),
            label: const Text('Nowa wiadomość', style: TextStyle(color: Colors.blue)),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
