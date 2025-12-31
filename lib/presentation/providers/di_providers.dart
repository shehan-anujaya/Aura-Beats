import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection_container.dart';
import '../../domain/usecases/get_song_suggestions.dart';
import '../../domain/usecases/get_chat_history.dart';
import '../../domain/usecases/save_chat_message.dart';
import '../../domain/usecases/clear_chat_history.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/chat_repository.dart';

// Use Cases
final getSongSuggestionsProvider = Provider<GetSongSuggestions>((ref) {
  return sl<GetSongSuggestions>();
});

final getChatHistoryProvider = Provider<GetChatHistory>((ref) {
  return sl<GetChatHistory>();
});

final saveChatMessageProvider = Provider<SaveChatMessage>((ref) {
  return sl<SaveChatMessage>();
});

final clearChatHistoryProvider = Provider<ClearChatHistory>((ref) {
  return sl<ClearChatHistory>();
});

// Repositories (if still needed directly)
final aiRepositoryProvider = Provider<AIRepository>((ref) {
  return sl<AIRepository>();
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return sl<ChatRepository>();
});
