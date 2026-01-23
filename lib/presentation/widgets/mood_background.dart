import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';

enum MoodType { love, sad, happy, chill, energetic, none }

class MoodBackground extends ConsumerWidget {
  final MoodType mood;
  final bool isPlaying;
  final Widget child;

  const MoodBackground({
    super.key,
    required this.mood,
    required this.isPlaying,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isSpotify = themeMode == AuraThemeMode.spotify;

    return Stack(
      children: [
        Positioned.fill(child: _BaseBackground(mood: mood, isPlaying: isPlaying, themeMode: themeMode)),
        if (isPlaying && !isSpotify) RepaintBoundary(child: _MoodOverlay(mood: mood)),
        child,
      ],
    );
  }
}

class _BaseBackground extends StatelessWidget {
  final MoodType mood;
  final bool isPlaying;
  final AuraThemeMode themeMode;

  const _BaseBackground({required this.mood, required this.isPlaying, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final colors = _getMoodColors(mood, isPlaying, themeMode);
    final isSpotify = themeMode == AuraThemeMode.spotify;

    return AnimatedContainer(
      duration: 2.seconds,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSpotify 
              ? [const Color(0xFF121212), const Color(0xFF181818)]
              : colors,
        ),
      ),
    );
  }

  List<Color> _getMoodColors(MoodType mood, bool isPlaying, AuraThemeMode themeMode) {
    if (!isPlaying) {
      final bg = AppTheme.getBackground(themeMode);
      final surface = AppTheme.getSurface(themeMode);
      return [bg, surface];
    }

    switch (mood) {
      case MoodType.love:
        return [const Color(0xFF4A148C), const Color(0xFF880E4F)];
      case MoodType.sad:
        return [const Color(0xFF0D47A1), const Color(0xFF001F3F)];
      case MoodType.happy:
        return [const Color(0xFFFF8F00), const Color(0xFFE65100)];
      case MoodType.chill:
        return [const Color(0xFF263238), const Color(0xFF455A64)];
      case MoodType.energetic:
        return [const Color(0xFFBF360C), const Color(0xFFD84315)];
      case MoodType.none:
      default:
        final bg = AppTheme.getBackground(themeMode);
        final surface = AppTheme.getSurface(themeMode);
        return [bg, surface];
    }
  }
}

class _MoodOverlay extends StatelessWidget {
  final MoodType mood;

  const _MoodOverlay({required this.mood});

  @override
  Widget build(BuildContext context) {
    switch (mood) {
      case MoodType.love:
        return const ParticleEffect(icon: Icons.favorite, color: Colors.pinkAccent);
      case MoodType.sad:
        return const RainEffect();
      case MoodType.happy:
        return const ParticleEffect(icon: Icons.star, color: Colors.amberAccent);
      case MoodType.chill:
        return const CloudEffect();
      case MoodType.energetic:
        return const PulseEffect();
      default:
        return const SizedBox.shrink();
    }
  }
}

class ParticleEffect extends StatelessWidget {
  final IconData icon;
  final Color color;

  const ParticleEffect({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: List.generate(12, (index) { // Reduced from 20 to 12
          final random = math.Random(index); // Use index as seed for consistency
          final startX = random.nextDouble() * MediaQuery.of(context).size.width;
          final delay = random.nextInt(2000).ms; // Reduced delay range
          final duration = (3000 + random.nextInt(2000)).ms; // Reduced duration range

          return Positioned(
            left: startX,
            bottom: -50, // Reduced from -100
            child: Icon(icon, color: color.withOpacity(0.4), size: 16 + random.nextDouble() * 24) // Smaller size range
                .animate(onPlay: (controller) => controller.repeat())
                .moveY(begin: 0, end: -MediaQuery.of(context).size.height - 100, duration: duration, delay: delay, curve: Curves.easeInOut)
                .fade(begin: 0, end: 0.8, duration: 500.ms) // Faster fade in
                .then()
                .fade(begin: 0.8, end: 0, duration: 500.ms), // Faster fade out
          );
        }),
      ),
    );
  }
}

class RainEffect extends StatelessWidget {
  const RainEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: List.generate(30, (index) { // Reduced from 60 to 30
          final random = math.Random(index); // Use index as seed
          final startX = random.nextDouble() * MediaQuery.of(context).size.width;
          final delay = random.nextInt(800).ms; // Reduced delay
          final duration = (600 + random.nextInt(400)).ms; // Reduced duration range

          return Positioned(
            left: startX,
            top: -50, // Reduced from -100
            child: Container(
              width: 1.5, // Slightly thinner
              height: 20 + random.nextDouble() * 30, // Smaller height range
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blueAccent.withOpacity(0), Colors.blueAccent.withOpacity(0.5)], // Reduced opacity
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .moveY(begin: 0, end: MediaQuery.of(context).size.height + 150, duration: duration, delay: delay, curve: Curves.linear),
          );
        }),
      ),
    );
  }
}

class CloudEffect extends StatelessWidget {
  const CloudEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: List.generate(3, (index) { // Reduced from 5 to 3
          final random = math.Random(index);
          final startY = random.nextDouble() * MediaQuery.of(context).size.height;
          final delay = random.nextInt(8000).ms; // Reduced delay range
          final duration = (12000 + random.nextInt(8000)).ms; // Reduced duration range

          return Positioned(
            top: startY,
            left: -200, // Reduced from -300
            child: Container(
              width: 150 + random.nextDouble() * 150, // Smaller width range
              height: 75 + random.nextDouble() * 75, // Smaller height range
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.08), // Reduced opacity
                    blurRadius: 80, // Reduced blur
                    spreadRadius: 30, // Reduced spread
                  ),
                ],
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .moveX(begin: 0, end: MediaQuery.of(context).size.width + 400, duration: duration, delay: delay, curve: Curves.linear),
          );
        }),
      ),
    );
  }
}

class PulseEffect extends StatelessWidget {
  const PulseEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Container(
          width: 400, // Reduced from 500
          height: 400, // Reduced from 500
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.orangeAccent.withOpacity(0.2), // Reduced opacity
                Colors.redAccent.withOpacity(0.0),
              ],
            ),
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
         .scale(begin: const Offset(0.9, 0.9), end: const Offset(2.0, 2.0), duration: 1.5.seconds, curve: Curves.easeInOut) // Slower and smaller scale
         .blur(begin: const Offset(30, 30), end: const Offset(100, 100)) // Reduced blur range
         .fade(begin: 0.05, end: 0.3), // Reduced opacity range
      ),
    );
  }
}
