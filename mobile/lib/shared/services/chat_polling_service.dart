import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatPollingService {
  late Timer _timer;
  final int pollingInterval = 1; // Interwał w sekundach
  bool _isPolling = false;

  // Start pollingu dla nowych wiadomości
  Future<void> startPolling() async {
    if (_isPolling) {
      //print("[ChatPollingService] Polling is already active. Skipping start.");
      return;
    }

    _isPolling = true;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    if (userId == 0) {
      //print("[ChatPollingService] User not logged in, stopping polling.");
      return;
    }
    //print("[ChatPollingService] Starting polling for userId: $userId");

    _timer = Timer.periodic(Duration(seconds: pollingInterval), (timer) async {
     // print("[ChatPollingService] Polling for new messages...");

      final chatListUrl = AppConfig.getChatListEndpoint(userId);
     // print("[ChatPollingService] Fetching chat list from: $chatListUrl");

      try {
        final response = await http.get(Uri.parse(chatListUrl));

        if (response.statusCode == 200) {
          final List<dynamic> conversations = json.decode(response.body);
         // print("[ChatPollingService] Fetched ${conversations.length} conversations");

          for (var conversation in conversations) {
            final conversationId = conversation['id'];
            //print("[ChatPollingService] Checking unread count for conversationId: $conversationId");

            final unreadCountUrl = AppConfig.unreadCountEndpoint(conversationId, userId);
            //print("[ChatPollingService] Fetching unread count from: $unreadCountUrl");

            final unreadResponse = await http.get(Uri.parse(unreadCountUrl));

            if (unreadResponse.statusCode == 200) {
              final unreadData = json.decode(unreadResponse.body);
              //print("[ChatPollingService] Unread count data for conversationId $conversationId: $unreadData");

              if (unreadData.containsKey('time')) {
                final lastMessageTime = DateTime.parse(unreadData['time']);
                final currentTime = DateTime.now();

                // Save the latest message time in SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('lastMessageTime_$conversationId', lastMessageTime.toIso8601String());

                // If the message is recent, consider it as new
                if (lastMessageTime.isAfter(currentTime.subtract(Duration(minutes: 5)))) {
                //  print("[ChatPollingService] New messages detected in conversationId: $conversationId");
                } else {
                  //print("[ChatPollingService] No new messages in conversationId: $conversationId");
                }
              } else {
              //  print("[ChatPollingService] No 'time' field in unread count response for conversationId: $conversationId");
              }
            } else {
              //print("[ChatPollingService] Error fetching unread count for conversationId: $conversationId. Status code: ${unreadResponse.statusCode}");
            }
          }
        } else {
         // print("[ChatPollingService] Error fetching conversation list. Status code: ${response.statusCode}");
        }
      } catch (e) {
        //print("[ChatPollingService] Error occurred during polling: $e");
      }
    });
  }

  // Stop pollingu
  void stopPolling() {
    if (_isPolling) {
      _timer.cancel();
      _isPolling = false;
     // print("[ChatPollingService] Stopped polling.");
    } else {
     // print("[ChatPollingService] Polling was not active.");
    }
  }
}
