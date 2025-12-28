import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/song_suggestion.dart';
import '../../domain/repositories/ai_repository.dart';

class OllamaRepositoryImpl implements AIRepository {
  final Dio _dio;
  final String _baseUrl = 'http://localhost:11434/api/chat';
  final String _model = 'qwen3:8b'; // Assuming this is the model tag

  OllamaRepositoryImpl(this._dio);

  @override
  Future<String> analyzeMood(String input) async {
    // Simple implementation for now, or could ask LLM to classify
    return "Mood Analysis Implementation Pending";
  }

  @override
  Future<List<SongSuggestion>> getSongSuggestions(String userMood, List<ChatMessage> history) async {
    final systemPrompt = """
You are AuraBeats, an advanced AI music companion.
Your goal is to suggest songs based on the user's mood.
Return ONLY a valid JSON object with a key 'songs' containing a list of 5 song suggestions.
Each song must have: 'title', 'artist', 'genre', 'mood', 'reason'.
The 'reason' should be a short, emotional explanation of why it fits.
Analyze the user's input deeply.
Example JSON:
{
  "songs": [
    {
      "title": "Song Name",
      "artist": "Artist Name",
      "genre": "Genre",
      "mood": "Mood Tag",
      "reason": "Because you feel..."
    }
  ]
}
Do not include markdown formatting or extra text.
""";

    try {
      final response = await _dio.post(
        _baseUrl,
        data: {
          "model": _model,
          "messages": [
            {"role": "system", "content": systemPrompt},
            ...history.map((e) => {"role": e.isUser ? "user" : "assistant", "content": e.content}),
            {"role": "user", "content": userMood}
          ],
          "stream": false,
          "format": "json", // Force JSON mode if supported by Ollama/Model
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['message']['content'];
        
        // Parse JSON content
        // It might be wrapped in ```json ... ``` or just raw json
        String jsonString = content.toString().trim();
        if (jsonString.startsWith('```json')) {
          jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '');
        }

        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        if (jsonMap.containsKey('songs')) {
          final List<dynamic> songsList = jsonMap['songs'];
          return songsList.map((e) => SongSuggestion.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Ollama Error: $e");
      throw Exception("Failed to fetch suggestions from Ollama");
    }
  }
}
