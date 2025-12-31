import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class SaveChatMessage {
  final ChatRepository repository;

  SaveChatMessage(this.repository);

  Future<void> execute(ChatMessage message) async {
    await repository.saveMessage(message);
  }
}
