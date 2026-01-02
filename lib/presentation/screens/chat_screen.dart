import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/chat_controller.dart';
import '../providers/connectivity_provider.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/mood_background.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/glass_container.dart';
import '../widgets/song_card.dart';
import '../widgets/custom_title_bar.dart';
import 'favorites_screen.dart';

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

  MoodType _getMoodType(String? mood) {
    if (mood == null) return MoodType.none;
    final m = mood.toLowerCase();
    if (m.contains('love')) return MoodType.love;
    if (m.contains('sad') || m.contains('melancholy')) return MoodType.sad;
    if (m.contains('happ') || m.contains('upbeat') || m.contains('joy')) return MoodType.happy;
    if (m.contains('chill') || m.contains('relax') || m.contains('calm')) return MoodType.chill;
    if (m.contains('energ') || m.contains('pump') || m.contains('power')) return MoodType.energetic;
    return MoodType.none;
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final audioState = ref.watch(audioPlaybackProvider);

    // Auto-scroll on new message
    ref.listen(chatProvider, (previous, next) {
      if (next.messages.length > (previous?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    final currentMood = _getMoodType(audioState.currentMood);

    return Scaffold(
      body: MoodBackground(
        mood: currentMood,
        isPlaying: audioState.isPlaying,
        child: Column(
          children: [
            CustomTitleBar(
              actions: [
                // Connectivity Indicator
                Consumer(
                  builder: (context, ref, child) {
                    final isConnected = ref.watch(backendConnectivityProvider);
                    return Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isConnected ? Colors.greenAccent : Colors.redAccent,
                            boxShadow: [
                              if (isConnected)
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isConnected ? "Aura Online" : "Aura Offline",
                          style: TextStyle(
                            color: isConnected ? Colors.greenAccent.withOpacity(0.7) : Colors.redAccent.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.favorite, size: 20, color: Colors.white70),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: Colors.white70),
                  onPressed: () => ref.read(chatProvider.notifier).reset(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
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
              
              // Mood Check-in Overlay
              if (audioState.hasJustFinished)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(24),
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Aura sensed the vibe. How are you feeling now?",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _MoodButton(
                              label: "Better", 
                              icon: Icons.wb_sunny_outlined,
                              onTap: () {
                                ref.read(chatProvider.notifier).sendMessage("I feel better, thanks!");
                                ref.read(audioPlaybackProvider.notifier).resetFinished();
                              },
                            ),
                            _MoodButton(
                              label: "Still Same", 
                              icon: Icons.filter_drama_outlined,
                              onTap: () {
                                ref.read(chatProvider.notifier).sendMessage("It's nice, but I'm still feeling a bit the same.");
                                ref.read(audioPlaybackProvider.notifier).resetFinished();
                              },
                            ),
                            _MoodButton(
                              label: "Different Vibe", 
                              icon: Icons.auto_awesome_mosaic_outlined,
                              onTap: () {
                                ref.read(chatProvider.notifier).sendMessage("Can we try a different vibe?");
                                ref.read(audioPlaybackProvider.notifier).resetFinished();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().scale(curve: Curves.elasticOut, duration: 600.ms).fade(),
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
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _MoodButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(icon, size: 20, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}
