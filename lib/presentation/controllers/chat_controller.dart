import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/song_suggestion.dart';
import '../../domain/repositories/ai_repository.dart';
import '../providers/di_providers.dart';
import '../providers/storage_provider.dart';
import '../../data/datasources/local_storage_service.dart';

// State class to hold chat data
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final List<SongSuggestion> suggestions;

  ChatState({
    required this.messages,
    required this.isLoading,
    required this.suggestions,
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
      suggestions: [],
    );
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    List<SongSuggestion>? suggestions,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

// Notifier class
class ChatNotifier extends Notifier<ChatState> {
  late final AIRepository _repository;
  late final LocalStorageService _storage;

  @override
  ChatState build() {
    _repository = ref.read(aiRepositoryProvider);
    _storage = ref.read(localStorageProvider);
    
    // Load history
    final history = _storage.getChatHistory();
    if (history.isNotEmpty) {
      return ChatState(
        messages: history,
        isLoading: false,
        suggestions: [],
      );
    }
    
    return ChatState.initial();
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
    await _storage.saveChatHistory(newMessages);

    // Analyze and Get Suggestions
    try {
      final suggestions = await _repository.getSongSuggestions(text, state.messages);

      if (suggestions.isNotEmpty) {
        final aiMsg = ChatMessage(
          id: const Uuid().v4(),
          content: "I've found some tracks that match your vibe.",
          isUser: false,
          timestamp: DateTime.now(),
        );
        final updatedMessages = [...newMessages, aiMsg];
        
        state = state.copyWith(
          isLoading: false,
          suggestions: suggestions,
          messages: updatedMessages,
        );
        await _storage.saveChatHistory(updatedMessages);
      } else {
        final aiMsg = ChatMessage(
          id: const Uuid().v4(),
          content: "Could you tell me a bit more about how you're feeling?",
          isUser: false,
          timestamp: DateTime.now(),
        );
        final updatedMessages = [...newMessages, aiMsg];
        
        state = state.copyWith(
          isLoading: false,
          messages: updatedMessages,
        );
        await _storage.saveChatHistory(updatedMessages);
      }
    } catch (e) {
      final errorMsg = ChatMessage(
        id: const Uuid().v4(),
        content: "I had trouble connecting to my inner senses (Ollama). Is it running?",
        isUser: false,
        timestamp: DateTime.now(),
      );
      final updatedMessages = [...newMessages, errorMsg];
      
      state = state.copyWith(
        isLoading: false,
        messages: updatedMessages,
      );
      await _storage.saveChatHistory(updatedMessages);
    }
  }
  
  void reset() {
    state = ChatState.initial();
    _storage.clearHistory();
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
