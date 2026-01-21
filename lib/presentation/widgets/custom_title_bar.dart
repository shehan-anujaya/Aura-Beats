import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';

class CustomTitleBar extends ConsumerWidget {
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomTitleBar({
    super.key,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isAura = themeMode == AuraThemeMode.aura;
    final isSunset = themeMode == AuraThemeMode.sunset;

    return Container(
      height: 54, // Slightly taller for a more premium feel
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.03),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: _AnimatedBackground(themeMode: themeMode),
          ),
          
          // Draggable Area
          const Positioned.fill(
            child: MoveWindow(),
          ),
          
          Row(
            children: [
              const SizedBox(width: 24),
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (showBackButton) const SizedBox(width: 16),
              
              // Branding
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.getPrimary(themeMode).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isAura || isSunset ? Icons.auto_awesome_rounded : Icons.music_note_rounded,
                  size: 18, 
                  color: AppTheme.getPrimary(themeMode),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "AuraBeats",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  letterSpacing: -0.8,
                ),
              ),
              
              const Spacer(),
              
              // Theme Selection
              PopupMenuButton<AuraThemeMode>(
                icon: Icon(
                  isAura ? Icons.palette_outlined : Icons.palette_rounded,
                  size: 18,
                  color: Colors.white.withOpacity(0.6),
                ),
                tooltip: 'Select Theme',
                offset: const Offset(0, 44),
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: AuraThemeMode.aura,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 18, color: AppTheme.auraPrimary),
                          const SizedBox(width: 12),
                          Text('Aura', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: AuraThemeMode.spotify,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.music_note_rounded, size: 18, color: AppTheme.spotifyPrimary),
                          const SizedBox(width: 12),
                          Text('Spotify', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: AuraThemeMode.sunset,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wb_sunny_rounded, size: 18, color: AppTheme.sunsetPrimary),
                          const SizedBox(width: 12),
                          Text('Sunset', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
                onSelected: (mode) => ref.read(themeProvider.notifier).setTheme(mode),
              ),

              if (actions != null) ...actions!,
              
              const SizedBox(width: 12),
              
              // Window Controls
              _TitleBarButton(
                icon: Icons.minimize_rounded,
                onPressed: () => windowManager.minimize(),
              ),
              _TitleBarButton(
                icon: Icons.close_rounded,
                isClose: true,
                onPressed: () => windowManager.close(),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class _TitleBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _TitleBarButton({
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 16),
      color: Colors.white70,
      hoverColor: isClose ? Colors.red.withOpacity(0.8) : Colors.white10,
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }
}

class MoveWindow extends StatelessWidget {
  const MoveWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: Container(),
    );
  }
}

class _AnimatedBackground extends StatefulWidget {
  final AuraThemeMode themeMode;

  const _AnimatedBackground({required this.themeMode});

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _primaryAnimation;
  late Animation<double> _secondaryAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    
    // Single controller for all animations to reduce overhead
    _controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    // Stagger animations to reduce simultaneous workload
    _primaryAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.67, curve: Curves.easeInOut),
      ),
    );
    
    _secondaryAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.17, 0.84, curve: Curves.easeInOutCubic),
      ),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 1.0, curve: Curves.easeInOutSine),
      ),
    );
    
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final primaryColor = AppTheme.getPrimary(widget.themeMode);
          
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.02 + (_pulseAnimation.value * 0.03)),
                  Colors.transparent,
                  primaryColor.withOpacity(0.01 + ((1 - _pulseAnimation.value) * 0.02)),
                ],
                stops: [
                  0.0,
                  0.3 + (_waveAnimation.value * 0.4),
                  1.0,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Floating orb 1 - Large shimmer
                Positioned(
                  left: -80 + (_primaryAnimation.value * 180),
                  top: -30 + (_secondaryAnimation.value * 20),
                  child: Transform.scale(
                    scale: 0.9 + (_pulseAnimation.value * 0.2),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primaryColor.withOpacity(0.12 * (0.5 + _pulseAnimation.value * 0.5)),
                            primaryColor.withOpacity(0.04),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Floating orb 2 - Medium right side
                Positioned(
                  right: -60 + ((1 - _primaryAnimation.value) * 140),
                  top: -20 + ((1 - _secondaryAnimation.value) * 15),
                  child: Transform.scale(
                    scale: 0.85 + ((1 - _pulseAnimation.value) * 0.15),
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primaryColor.withOpacity(0.10 * (0.6 + (1 - _pulseAnimation.value) * 0.4)),
                            primaryColor.withOpacity(0.03),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Floating orb 3 - Small wanderer
                Positioned(
                  left: 100 + (_secondaryAnimation.value * 80),
                  top: 10 + (_primaryAnimation.value * 25),
                  child: Transform.scale(
                    scale: 0.7 + (_pulseAnimation.value * 0.3),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primaryColor.withOpacity(0.08 * _pulseAnimation.value),
                            Colors.transparent,
                          ],
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Wave effect overlay with RepaintBoundary
                RepaintBoundary(
                  child: CustomPaint(
                    painter: _WavePainter(
                      color: primaryColor,
                      progress: _waveAnimation.value,
                      opacity: 0.02 + (_pulseAnimation.value * 0.03),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                
                // Subtle scanline effect
                Positioned(
                  left: -200,
                  right: -200,
                  top: -10 + (_primaryAnimation.value * 70),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          primaryColor.withOpacity(0.15 * _pulseAnimation.value),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2 * _pulseAnimation.value),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for wave effect
class _WavePainter extends CustomPainter {
  final Color color;
  final double progress;
  final double opacity;

  _WavePainter({
    required this.color,
    required this.progress,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final waveHeight = 10.0;
    final waveLength = size.width / 3;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          waveHeight * Math.sin((x / waveLength * 2 * Math.pi) + (progress * 2 * Math.pi));
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
    
    // Draw second wave with offset
    final path2 = Path();
    path2.moveTo(0, size.height / 2 + 15);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 + 15 +
          waveHeight * 0.7 * Math.sin((x / waveLength * 2 * Math.pi) - (progress * 2 * Math.pi));
      path2.lineTo(x, y);
    }

    canvas.drawPath(path2, paint..color = color.withOpacity(opacity * 0.6));
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.opacity != opacity ||
           oldDelegate.color != color;
  }
}

// Math helper
class Math {
  static double sin(double x) => math.sin(x);
  static double pi = math.pi;
}
