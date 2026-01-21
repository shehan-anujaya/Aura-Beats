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
    return Stack(
      children: List.generate(60, (index) {
        final random = math.Random();
        final startX = random.nextDouble() * MediaQuery.of(context).size.width;
        final delay = random.nextInt(1000).ms;
        final duration = (800 + random.nextInt(600)).ms;

        return Positioned(
          left: startX,
          top: -100,
          child: Container(
            width: 2,
            height: 30 + random.nextDouble() * 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueAccent.withOpacity(0), Colors.blueAccent.withOpacity(0.6)],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .moveY(begin: 0, end: MediaQuery.of(context).size.height + 250, duration: duration, delay: delay, curve: Curves.linear),
        );
      }),
    );
  }
}

class CloudEffect extends StatelessWidget {
  const CloudEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(5, (index) {
        final random = math.Random();
        final startY = random.nextDouble() * MediaQuery.of(context).size.height;
        final delay = random.nextInt(10000).ms;
        final duration = (15000 + random.nextInt(15000)).ms;

        return Positioned(
          top: startY,
          left: -300,
          child: Container(
            width: 200 + random.nextDouble() * 200,
            height: 100 + random.nextDouble() * 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.1),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .moveX(begin: 0, end: MediaQuery.of(context).size.width + 600, duration: duration, delay: delay, curve: Curves.linear),
        );
      }),
    );
  }
}

class PulseEffect extends StatelessWidget {
  const PulseEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        height: 500,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.orangeAccent.withOpacity(0.3),
              Colors.redAccent.withOpacity(0.0),
            ],
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .scale(begin: const Offset(0.8, 0.8), end: const Offset(2.5, 2.5), duration: 1.2.seconds, curve: Curves.easeInOut)
       .blur(begin: const Offset(40, 40), end: const Offset(150, 150))
       .fade(begin: 0.1, end: 0.5),
    );
  }
}
