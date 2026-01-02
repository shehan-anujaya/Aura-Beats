import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum MoodType { love, sad, happy, chill, energetic, none }

class MoodBackground extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _BaseBackground(mood: mood, isPlaying: isPlaying),
        if (isPlaying) _MoodOverlay(mood: mood),
        child,
      ],
    );
  }
}

class _BaseBackground extends StatelessWidget {
  final MoodType mood;
  final bool isPlaying;

  const _BaseBackground({required this.mood, required this.isPlaying});

  Color _getMoodColor() {
    switch (mood) {
      case MoodType.love:
        return const Color(0xFF4A148C); // Deep Purple/Wine
      case MoodType.sad:
        return const Color(0xFF102027); // Dark Blue Grey
      case MoodType.happy:
        return const Color(0xFFE65100); // Deep Orange
      case MoodType.chill:
        return const Color(0xFF004D40); // Deep Teal
      case MoodType.energetic:
        return const Color(0xFFBF360C); // Deep Red Orange
      case MoodType.none:
      default:
        return const Color(0xFF0F0C29); // Default Space Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodColor = _getMoodColor();
    return AnimatedContainer(
      duration: 2.seconds,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            moodColor,
            isPlaying ? moodColor.withOpacity(0.8) : const Color(0xFF302B63),
            const Color(0xFF24243E),
          ],
        ),
      ),
    );
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
    return Stack(
      children: List.generate(15, (index) {
        final random = math.Random();
        final startX = random.nextDouble() * MediaQuery.of(context).size.width;
        final delay = random.nextInt(5000).ms;
        final duration = (3000 + random.nextInt(4000)).ms;

        return Positioned(
          left: startX,
          bottom: -50,
          child: Icon(icon, color: color.withOpacity(0.3), size: 10 + random.nextDouble() * 30)
              .animate(onPlay: (controller) => controller.repeat())
              .moveY(begin: 0, end: -MediaQuery.of(context).size.height - 100, duration: duration, delay: delay, curve: Curves.easeInOut)
              .fade(begin: 0, end: 0.6, duration: 1.seconds)
              .then()
              .fade(begin: 0.6, end: 0, duration: 1.seconds),
        );
      }),
    );
  }
}

class RainEffect extends StatelessWidget {
  const RainEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(40, (index) {
        final random = math.Random();
        final startX = random.nextDouble() * MediaQuery.of(context).size.width;
        final delay = random.nextInt(2000).ms;
        final duration = (1000 + random.nextInt(1000)).ms;

        return Positioned(
          left: startX,
          top: -100,
          child: Container(
            width: 1,
            height: 20 + random.nextDouble() * 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueAccent.withOpacity(0), Colors.blueAccent.withOpacity(0.4)],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .moveY(begin: 0, end: MediaQuery.of(context).size.height + 200, duration: duration, delay: delay, curve: Curves.linear),
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
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.orangeAccent.withOpacity(0.1),
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .scale(begin: const Offset(1, 1), end: const Offset(1.8, 1.8), duration: 1.seconds, curve: Curves.easeInOut)
       .blur(begin: const Offset(50, 50), end: const Offset(120, 120))
       .fade(begin: 0.1, end: 0.3),
    );
  }
}
