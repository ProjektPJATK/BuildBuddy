import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_field.dart';
import 'widgets/chat_header.dart'; // Importujemy ChatHeader
import 'package:mobile/shared/themes/styles.dart';

class ChatScreen extends StatefulWidget {
  final String conversationName;

  const ChatScreen({super.key, required this.conversationName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatBloc? _chatBloc;
  int? userId;

  @override
  void dispose() {
    _chatBloc?.chatHubService.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    _loadUserIdAndConversationId();
  }

  void _loadUserIdAndConversationId() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationId = prefs.getInt('conversationId') ?? 0;
    final userId = prefs.getInt('userId') ?? 0;

    setState(() {
      this.userId = userId;
    });

    if (conversationId != 0) {
      _chatBloc?.add(ConnectChatEvent(
        baseUrl: AppConfig.getChatUrl(),
        conversationId: conversationId,
         userId: userId,
      ));
    } else {
      print("[ChatScreen] No valid conversationId found in SharedPreferences");
    }
  }

  Future<void> _sendMessage() async {
  final text = messageController.text.trim();
  if (text.isNotEmpty) {
    final prefs = await SharedPreferences.getInstance();
    final senderId = prefs.getInt('userId') ?? 0;
    final conversationId = prefs.getInt('conversationId') ?? 0;

    _chatBloc?.add(SendMessageEvent(
      senderId: senderId,
      conversationId: conversationId,
      text: text,
    ));

    messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }
}


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final targetOffset = _scrollController.position.maxScrollExtent+400;
        if (_scrollController.offset != targetOffset) {
          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final formattedDate = date.day == now.day &&
            date.month == now.month &&
            date.year == now.year
        ? "Dzisiaj"
        : "${date.day}/${date.month}/${date.year}";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Text(
        formattedDate,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
              ChatHeader(
                conversationName: widget.conversationName,
                onBackPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/chats',  // Zmień na odpowiednią ścieżkę do listy konwersacji
                      (Route<dynamic> route) => false,  // Usunięcie wszystkich poprzednich ekranów
                    );
                  },
              ),
              Expanded(
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  child: BlocConsumer<ChatBloc, ChatState>(
                    listener: (context, state) {
                      if (state is ChatLoaded) {
                        _scrollToBottom();
                      }
                    },
                    builder: (context, state) {
                      if (state is ChatLoaded) {
                        final messages = state.messages;
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final previousMessage =
                                index > 0 ? messages[index - 1] : null;

                            // Sprawdzenie, czy dodać separator daty
                            final showDateSeparator = previousMessage == null ||
                                message.timestamp.toLocal().day !=
                                    previousMessage.timestamp.toLocal().day;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (showDateSeparator)
                                  _buildDateSeparator(
                                      message.timestamp.toLocal()),
                                ChatBubble(
                                  message: message.text,
                                  isSentByMe: message.senderId == userId,
                                  sender: message.senderId == userId
                                      ? ""
                                      : "User_${message.senderId}",
                                  time: message.timestamp
                                      .toLocal()
                                      .toString()
                                      .substring(11, 16),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
              ChatInputField(
                controller: messageController,
                onSendPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
