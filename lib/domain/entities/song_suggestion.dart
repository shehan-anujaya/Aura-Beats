import 'package:equatable/equatable.dart';

class SongSuggestion extends Equatable {
  final String title;
  final String artist;
  final String genre;
  final String mood;
  final String reason;
  final String? imageUrl;
  final String? previewUrl;

  const SongSuggestion({
    required this.title,
    required this.artist,
    required this.genre,
    required this.mood,
    required this.reason,
    this.imageUrl,
    this.previewUrl,
  });

  @override
  List<Object?> get props => [title, artist, genre, mood, reason, imageUrl, previewUrl];

  // Helper to parse from typical JSON format
  factory SongSuggestion.fromJson(Map<String, dynamic> json) {
    return SongSuggestion(
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist'] ?? 'Unknown Artist',
      genre: json['genre'] ?? 'Unknown Genre',
      mood: json['mood'] ?? 'General',
      reason: json['reason'] ?? '',
    );
  }
}
