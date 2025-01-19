import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web/services/chat_hub_service.dart';
import 'package:universal_html/html.dart' as html;

class ChatScreen extends StatefulWidget {
  final String conversationName;
  final List<Map<String, dynamic>> participants;
  final int conversationId;

  const ChatScreen({
    Key? key,
    required this.conversationName,
    required this.participants,
    required this.conversationId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatHubService _chatHubService = ChatHubService();
  int? userId;
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _connectToChat();
  }

  @override
  void dispose() {
    _chatHubService.disconnect();
    super.dispose();
  }

  Future<void> _connectToChat() async {
    final userIdFromCookie = int.tryParse(
        (html.document.cookie?.split('; ') ?? [])
            .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
            .split('=')[1]);

    setState(() {
      userId = userIdFromCookie;
    });

    if (userId != null && userId != 0) {
      await _chatHubService.connect(
        baseUrl: "ws://127.0.0.1:5088",
        conversationId: widget.conversationId,
        userId: userId!,
        onMessageReceived: _onMessageReceived,
        onHistoryReceived: _onHistoryReceived,
      );
    }
  }

  void _onMessageReceived(Map<String, dynamic> message) {
    setState(() {
      messages.add(message);
    });
    _scrollToBottom();
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
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversationName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isSentByMe = message['senderId'] == userId;
                return ListTile(
                  title: Text(message['text'] ?? ''),
                  subtitle: Text(isSentByMe ? "You" : "Other"),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: "Type a message..."),
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
