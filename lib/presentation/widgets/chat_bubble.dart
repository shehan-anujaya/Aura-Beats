import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/chat_message.dart';
import 'glass_container.dart';
import 'song_card.dart';

import '../providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatBubble extends ConsumerWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.isUser;
    final themeMode = ref.watch(themeProvider);
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: isUser
            ? _buildUserBubble(context, themeMode)
            : _buildAIBubble(context, themeMode),
      ),
    ).animate().fade().scale();
  }

  Widget _buildUserBubble(BuildContext context, AuraThemeMode themeMode) {
    final primary = AppTheme.getPrimary(themeMode);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            themeMode == AuraThemeMode.aura ? AppTheme.auraPrimaryDark : primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        message.content,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14.5,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildAIBubble(BuildContext context, AuraThemeMode themeMode) {
    final isSpotify = themeMode == AuraThemeMode.spotify;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassContainer(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          color: isSpotify ? Colors.white.withOpacity(0.05) : null,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(24),
          ),
          blur: isSpotify ? 10 : 25,
          child: Text(
            message.content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              height: 1.5,
              fontSize: 14.5,
              letterSpacing: 0.1,
            ),
          ),
        ),
        if (message.suggestions != null && message.suggestions!.isNotEmpty)
          Container(
            height: 280,
            margin: const EdgeInsets.only(bottom: 12, top: 4),
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: message.suggestions!.length,
              itemBuilder: (context, index) {
                final song = message.suggestions![index];
                return SizedBox(
                  width: 200,
                  child: SongCard(song: song)
                      .animate(delay: (200 * index).ms)
                      .shimmer(duration: 1.5.seconds, color: Colors.white.withOpacity(0.05))
                      .fade(duration: 600.ms)
                      .slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                );
              },
            ),
          ),
      ],
    );
  }
}
