import '../../domain/entities/song_suggestion.dart';

class SongSuggestionModel extends SongSuggestion {
  const SongSuggestionModel({
    required super.title,
    required super.artist,
    required super.genre,
    required super.mood,
    required super.reason,
    super.imageUrl,
    super.previewUrl,
  });

  factory SongSuggestionModel.fromEntity(SongSuggestion song) {
    return SongSuggestionModel(
      title: song.title,
      artist: song.artist,
      genre: song.genre,
      mood: song.mood,
      reason: song.reason,
      imageUrl: song.imageUrl,
      previewUrl: song.previewUrl,
    );
  }

  factory SongSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SongSuggestionModel(
      title: json['title'],
      artist: json['artist'],
      genre: json['genre'],
      mood: json['mood'],
      reason: json['reason'],
      imageUrl: json['imageUrl'],
      previewUrl: json['previewUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'genre': genre,
      'mood': mood,
      'reason': reason,
      'imageUrl': imageUrl,
      'previewUrl': previewUrl,
    };
  }
}
