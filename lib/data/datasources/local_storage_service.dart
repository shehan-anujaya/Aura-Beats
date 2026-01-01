import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message_model.dart';

class LocalStorageService {
  static const String boxName = 'aura_data';
  static const String keyChatHistory = 'chat_history';
  static const String keyFavorites = 'favorites';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  Box get _box => Hive.box(boxName);

  // Chat History
  Future<void> saveChatHistory(List<ChatMessageModel> messages) async {
    final List<Map<String, dynamic>> rawList = messages.map((m) => m.toJson()).toList();
    await _box.put(keyChatHistory, rawList);
  }

  List<ChatMessageModel> getChatHistory() {
    final rawData = _box.get(keyChatHistory);
    if (rawData == null) return [];

    final List<dynamic> list = rawData;
    return list.map((e) {
      final map = Map<String, dynamic>.from(e);
      return ChatMessageModel.fromJson(map);
    }).toList();
  }

  // Favorites
  Future<void> saveFavorite(SongSuggestionModel song) async {
    final favorites = getFavorites();
    if (!favorites.any((s) => s.title == song.title && s.artist == song.artist)) {
      favorites.add(song);
      final List<Map<String, dynamic>> rawList = favorites.map((s) => s.toJson()).toList();
      await _box.put(keyFavorites, rawList);
    }
  }

  Future<void> removeFavorite(String title, String artist) async {
    final favorites = getFavorites();
    favorites.removeWhere((s) => s.title == title && s.artist == artist);
    final List<Map<String, dynamic>> rawList = favorites.map((s) => s.toJson()).toList();
    await _box.put(keyFavorites, rawList);
  }

  List<SongSuggestionModel> getFavorites() {
    final rawData = _box.get(keyFavorites);
    if (rawData == null) return [];

    final List<dynamic> list = rawData;
    return list.map((e) {
      final map = Map<String, dynamic>.from(e);
      return SongSuggestionModel.fromJson(map);
    }).toList();
  }

  Future<void> clearHistory() async {
    await _box.delete(keyChatHistory);
  }
}
