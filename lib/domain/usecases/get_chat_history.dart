import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class GetChatHistory {
  final ChatRepository repository;

  GetChatHistory(this.repository);

  Future<List<ChatMessage>> execute() async {
    return await repository.getHistory();
  }
}
