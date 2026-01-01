import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  }) : super(
          id: id,
          content: content,
          isUser: isUser,
          timestamp: timestamp,
        );

  factory ChatMessageModel.fromEntity(ChatMessage message) {
    return ChatMessageModel(
      id: message.id,
      content: message.content,
      isUser: message.isUser,
      timestamp: message.timestamp,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
