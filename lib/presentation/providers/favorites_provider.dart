import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/song_suggestion.dart';
import '../../data/datasources/local_storage_service.dart';
import '../../data/models/song_suggestion_model.dart';
import '../../core/di/injection_container.dart';

class FavoritesNotifier extends Notifier<List<SongSuggestion>> {
  late final LocalStorageService _localStorageService;

  @override
  List<SongSuggestion> build() {
    _localStorageService = sl<LocalStorageService>();
    return _localStorageService.getFavorites();
  }

  Future<void> toggleFavorite(SongSuggestion song) async {
    final isFavorite = state.any((s) => s.title == song.title && s.artist == song.artist);
    
    if (isFavorite) {
      await _localStorageService.removeFavorite(song.title, song.artist);
      state = state.where((s) => !(s.title == song.title && s.artist == song.artist)).toList();
    } else {
      final model = SongSuggestionModel(
        title: song.title,
        artist: song.artist,
        genre: song.genre,
        mood: song.mood,
        reason: song.reason,
      );
      await _localStorageService.saveFavorite(model);
      state = [...state, song];
    }
  }

  bool isFavorite(SongSuggestion song) {
    return state.any((s) => s.title == song.title && s.artist == song.artist);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<SongSuggestion>>(FavoritesNotifier.new);
