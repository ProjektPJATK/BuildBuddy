import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';

class NewMessageService {
  Future<List<int>> getRecipientIds(int userId, List<String> recipientNames) async {
    List<int> recipientIds = [];

    final response = await http.get(Uri.parse(AppConfig.getTeamsEndpoint(userId)));

    if (response.statusCode == 200) {
      List<dynamic> teams = json.decode(response.body);

      for (var team in teams) {
        final teamId = team['id'];
        final membersResponse = await http.get(Uri.parse(AppConfig.getTeammatesEndpoint(teamId)));

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

  Future<int> findOrCreateConversation(int userId, List<int> recipientIds) async {
    final response = await http.get(Uri.parse(AppConfig.getChatListEndpoint(userId)));

    if (response.statusCode == 200) {
      List<dynamic> conversations = json.decode(response.body);

      for (var conversation in conversations) {
        List<dynamic> participants = conversation['users'];
        final participantIds = participants.map((p) => p['id']).where((id) => id != userId).toList();

        if (const ListEquality().equals(participantIds, recipientIds)) {
          return conversation['id'];
        }
      }
    }

    final uri = Uri.parse(
      '${AppConfig.createConversationEndpoint()}?user1Id=$userId&user2Id=${recipientIds.first}',
    );

    final createResponse = await http.post(uri);

    if (createResponse.statusCode == 200) {
      final newConversation = json.decode(createResponse.body);
      return newConversation['conversationId'];
    } else {
      throw Exception('Błąd tworzenia konwersacji');
    }
  }
}
