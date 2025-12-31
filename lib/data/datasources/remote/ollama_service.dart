import 'package:dio/dio.dart';
import '../../models/song_suggestion_model.dart';
import 'dart:convert';

class OllamaService {
  final Dio _dio;
  // Use http://localhost:11434/api/chat for chat-based (e.g. llama3, qwen) or /api/generate
  // Android emulator needs 10.0.2.2 usually, but for Desktop (Windows) localhost is fine.
  static const String _baseUrl = 'http://localhost:8000';

  OllamaService(this._dio);

  /// Generates a response from the AuraBeats Python Backend.
  Future<List<SongSuggestionModel>> generateSongSuggestions({
    required String prompt,
    List<Map<String, dynamic>>? history,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/suggestions',
        data: {
          'mood': prompt,
          'history': history ?? [],
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['suggestions'];
        return jsonList.map((e) => SongSuggestionModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch from AuraBeats API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AuraBeats API Error: $e');
    }
  }

  Future<String> analyzeMood(String input) async {
     // For now, we can keep this or move it to Python if needed.
     // Let's assume we want all AI logic in Python eventually.
     // For this task, let's just make it return a placeholder or implement it in Python.
     return 'Neutral';
  }
}
