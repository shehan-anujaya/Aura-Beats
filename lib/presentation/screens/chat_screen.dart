import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/glass_container.dart';
import '../widgets/song_card.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // Small delay to let the list build
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    // Auto-scroll on new message
    ref.listen(chatProvider, (previous, next) {
      if (next.messages.length > (previous?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("AuraBeats"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(chatProvider.notifier).reset(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Dynamic Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0C29),
                  Color(0xFF302B63),
                  Color(0xFF24243E),
                ],
              ),
            ),
          ),
          
          // Subtle Animated Glows (Simulated with Containers)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.15),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
             .moveY(begin: 0, end: 50, duration: 4.seconds, curve: Curves.easeInOut)
             .then()
             .moveY(begin: 50, end: 0, duration: 4.seconds, curve: Curves.easeInOut),
          ),

          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
                  itemCount: chatState.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatState.messages[index];
                    return ChatBubble(message: msg)
                        .animate()
                        .fade(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0);
                  },
                ),
              ),
              
              // Suggestions View
              if (chatState.suggestions.isNotEmpty)
                Container(
                  height: 220,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: chatState.suggestions.length,
                    itemBuilder: (context, index) {
                      final song = chatState.suggestions[index];
                      return SongCard(song: song)
                          .animate(delay: Duration(milliseconds: index * 100))
                          .fade(duration: 500.ms)
                          .slideX(begin: 0.2, end: 0);
                    },
                  ),
                ),

              // Input Area
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  borderRadius: BorderRadius.circular(32),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: "How's your heart feeling today?",
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              ref.read(chatProvider.notifier).sendMessage(value);
                              _textController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (chatState.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            ),
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                          onPressed: () {
                            if (_textController.text.trim().isNotEmpty) {
                              ref.read(chatProvider.notifier).sendMessage(_textController.text);
                              _textController.clear();
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
