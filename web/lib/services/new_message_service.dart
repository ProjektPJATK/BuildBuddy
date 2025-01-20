import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:web_app/config/config.dart';

class NewMessageService {
  Future<List<int>> getRecipientIds(int userId, List<String> recipientNames) async {
    Set<int> recipientIds = {};
    print('[NewMessageService] Start fetching recipient IDs for userId: $userId');

    final response = await http.get(Uri.parse(AppConfig.getTeamsEndpoint(userId)));

    if (response.statusCode == 200) {
      List<dynamic> teams = json.decode(response.body);
      print('[NewMessageService] Teams fetched: $teams');

      for (var team in teams) {
        final teamId = team['id'];
        final membersResponse = await http.get(Uri.parse(AppConfig.getTeammatesEndpoint(teamId)));

        if (membersResponse.statusCode == 200) {
          List<dynamic> teammates = json.decode(membersResponse.body);
          print('[NewMessageService] Teammates fetched for teamId $teamId: $teammates');

          for (var mate in teammates) {
            String fullName = '${mate['name']} ${mate['surname']}';
            if (recipientNames.contains(fullName) && mate['id'] != userId) {
              recipientIds.add(mate['id']);
              print('[NewMessageService] Added recipient ID: ${mate['id']} for $fullName');
            }
          }
        }
      }
    } else {
      print('[NewMessageService] Error fetching teams: ${response.statusCode}, ${response.body}');
    }

    print('[NewMessageService] Final recipient IDs (unique): $recipientIds');
    return recipientIds.toList();
  }

  Future<Map<String, dynamic>> getConversationData(int conversationId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.getBaseUrl()}/api/Conversation/$conversationId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch conversation data: ${response.body}');
    }
  }

  Future<int> findOrCreateConversation(int userId, List<int> recipientIds) async {
    recipientIds = recipientIds.toSet().toList()..sort();
    print('[NewMessageService] Searching for conversation with recipient IDs: $recipientIds');

    final response = await http.get(Uri.parse(AppConfig.getChatListEndpoint(userId)));

    if (response.statusCode == 200) {
      List<dynamic> conversations = json.decode(response.body);

      for (var conversation in conversations) {
        List<dynamic> participants = conversation['users'];
        final participantIds = participants
            .map((p) => p['id'])
            .where((id) => id != userId)
            .toSet()
            .toList()
          ..sort();

        print('[NewMessageService] Comparing participant IDs: $participantIds with $recipientIds');
        if (const ListEquality().equals(participantIds, recipientIds)) {
          print('[NewMessageService] Found existing conversation: ${conversation['id']}');
          return conversation['id'];
        }
      }
    } else {
      print('[NewMessageService] Error fetching conversations: ${response.statusCode}, ${response.body}');
    }

    print('[NewMessageService] No existing conversation found. Creating a new one...');
    final uri = Uri.parse(
      '${AppConfig.createConversationEndpoint()}?user1Id=$userId&user2Id=${recipientIds.first}',
    );

    final createResponse = await http.post(uri);

    if (createResponse.statusCode == 200) {
      final newConversation = json.decode(createResponse.body);
      final conversationId = newConversation['conversationId'];
      print('[NewMessageService] Created new conversation: $conversationId');

      for (int i = 1; i < recipientIds.length; i++) {
        final addUserUri = Uri.parse(
          '${AppConfig.getBaseUrl()}/api/Conversation/$conversationId/addUser?userId=${recipientIds[i]}',
        );

        final addUserResponse = await http.post(addUserUri);

        if (addUserResponse.statusCode == 200) {
          print('[NewMessageService] Added user ${recipientIds[i]} to conversation $conversationId');
        } else if (addUserResponse.statusCode == 409) {
          print('[NewMessageService] User ${recipientIds[i]} already exists in conversation $conversationId');
        } else {
          print('[NewMessageService] Error adding user: ${addUserResponse.statusCode}');
        }
      }

      return conversationId;
    } else {
      throw Exception('[NewMessageService] Error creating conversation: ${createResponse.body}');
    }
  }
}
