import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:web_app/services/chat_hub_service.dart';
import 'package:universal_html/html.dart' as html;

class ChatScreen extends StatefulWidget {
  final String conversationName;
  final List<Map<String, dynamic>> participants;
  final int conversationId;
  final int? teamId; // Opcjonalne teamId dla sprawdzania typu konwersacji

  const ChatScreen({
    Key? key,
    required this.conversationName,
    required this.participants,
    required this.conversationId,
    this.teamId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatHubService _chatHubService = ChatHubService();
  List<Map<String, dynamic>> messages = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    _connectToChat().then((_) {
      _fetchHistory();
    });
  }

  @override
  void dispose() {
    _chatHubService.disconnect();
    super.dispose();
  }

  Future<void> _connectToChat() async {
    userId = int.tryParse(
      (html.document.cookie?.split('; ') ?? [])
          .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
          .split('=')[1],
    );

    if (userId != null) {
      await _chatHubService.connect(
        baseUrl: "http://127.0.0.1:5088",
        conversationId: widget.conversationId,
        userId: userId!,
        onMessageReceived: _onMessageReceived,
        onHistoryReceived: _onHistoryReceived,
      );
    }
  }

  void _onMessageReceived(Map<String, dynamic> message) {
    if (message.containsKey('text') &&
        message.containsKey('senderId') &&
        message.containsKey('dateTimeDate')) {
      setState(() {
        messages.add(message);
      });
      _scrollToBottom();
    }
  }

  Future<void> _fetchHistory() async {
    if (userId != null) {
      try {
        await _chatHubService.fetchHistory(widget.conversationId, userId!);
      } catch (e) {
        print("[ChatScreen] Error during FetchHistory: $e");
      }
    }
  }

  void _onHistoryReceived(List<Map<String, dynamic>> history) {
    setState(() {
      messages = history;
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && userId != null) {
      await _chatHubService.sendMessage(userId!, widget.conversationId, text);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 400,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showParticipantsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Uczestnicy konwersacji"),
          content: SingleChildScrollView(
            child: ListBody(
              children: widget.participants
                  .map((participant) => Text(
                        "${participant['name']} ${participant['surname']}",
                        style: const TextStyle(fontSize: 16),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Zamknij"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    String? formattedDate;

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.subtract(const Duration(days: 1)).day) {
      formattedDate = "Wczoraj";
    } else if (date.year != now.year || date.month != now.month || date.day != now.day) {
      formattedDate = "${date.day}/${date.month}/${date.year}";
    }

    if (formattedDate == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastMessageDate;

    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
             onTap: () {
    final isTeamChat = widget.teamId != null; // Sprawdzanie, czy teamId nie jest null
    final isGroupChat = widget.participants.length > 1; // Sprawdzanie, czy to czat grupowy

    print("[ChatScreen] Checking chat type...");
    print("[ChatScreen] teamId: ${widget.teamId}");
    print("[ChatScreen] participants count: ${widget.participants.length}");

    if (isTeamChat || isGroupChat) {
      print("[ChatScreen] Showing participants dialog.");
      _showParticipantsDialog();
    } else {
      print("[ChatScreen] This is not a group chat or a team chat.");
    }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.conversationName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isSentByMe = message['senderId'] == userId;
                final timestampString = message['dateTimeDate'];

                final messageDate = timestampString != null
                    ? DateTime.tryParse(timestampString)?.toLocal() ?? DateTime.now()
                    : DateTime.now();

                final bool isLastMessageOfDay = index == messages.length - 1 ||
                    (index < messages.length - 1 &&
                        DateTime.tryParse(messages[index + 1]['dateTimeDate'])
                                ?.toLocal()
                                .day !=
                            messageDate.day);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: IntrinsicWidth(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSentByMe ? Colors.grey[300] : Colors.lightBlue[100],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft:
                                  isSentByMe ? const Radius.circular(12) : Radius.zero,
                              bottomRight:
                                  isSentByMe ? Radius.zero : const Radius.circular(12),
                            ),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          child: Column(
                            crossAxisAlignment: isSentByMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (!isSentByMe)
                                Text(
                                  "${widget.participants.firstWhere(
                                    (p) => p['id'] == message['senderId'],
                                    orElse: () => {'name': 'Unknown', 'surname': ''},
                                  )['name'] ?? 'Unknown'} ${widget.participants.firstWhere(
                                    (p) => p['id'] == message['senderId'],
                                    orElse: () => {'name': '', 'surname': ''},
                                  )['surname'] ?? ''}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              Text(
                                message['text'] ?? '',
                                textAlign:
                                    isSentByMe ? TextAlign.right : TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    messageDate.toString().substring(11, 16),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (isLastMessageOfDay) _buildDateSeparator(messageDate),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Napisz wiadomość...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
