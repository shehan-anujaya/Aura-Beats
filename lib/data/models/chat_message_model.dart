import '../../domain/entities/chat_message.dart';
import 'song_suggestion_model.dart';
import '../../domain/entities/song_suggestion.dart';

class ChatMessageModel extends ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<SongSuggestion>? suggestions;

  ChatMessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
  }) : super(
          id: id,
          content: content,
          isUser: isUser,
          timestamp: timestamp,
          suggestions: suggestions,
        );

  factory ChatMessageModel.fromEntity(ChatMessage message) {
    return ChatMessageModel(
      id: message.id,
      content: message.content,
      isUser: message.isUser,
      timestamp: message.timestamp,
      suggestions: message.suggestions,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      suggestions: json['suggestions'] != null
          ? (json['suggestions'] as List)
              .map((s) => SongSuggestionModel.fromJson(s))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'suggestions': suggestions != null
          ? suggestions!
              .map((s) => SongSuggestionModel.fromEntity(s).toJson())
              .toList()
          : null,
    };
  }
}
