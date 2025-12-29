import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<void> saveMessage(ChatMessage message);
  Future<List<ChatMessage>> getHistory();
  Future<void> clearHistory();
}
