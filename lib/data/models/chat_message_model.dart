import 'package:hive/hive.dart';
import '../../domain/entities/chat_message.dart';

part 'chat_message_model.g.dart';

@HiveType(typeId: 0)
class ChatMessageModel extends ChatMessage {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String content;
  @HiveField(2)
  final bool isUser;
  @HiveField(3)
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
