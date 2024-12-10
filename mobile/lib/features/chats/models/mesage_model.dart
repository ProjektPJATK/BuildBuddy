class MessageModel {
  final String id;
  final String chatId;
  final String sender;
  final String content;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      chatId: json['chatId'],
      sender: json['sender'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
