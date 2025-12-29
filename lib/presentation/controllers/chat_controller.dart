import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/song_suggestion.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../providers/di_providers.dart';

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
  late final AIRepository _aiRepository;
  late final ChatRepository _chatRepository;

  @override
  ChatState build() {
    _aiRepository = ref.read(aiRepositoryProvider);
    _chatRepository = ref.read(chatRepositoryProvider);
    
    _loadHistory();
    
    // Return initial state temporarily, will update async
    return ChatState.initial();
  }

  Future<void> _loadHistory() async {
    final history = await _chatRepository.getHistory();
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
    await _chatRepository.saveMessage(userMsg);

    // Analyze and Get Suggestions
    try {
      final suggestions = await _aiRepository.getSongSuggestions(text, state.messages);

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
        await _chatRepository.saveMessage(aiMsg);
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
        await _chatRepository.saveMessage(aiMsg);
      }
    } catch (e) {
      final errorMsg = ChatMessage(
        id: const Uuid().v4(),
        content: "I had trouble connecting to my inner senses (Ollama). Is it running? Error: $e",
        isUser: false,
        timestamp: DateTime.now(),
      );
      final updatedMessages = [...newMessages, errorMsg];
      
      state = state.copyWith(
        isLoading: false,
        messages: updatedMessages,
      );
      // Don't save error messages to history maybe? Or yes to show context.
      await _chatRepository.saveMessage(errorMsg);
    }
  }
  
  Future<void> reset() async {
    state = ChatState.initial();
    await _chatRepository.clearHistory();
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
