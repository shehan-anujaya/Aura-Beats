import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/chat_message.dart';

class LocalStorageService {
  static const String boxName = 'aura_data';
  static const String keyChatHistory = 'chat_history';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  Box get _box => Hive.box(boxName);

  Future<void> saveChatHistory(List<ChatMessage> messages) async {
    final List<Map<String, dynamic>> rawList = messages.map((m) => {
      'id': m.id,
      'content': m.content,
      'isUser': m.isUser,
      'timestamp': m.timestamp.toIso8601String(),
    }).toList();
    
    await _box.put(keyChatHistory, rawList);
  }

  List<ChatMessage> getChatHistory() {
    final rawData = _box.get(keyChatHistory);
    if (rawData == null) return [];

    // Hive might return List<dynamic>, need to cast to List<Map>
    final List<dynamic> list = rawData;
    return list.map((e) {
      final map = Map<String, dynamic>.from(e);
      return ChatMessage(
        id: map['id'],
        content: map['content'],
        isUser: map['isUser'],
        timestamp: DateTime.parse(map['timestamp']),
      );
    }).toList();
  }

  Future<void> clearHistory() async {
    await _box.delete(keyChatHistory);
  }
}
