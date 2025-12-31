import '../../domain/repositories/chat_repository.dart';

class ClearChatHistory {
  final ChatRepository repository;

  ClearChatHistory(this.repository);

  Future<void> execute() async {
    await repository.clearHistory();
  }
}
