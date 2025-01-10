import 'package:flutter/material.dart';
import 'package:mobile/features/chat/bloc/chat_bloc.dart';
import 'package:mobile/features/chat/bloc/chat_event.dart';
import 'package:mobile/features/new_message/recipent_selection_screen.dart';
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../shared/themes/styles.dart';
import 'package:collection/collection.dart';

class NewMessageScreen extends StatefulWidget {
  final ChatBloc chatBloc;

  const NewMessageScreen({required this.chatBloc, super.key});

  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  List<String> selectedRecipients = [];
  TextEditingController messageController = TextEditingController();
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId') ?? 0;
    });
    print('Załadowano userId: $userId');
  }
Future<List<Map<String, dynamic>>> _getParticipantsWithIds(List<String> recipientNames) async {
  List<Map<String, dynamic>> participants = [];
  
  final teamsResponse = await http.get(
    Uri.parse(AppConfig.getTeamsEndpoint(userId!)),
  );

  if (teamsResponse.statusCode == 200) {
    List<dynamic> teams = json.decode(teamsResponse.body);
    for (var team in teams) {
      final teamId = team['id'];
      final membersResponse = await http.get(
        Uri.parse(AppConfig.getTeammatesEndpoint(teamId)),
      );

      if (membersResponse.statusCode == 200) {
        List<dynamic> teammates = json.decode(membersResponse.body);
        for (var mate in teammates) {
          String fullName = '${mate['name']} ${mate['surname']}';
          if (recipientNames.contains(fullName) && mate['id'] != userId) {
            participants.add({
              'id': mate['id'],  // Correctly adding the participant ID
              'name': fullName,
            });
          }
        }
      }
    }
  }
  return participants;
}

  Future<void> _handleSendMessage() async {
  if (selectedRecipients.isEmpty || messageController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dodaj odbiorców i wpisz wiadomość'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    final recipientIds = await _getRecipientIds(selectedRecipients); // Fetch actual recipient IDs
    print('Recipient IDs: $recipientIds');

    final conversationId = await _findOrCreateConversation(recipientIds);
    print('Używana konwersacja: $conversationId');

    widget.chatBloc.add(SendMessageEvent(
      senderId: userId!,
      conversationId: conversationId,
      text: messageController.text,
    ));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('conversationId', conversationId);

    // Preparing conversation name and participants with actual IDs
    String conversationName = '';
    List<Map<String, dynamic>> participants = [];

    if (selectedRecipients.length == 1) {
      // Czatujemy tylko z jednym użytkownikiem
      conversationName = selectedRecipients[0];
      participants = await _getParticipantsWithIds(selectedRecipients);
    } else {
      // Czat grupowy
      conversationName = 'Konwersacja grupowa';
      participants = await _getParticipantsWithIds(selectedRecipients); // Fetch participant IDs
    }

    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'conversationId': conversationId,
        'conversationName': conversationName,
        'participants': participants,
      },
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Błąd podczas wysyłania wiadomości'),
        backgroundColor: Colors.red,
      ),
    );
    print('Błąd wysyłania wiadomości: $e');
  }
}


  Future<List<int>> _getRecipientIds(List<String> recipientNames) async {
    List<int> recipientIds = [];

    final teamsResponse = await http.get(
      Uri.parse(AppConfig.getTeamsEndpoint(userId!)),
    );

    if (teamsResponse.statusCode == 200) {
      List<dynamic> teams = json.decode(teamsResponse.body);
      print('Response from getTeamsEndpoint: $teams');

      for (var team in teams) {
        final teamId = team['id'];
        final membersResponse = await http.get(
          Uri.parse(AppConfig.getTeammatesEndpoint(teamId)),
        );

        if (membersResponse.statusCode == 200) {
          List<dynamic> teammates = json.decode(membersResponse.body);
          for (var mate in teammates) {
            String fullName = '${mate['name']} ${mate['surname']}';
            if (recipientNames.contains(fullName) && mate['id'] != userId) {
              recipientIds.add(mate['id']);
            }
          }
        }
      }
    }
    return recipientIds;
  }

 Future<int> _findOrCreateConversation(List<int> recipientIds) async {
  final response = await http.get(
    Uri.parse(AppConfig.getChatListEndpoint(userId!)),
  );

  if (response.statusCode == 200) {
    List<dynamic> conversations = json.decode(response.body);

    for (var conversation in conversations) {
      List<dynamic> participants = conversation['users'];
      final participantIds = participants
          .map((p) => p['id'])
          .where((id) => id != userId)
          .toList();

      print('Participant IDs (bez userId): $participantIds');
      print('Recipient IDs: $recipientIds');

      if (const ListEquality().equals(participantIds, recipientIds)) {
        print('Znaleziono istniejącą konwersację: ${conversation['id']}');
        return conversation['id'];
      }
    }
  } else {
    print('Błąd pobierania listy konwersacji: ${response.statusCode}');
    throw Exception('Błąd pobierania listy konwersacji');
  }

  print('Nie znaleziono istniejącej konwersacji. Tworzenie nowej...');

  // Tworzymy konwersację z pierwszym odbiorcą
  final uri = Uri.parse(
    '${AppConfig.getBaseUrl()}/api/Conversation/create?user1Id=$userId&user2Id=${recipientIds.first}',
  );

  print('Wysyłanie żądania POST do: $uri');

  final createResponse = await http.post(uri);

  print('Response code: ${createResponse.statusCode}');
  print('Response body: ${createResponse.body}');

  if (createResponse.statusCode == 200) {
    final newConversation = json.decode(createResponse.body);
    final conversationId = newConversation['conversationId'];
    print('Nowa konwersacja utworzona: $conversationId');

    // Dodajemy pozostałych użytkowników do konwersacji
    for (int i = 1; i < recipientIds.length; i++) {
      final addUserUri = Uri.parse(
        '${AppConfig.getBaseUrl()}/api/Conversation/$conversationId/addUser?userId=${recipientIds[i]}',
      );

      print('Dodawanie użytkownika ${recipientIds[i]} do konwersacji $conversationId');
      final addUserResponse = await http.post(addUserUri);

      if (addUserResponse.statusCode == 200) {
        print('Dodano użytkownika ${recipientIds[i]} do konwersacji');
      } else {
        print('Błąd podczas dodawania użytkownika: ${addUserResponse.statusCode}');
      }
    }

    return conversationId;
  } else {
    print(
        'Błąd podczas tworzenia nowej konwersacji: ${createResponse.statusCode} - ${createResponse.body}');
    throw Exception('Błąd tworzenia konwersacji');
  }
}



  Future<void> _addUserToConversation(int conversationId, int userId) async {
    final uri = Uri.parse(
      '${AppConfig.getBaseUrl()}/api/Conversation/$conversationId/addUser?userId=$userId',
    );

    final response = await http.post(uri);
    if (response.statusCode == 200) {
      print('Użytkownik $userId dodany do konwersacji $conversationId');
    } else {
      throw Exception('Nie udało się dodać użytkownika do konwersacji');
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Container(decoration: AppStyles.backgroundDecoration),
        Container(color: AppStyles.filterColor.withOpacity(0.75)),
        Container(color: AppStyles.transparentWhite),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 12),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/chats');
                  },
                ),
              ),
            ),
            _buildRecipientField(),
            _buildMessageField(),
            _buildSendButton(),
          ],
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
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipientSelectionScreen(
              selectedRecipients,
              userId: userId!,
            ),
          ),
        );
        if (result != null) {
          setState(() {
            selectedRecipients = result;
          });
        }
      },
      decoration: InputDecoration(
        hintText: selectedRecipients.isEmpty
            ? 'Dodaj odbiorców'
            : selectedRecipients.join(', '),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),  // Białe tło
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),  // Zaokrąglenie rogów
          borderSide: BorderSide.none,  // Brak ramki
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 20.0,
        ),
        prefixIcon: const Icon(Icons.person_add, color: Colors.black54),  // Ikona osoby
      ),
    ),
  );
}


 Widget _buildMessageField() {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,  // 25% wysokości ekranu
      child: TextField(
        controller: messageController,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          hintText: 'Wpisz wiadomość...',
          filled: true,
          fillColor: Colors.white,  // Białe tło
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),  // Zaokrąglenie rogów
            borderSide: BorderSide.none,  // Brak ramki
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
        ),
        style: const TextStyle(color: Colors.black),  // Czarny tekst
      ),
    ),
  );
}

  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: _handleSendMessage,
      child: const Text('Wyślij'),
    );
  }
}