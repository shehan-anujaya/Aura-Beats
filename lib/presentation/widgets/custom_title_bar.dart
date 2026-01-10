import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final primaryColor = AppTheme.getPrimary(widget.themeMode);
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.03 + (_animation.value * 0.02)),
                Colors.transparent,
                primaryColor.withOpacity(0.02 + ((1 - _animation.value) * 0.02)),
              ],
              stops: [
                0.0,
                0.3 + (_animation.value * 0.4),
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated shimmer effect
              Positioned(
                left: -100 + (_animation.value * 200),
                top: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryColor.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Secondary shimmer effect
              Positioned(
                right: -50 + ((1 - _animation.value) * 150),
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryColor.withOpacity(0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
