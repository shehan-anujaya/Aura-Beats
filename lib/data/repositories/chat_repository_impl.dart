import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/chat_message.dart';
import '../datasources/local_storage_service.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final LocalStorageService _localStorageService;

  ChatRepositoryImpl(this._localStorageService);

  @override
  Future<void> saveMessage(ChatMessage message) async {
    // If we're saving a single message, we might need to fetch existing, append, and save all?
    // Or LocalStorageService should handle append. 
    // Current LocalStorageService implementations saves a LIST.
    // So we fetch, append, save. OR we change LocalStorageService to save one.
    // Let's modify logic here to be safe: fetch, add, save.
    
    final currentHistory = _localStorageService.getChatHistory();
    // Convert to model
    final messageModel = ChatMessageModel.fromEntity(message);
    
    currentHistory.add(messageModel);
    await _localStorageService.saveChatHistory(currentHistory);
  }

  @override
  Future<List<ChatMessage>> getHistory() async {
    return _localStorageService.getChatHistory();
  }

  @override
  Future<void> clearHistory() async {
    await _localStorageService.clearHistory();
  }
}
