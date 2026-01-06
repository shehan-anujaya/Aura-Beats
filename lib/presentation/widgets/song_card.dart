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
      width: 200,
      margin: const EdgeInsets.only(right: 12, bottom: 8, top: 8),
      child: GlassContainer(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Album Art / Media Section
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
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
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Play/Pause Button - Pulsing
                  if (widget.song.previewUrl != null)
                    Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => ref.read(audioPlaybackProvider.notifier).playPreview(widget.song.previewUrl!, widget.song.mood),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Like Button - Top Right
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(widget.song),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(6),
                        borderRadius: BorderRadius.circular(12),
                        blur: 5,
                        color: Colors.black26,
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
            // Details - Refined
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.song.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.song.artist,
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (isThisPlaying) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_isDragging 
                                ? Duration(milliseconds: _dragValue.toInt())
                                : audioState.position),
                            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
                          ),
                          Text(
                            _formatDuration(audioState.duration),
                            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                          activeTrackColor: primaryColor,
                          inactiveTrackColor: Colors.white10,
                          thumbColor: primaryColor,
                        ),
                        child: Slider(
                          value: _isDragging 
                              ? _dragValue 
                              : audioState.position.inMilliseconds.toDouble().clamp(0, audioState.duration.inMilliseconds.toDouble() > 0 ? audioState.duration.inMilliseconds.toDouble() : 1.0),
                          max: audioState.duration.inMilliseconds.toDouble() > 0 
                              ? audioState.duration.inMilliseconds.toDouble() 
                              : 1.0,
                          onChangeStart: (value) {
                            setState(() {
                              _isDragging = true;
                              _dragValue = value;
                            });
                          },
                          onChanged: (value) {
                            setState(() {
                              _dragValue = value;
                            });
                          },
                          onChangeEnd: (value) {
                            ref.read(audioPlaybackProvider.notifier).seek(Duration(milliseconds: value.toInt()));
                            setState(() {
                              _isDragging = false;
                            });
                          },
                        ),
                      ),
                    ],
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        widget.song.reason,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 10,
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
    ).animate().scale(begin: const Offset(1, 1), end: const Offset(1, 1)).shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.03));
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
