import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/chat/views/widgets/chat_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_field.dart';
import 'package:mobile/shared/themes/styles.dart';

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child; // Usuwamy systemowy efekt glow
  }
}

class ChatScreen extends StatefulWidget {
  final String conversationName;

  const ChatScreen({super.key, required this.conversationName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    context.read<ChatBloc>().add(ConnectChatEvent());
  }

  void _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId') ?? 0;
    });
  }

  void _sendMessage() {
    final text = messageController.text.trim();
    if (text.isNotEmpty && userId != null) {
      context.read<ChatBloc>().add(SendMessageEvent(text));
      messageController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
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
      body: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: Stack(
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
                  onBackPressed: () => Navigator.pop(context),
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
                              return ChatBubble(
                                message: message.text,
                                isSentByMe: message.senderId == userId,
                                sender: message.senderId == userId ? "" : "User_${message.senderId}",
                                time: message.timestamp
                                    .toLocal()
                                    .toString()
                                    .substring(11, 16),
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
      ),
    );
  }
}