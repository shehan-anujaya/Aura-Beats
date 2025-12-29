import 'package:dio/dio.dart';
import '../../models/song_suggestion_model.dart';
import 'dart:convert';

class OllamaService {
  final Dio _dio;
  // Use http://localhost:11434/api/chat for chat-based (e.g. llama3, qwen) or /api/generate
  // Android emulator needs 10.0.2.2 usually, but for Desktop (Windows) localhost is fine.
  static const String _baseUrl = 'http://localhost:11434/api';

  OllamaService(this._dio);

  /// Generates a response from the Ollama model.
  /// [prompt] is the user's latest message or a constructed system prompt.
  /// [history] is the list of previous messages for context.
  Future<List<SongSuggestionModel>> generateSongSuggestions({
    required String prompt,
    List<Map<String, dynamic>>? history,
  }) async {
    try {
      final messages = history ?? [];
      // Add the current prompt as a user message
      messages.add({
        'role': 'user',
        'content': prompt,
      });

      // System instruction to force JSON output
      const systemPrompt = '''
You are AuraBeats, a deeply emotional and intelligent music assistant.
Your goal is to suggest songs based on the user's mood and vibe.
You MUST reply with a strictly valid JSON array of objects.
Each object must have: "title", "artist", "genre", "mood", "reason".
Do not include any markdown formatting like ```json ... ```. Just the raw JSON.
Example:
[
  {"title": "Song Name", "artist": "Artist Name", "genre": "Genre", "mood": "Happy", "reason": "Because..."}
]
''';
      
      // Prepend system prompt
      final fullMessages = [
        {'role': 'system', 'content': systemPrompt},
        ...messages
      ];

      final response = await _dio.post(
        '$_baseUrl/chat',
        data: {
          'model': 'qwen2.5:3b', // Or whatever model the user has. Configurable?
          'messages': fullMessages,
          'stream': false,
          'format': 'json', // Force JSON mode if model supports it
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['message']['content'];
        
        // Attempt to parse the JSON content
        // The content might be a string containing JSON.
        final List<dynamic> jsonList = jsonDecode(content);
        
        return jsonList.map((e) => SongSuggestionModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch from Ollama: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ollama Error: $e');
    }
  }

  Future<String> analyzeMood(String input) async {
     try {
      final response = await _dio.post(
        '$_baseUrl/generate',
        data: {
          'model': 'qwen2.5:3b',
          'prompt': 'Analyze the mood of this text and return a SINGLE word (e.g., Happy, Sad, Energetic): "$input"',
          'stream': false,
        },
      );
      
       if (response.statusCode == 200) {
        return response.data['response'].toString().trim();
      }
      return 'Neutral';
     } catch (e) {
       return 'Neutral';
     }
  }
}
