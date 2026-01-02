import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/theme/app_theme.dart';

class CustomTitleBar extends StatelessWidget {
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomTitleBar({
    super.key,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Draggable Area
          const Positioned.fill(
            child: MoveWindow(),
          ),
          
          Row(
            children: [
              const SizedBox(width: 20),
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (showBackButton) const SizedBox(width: 12),
              
              // Branding
              const Icon(Icons.auto_awesome_rounded, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Text(
                "AuraBeats",
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.5,
                ),
              ),
              
              const Spacer(),
              
              if (actions != null) ...actions!,
              
              const SizedBox(width: 8),
              
              // Window Controls
              _TitleBarButton(
                icon: Icons.remove,
                onPressed: () => windowManager.minimize(),
              ),
              _TitleBarButton(
                icon: Icons.close,
                isClose: true,
                onPressed: () => windowManager.close(),
              ),
              const SizedBox(width: 8),
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
