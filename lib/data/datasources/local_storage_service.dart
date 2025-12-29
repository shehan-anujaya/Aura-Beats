import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message_model.dart';

class LocalStorageService {
  static const String boxName = 'aura_data';
  static const String keyChatHistory = 'chat_history';

  Future<void> init() async {
    await Hive.initFlutter();
    // We register adapter if we were using it, but here we sticking to List<Map> for simplicity without code-gen for now,
    // OR we just serialize Model -> Map manually as before but cleaner.
    // If we want TypeAdapter, we need generated code. Let's stick to manual Map conversion but use Model helper.
    await Hive.openBox(boxName);
  }

  Box get _box => Hive.box(boxName);

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

  Future<void> clearHistory() async {
    await _box.delete(keyChatHistory);
  }
}
