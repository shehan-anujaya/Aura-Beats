import '../../domain/entities/song_suggestion.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';

class GetSongSuggestions {
  final AIRepository repository;

  GetSongSuggestions(this.repository);

  Future<List<SongSuggestion>> execute(String userMood, List<ChatMessage> history) async {
    return await repository.getSongSuggestions(userMood, history);
  }
}
