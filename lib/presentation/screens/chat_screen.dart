import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/chat_controller.dart';
import '../providers/connectivity_provider.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/mood_background.dart';
import '../providers/theme_provider.dart';
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
    final themeMode = ref.watch(themeProvider);
    final primaryColor = AppTheme.getPrimary(themeMode);

    // Auto-scroll on new message
    ref.listen(chatProvider, (previous, next) {
      if (next.messages.length > (previous?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    final currentMood = _getMoodType(audioState.currentMood);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MoodBackground(
        mood: currentMood,
        isPlaying: audioState.isPlaying,
        child: Column(
          children: [
            CustomTitleBar(
              actions: [
                // Connectivity Indicator - Premium Glass Pill
                Consumer(
                  builder: (context, ref, child) {
                    final isConnected = ref.watch(backendConnectivityProvider);
                    final color = isConnected ? Colors.greenAccent : Colors.redAccent;
                    
                    return GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      borderRadius: BorderRadius.circular(20),
                      blur: 10,
                      color: color.withOpacity(0.05),
                      border: Border.all(color: color.withOpacity(0.2), width: 1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                           .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 1.seconds)
                           .tint(color: color.withOpacity(0.8)),
                          const SizedBox(width: 8),
                          Text(
                            isConnected ? "AURA ONLINE" : "AURA OFFLINE",
                            style: GoogleFonts.outfit(
                              color: color.withOpacity(0.8),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
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
                  return ChatBubble(message: msg);
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
                    color: primaryColor.withOpacity(0.15),
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

              // Input Area - Premium Floating Pill
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  borderRadius: BorderRadius.circular(40),
                  blur: 30,
                  color: Colors.white.withOpacity(0.08),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: "Speak your heart to Aura...",
                            hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 15),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              ref.read(chatProvider.notifier).sendMessage(value);
                              _textController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (chatState.isLoading)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withOpacity(0.15),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.auto_awesome_rounded, color: primaryColor, size: 24),
                            onPressed: () {
                              if (_textController.text.trim().isNotEmpty) {
                                ref.read(chatProvider.notifier).sendMessage(_textController.text);
                                _textController.clear();
                              }
                            },
                          ),
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
