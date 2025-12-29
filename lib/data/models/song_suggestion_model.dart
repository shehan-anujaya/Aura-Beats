import '../../domain/entities/song_suggestion.dart';

class SongSuggestionModel extends SongSuggestion {
  const SongSuggestionModel({
    required String title,
    required String artist,
    required String genre,
    required String mood,
    required String reason,
  }) : super(
          title: title,
          artist: artist,
          genre: genre,
          mood: mood,
          reason: reason,
        );

  factory SongSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SongSuggestionModel(
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist'] ?? 'Unknown Artist',
      genre: json['genre'] ?? 'Unknown Genre',
      mood: json['mood'] ?? 'General',
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'genre': genre,
      'mood': mood,
      'reason': reason,
    };
  }
}
