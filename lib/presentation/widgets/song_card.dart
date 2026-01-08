import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/song_suggestion.dart';
import '../providers/favorites_provider.dart';
import '../providers/audio_player_provider.dart';
import 'glass_container.dart';

import '../providers/theme_provider.dart';

class SongCard extends ConsumerStatefulWidget {
  final SongSuggestion song;

  const SongCard({
    super.key,
    required this.song,
  });

  @override
  ConsumerState<SongCard> createState() => _SongCardState();
}

class _SongCardState extends ConsumerState<SongCard> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioPlaybackProvider);
    final isLiked = ref.watch(favoritesProvider).any((s) => s.title == widget.song.title);
    final isThisPlaying = audioState.playingUrl == widget.song.previewUrl && audioState.isPlaying;
    final themeMode = ref.watch(themeProvider);
    final primaryColor = AppTheme.getPrimary(themeMode);

    return Container(
      width: 210, // Slightly wider for better text spacing
      margin: const EdgeInsets.only(right: 16, bottom: 12, top: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(32),
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Album Art Section
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      child: widget.song.imageUrl != null
                          ? Image.network(
                              widget.song.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                  ),
                  // Premium Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.8),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Play/Pause Button - Centered and Refined
                  if (widget.song.previewUrl != null)
                    Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => ref.read(audioPlaybackProvider.notifier).playPreview(widget.song.previewUrl!, widget.song.mood),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isThisPlaying ? primaryColor : Colors.white.withOpacity(0.15),
                              border: Border.all(color: Colors.white24, width: 1.5),
                              boxShadow: [
                                if (isThisPlaying)
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: Icon(
                              isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Like Button - Top Right
                  Positioned(
                    top: 14,
                    right: 14,
                    child: GestureDetector(
                      onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(widget.song),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black38,
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Icon(
                          isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 16,
                          color: isLiked ? Colors.redAccent : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info Section
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.song.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.song.artist,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (isThisPlaying) ...[
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                          activeTrackColor: primaryColor,
                          inactiveTrackColor: Colors.white.withOpacity(0.05),
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: _isDragging 
                              ? _dragValue 
                              : audioState.position.inMilliseconds.toDouble().clamp(0, audioState.duration.inMilliseconds.toDouble() > 0 ? audioState.duration.inMilliseconds.toDouble() : 1.0),
                          max: audioState.duration.inMilliseconds.toDouble() > 0 
                              ? audioState.duration.inMilliseconds.toDouble() 
                              : 1.0,
                          onChanged: (value) => setState(() => _dragValue = value),
                          onChangeStart: (_) => setState(() => _isDragging = true),
                          onChangeEnd: (value) {
                            ref.read(audioPlaybackProvider.notifier).seek(Duration(milliseconds: value.toInt()));
                            setState(() => _isDragging = false);
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Text(
                        widget.song.reason,
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                          height: 1.3,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purpleAccent.withOpacity(0.4),
            Colors.blueAccent.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.music_note, size: 48, color: Colors.white.withOpacity(0.5)),
      ),
    );
  }
}
