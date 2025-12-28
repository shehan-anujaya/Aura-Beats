import '../entities/chat_message.dart';
import '../entities/song_suggestion.dart';

abstract class AIRepository {
  /// Sends a user message to the AI and gets a response.
  /// The response might be a simple chat reply or a structured list of songs.
  Future<List<SongSuggestion>> getSongSuggestions(String userMood, List<ChatMessage> history);

  /// Analyze the mood string to get a simplified "Vibe" tag if needed.
  Future<String> analyzeMood(String input);
}
