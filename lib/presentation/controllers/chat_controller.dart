import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/song_suggestion.dart';
import '../../domain/usecases/get_song_suggestions.dart';
import '../../domain/usecases/get_chat_history.dart';
import '../../domain/usecases/save_chat_message.dart';
import '../../domain/usecases/clear_chat_history.dart';
import '../providers/di_providers.dart';

// State class to hold chat data
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState({
    required this.messages,
    required this.isLoading,
  });

  factory ChatState.initial() {
    return ChatState(
      messages: [
        ChatMessage(
          id: const Uuid().v4(),
          content: "Hey there! I'm Aura. How are you feeling right now?\nRough day or chill vibes?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
      isLoading: false,
    );
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Notifier class
class ChatNotifier extends Notifier<ChatState> {
  late final GetSongSuggestions _getSongSuggestions;
  late final GetChatHistory _getChatHistory;
  late final SaveChatMessage _saveChatMessage;
  late final ClearChatHistory _clearChatHistory;

  @override
  ChatState build() {
    _getSongSuggestions = ref.read(getSongSuggestionsProvider);
    _getChatHistory = ref.read(getChatHistoryProvider);
    _saveChatMessage = ref.read(saveChatMessageProvider);
    _clearChatHistory = ref.read(clearChatHistoryProvider);
    
    _loadHistory();
    
    return ChatState.initial();
  }

  Future<void> _loadHistory() async {
    final history = await _getChatHistory.execute();
    if (history.isNotEmpty) {
      state = state.copyWith(messages: history);
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add User Message
    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final newMessages = [...state.messages, userMsg];
    state = state.copyWith(
      messages: newMessages,
      isLoading: true,
    );
    await _saveChatMessage.execute(userMsg);

    // Analyze and Get Suggestions
    try {
      final suggestions = await _getSongSuggestions.execute(text, state.messages);

      if (suggestions.isNotEmpty) {
        final aiMsg = ChatMessage(
          id: const Uuid().v4(),
          content: "I've found some tracks that match your vibe.",
          isUser: false,
          timestamp: DateTime.now(),
          suggestions: suggestions,
        );
        final updatedMessages = [...state.messages, aiMsg];
        
        state = state.copyWith(
          isLoading: false,
          messages: updatedMessages,
        );
        await _saveChatMessage.execute(aiMsg);
      } else {
        final aiMsg = ChatMessage(
          id: const Uuid().v4(),
          content: "Could you tell me a bit more about how you're feeling?",
          isUser: false,
          timestamp: DateTime.now(),
        );
        final updatedMessages = [...state.messages, aiMsg];
        
        state = state.copyWith(
          isLoading: false,
          messages: updatedMessages,
        );
        await _saveChatMessage.execute(aiMsg);
      }
    } catch (e) {
      final errorMsg = ChatMessage(
        id: const Uuid().v4(),
        content: "I had trouble connecting to my inner senses (Ollama). Is it running? Error: $e",
        isUser: false,
        timestamp: DateTime.now(),
      );
      final updatedMessages = [...state.messages, errorMsg];
      
      state = state.copyWith(
        isLoading: false,
        messages: updatedMessages,
      );
      await _saveChatMessage.execute(errorMsg);
    }
  }
  
  Future<void> reset() async {
    await _clearChatHistory.execute();
    state = ChatState.initial();
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
