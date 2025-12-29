import '../../domain/repositories/ai_repository.dart';
import '../../domain/entities/song_suggestion.dart';
import '../../domain/entities/chat_message.dart';
import '../datasources/remote/ollama_service.dart';

class AIRepositoryImpl implements AIRepository {
  final OllamaService _ollamaService;

  AIRepositoryImpl(this._ollamaService);

  @override
  Future<List<SongSuggestion>> getSongSuggestions(String userMood, List<ChatMessage> history) async {
    // Convert domain entities to Maps for the service
    final historyMaps = history.map((e) => {
      'role': e.isUser ? 'user' : 'assistant', // Assuming AI messages are saved too with isUser=false
      'content': e.content,
    }).toList();

    return await _ollamaService.generateSongSuggestions(
      prompt: userMood,
      history: historyMaps,
    );
  }

  @override
  Future<String> analyzeMood(String input) async {
    return await _ollamaService.analyzeMood(input);
  }
}
