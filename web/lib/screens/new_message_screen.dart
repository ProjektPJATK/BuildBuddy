import 'package:flutter/material.dart';
import 'package:web_app/config/config.dart';
import 'package:web_app/screens/chat_screen.dart';
import 'package:web_app/services/new_message_service.dart';
import 'package:web_app/themes/styles.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<String> selectedRecipients = [];
  bool isLoading = false;
  final NewMessageService _newMessageService = NewMessageService();
  late final int loggedInUserId;

  @override
  void initState() {
    super.initState();
    loggedInUserId = int.tryParse(
      (html.document.cookie?.split('; ') ?? [])
          .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
          .split('=')[1],
    ) ?? 0;
  }

  Future<void> _handleSendMessage() async {
  final text = _messageController.text.trim();
  if (selectedRecipients.isEmpty || text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dodaj odbiorców i wpisz wiadomość'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final recipientIds = await _newMessageService.getRecipientIds(loggedInUserId, selectedRecipients);
    final conversationId = await _newMessageService.findOrCreateConversation(loggedInUserId, recipientIds);
    final conversationData = await _newMessageService.getConversationData(conversationId);

    final String conversationName = _getConversationName(conversationData, loggedInUserId);
    final List<Map<String, dynamic>> participants =
        (conversationData['users'] as List<dynamic>?)
            ?.where((user) => user['id'] != loggedInUserId)
            .map((user) => Map<String, dynamic>.from(user))
            .toList() ?? [];
    final int? teamId = conversationData['teamId'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationName: conversationName,
          participants: participants,
          conversationId: conversationId,
          teamId: teamId,
          initialMessage: text, // Przekazanie wiadomości
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Błąd: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


 String _getConversationName(Map<String, dynamic> conversation, int? userIdFromCookie) {
    final participants = conversation['participants'] as List<dynamic>? ?? conversation['users'] as List<dynamic>? ?? [];
    final filteredParticipants = participants.where((participant) => participant['id'] != userIdFromCookie).toList();

    if (conversation['teamId'] != null) {
      return conversation['name'] ?? 'Unknown Group';
    }

    if (filteredParticipants.length == 1) {
      final otherUser = filteredParticipants.first;
      return '${otherUser['name']} ${otherUser['surname']}';
    }

    return 'Group Conversation';
  }

  void _selectRecipients() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipientSelectionScreen(newMessageService: _newMessageService, userId: loggedInUserId),
      ),
    );

    if (result != null && result is List<String>) {
      setState(() {
        selectedRecipients = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(144, 81, 85, 87),
        title: const Text(
          'New message',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          Container(
            child: Column(
              children: [
                _buildRecipientField(),
                _buildMessageField(),
                _buildSendButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientField() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        readOnly: true,
        onTap: _selectRecipients,
        decoration: InputDecoration(
          hintText: selectedRecipients.isEmpty
              ? 'Add recipients'
              : selectedRecipients.join(', '),
          hintStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: 150,
        child: TextField(
          controller: _messageController,
          maxLines: null,
          expands: true,
          decoration: InputDecoration(
            hintText: 'Write message... ',
            hintStyle: const TextStyle(color: Colors.black54),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleSendMessage,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        minimumSize: const Size(150, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Send message',
              style: TextStyle(color: Colors.white),
            ),
    );
  }
}

class RecipientSelectionScreen extends StatefulWidget {
  final NewMessageService newMessageService;
  final int userId;

  const RecipientSelectionScreen({required this.newMessageService, required this.userId, Key? key}) : super(key: key);

  @override
  _RecipientSelectionScreenState createState() => _RecipientSelectionScreenState();
}

class _RecipientSelectionScreenState extends State<RecipientSelectionScreen> {
  List<Map<String, dynamic>> _recipients = [];
  List<Map<String, dynamic>> _filteredRecipients = [];
  final List<Map<String, dynamic>> _selectedRecipients = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecipients();
    _searchController.addListener(_filterRecipients);
  }

  Future<void> _loadRecipients() async {
    final response = await widget.newMessageService.getRecipientIds(widget.userId, []);
    final List<Map<String, dynamic>> recipients = [];

    final teamResponse = await http.get(Uri.parse(AppConfig.getTeamsEndpoint(widget.userId)));
    if (teamResponse.statusCode == 200) {
      final List<dynamic> teams = json.decode(teamResponse.body);
      for (final team in teams) {
        final teamId = team['id'];
        final membersResponse = await http.get(Uri.parse(AppConfig.getTeammatesEndpoint(teamId)));
        if (membersResponse.statusCode == 200) {
          final List<dynamic> teammates = json.decode(membersResponse.body);
          for (final teammate in teammates) {
            if (teammate['id'] != widget.userId && !recipients.any((r) => r['id'] == teammate['id'])) {
              recipients.add(teammate);
            }
          }
        }
      }
    }

    setState(() {
      _recipients = recipients;
      _filteredRecipients = List.from(_recipients);
    });
  }

  void _filterRecipients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRecipients = _recipients
          .where((recipient) =>
              (recipient['name'] as String).toLowerCase().contains(query) ||
              (recipient['surname'] as String).toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(144, 81, 85, 87),
        title: const Text(
          'Wybierz odbiorców',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name and surname... ',
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: _filteredRecipients.map((recipient) {
                      final recipientName = '${recipient['name']} ${recipient['surname']}';
                      return Row(
                        children: [
                          Checkbox(
                            value: _selectedRecipients.contains(recipient),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true && !_selectedRecipients.contains(recipient)) {
                                  _selectedRecipients.add(recipient);
                                } else {
                                  _selectedRecipients.remove(recipient);
                                }
                              });
                            },
                          ),
                          Text(recipientName),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.pop(context, _selectedRecipients.map((r) => '${r['name']} ${r['surname']}').toList());
        },
        child: const Text(
          'Confirm',
          style: TextStyle(color: Colors.blue),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(300, 80),
          side: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}
