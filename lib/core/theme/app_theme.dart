import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Aura Theme Colors (Premium Deep Midnight)
  static const Color auraPrimary = Color(0xFF6366F1); // Indigo 500
  static const Color auraPrimaryDark = Color(0xFF4F46E5); // Indigo 600
  static const Color auraBackground = Color(0xFF0A0F1E); // Deep Midnight
  static const Color auraSurface = Color(0xFF161D31); // Refined Surface
  static const Color auraAccent = Color(0xFF10B981); // Emerald accent

  // Spotify Theme Colors
  static const Color spotifyPrimary = Color(0xFF1DB954);
  static const Color spotifyBackground = Color(0xFF121212);
  static const Color spotifySurface = Color(0xFF181818);
  static const Color spotifyAccent = Color(0xFF1ED760);

  // Sunset Theme Colors
  static const Color sunsetPrimary = Color(0xFFFF5722);
  static const Color sunsetBackground = Color(0xFF1A1414); // Deeper Warm Grey
  static const Color sunsetSurface = Color(0xFF2D2424); // Warm Dark Grey
  static const Color sunsetAccent = Color(0xFFFFC107);

  // Neon Theme Colors
  static const Color neonPrimary = Color(0xFF00FFFF); // Cyan
  static const Color neonBackground = Color(0xFF0D0D0D); // Very Dark Grey
  static const Color neonSurface = Color(0xFF1A1A1A); // Dark Grey
  static const Color neonAccent = Color(0xFFFF00FF); // Magenta

  // Theme-aware values
  static Color getPrimary(AuraThemeMode mode) {
    switch (mode) {
      case AuraThemeMode.aura: return auraPrimary;
      case AuraThemeMode.spotify: return spotifyPrimary;
      case AuraThemeMode.sunset: return sunsetPrimary;
      case AuraThemeMode.neon: return neonPrimary;
    }
  }

  static Color getBackground(AuraThemeMode mode) {
    switch (mode) {
      case AuraThemeMode.aura: return auraBackground;
      case AuraThemeMode.spotify: return spotifyBackground;
      case AuraThemeMode.sunset: return sunsetBackground;
      case AuraThemeMode.neon: return neonBackground;
    }
  }

  static Color getSurface(AuraThemeMode mode) {
    switch (mode) {
      case AuraThemeMode.aura: return auraSurface;
      case AuraThemeMode.spotify: return spotifySurface;
      case AuraThemeMode.sunset: return sunsetSurface;
      case AuraThemeMode.neon: return neonSurface;
    }
  }

  // Glassmorphism Constants
  static const double glassBorderRadius = 24.0;
  static const double glassBlur = 25.0; // Increased blur for better premium feel
  static const Color glassBorderColor = Color(0x1AFFFFFF); // Subtle white border
  static const Color glassBackgroundColor = Color(0x0DFFFFFF); // Transparent white

  static ThemeData getTheme(AuraThemeMode mode) {
    final primary = getPrimary(mode);
    final background = getBackground(mode);
    final surface = getSurface(mode);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: mode == AuraThemeMode.aura 
            ? auraAccent 
            : (mode == AuraThemeMode.spotify ? spotifyAccent : (mode == AuraThemeMode.sunset ? sunsetAccent : neonAccent)),
        surface: surface,
        onSurface: Colors.white,
        background: background,
        onBackground: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w700, 
          color: Colors.white,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.w700, 
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w600, 
          color: Colors.white,
          letterSpacing: -0.2,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w400, 
          color: Colors.white,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.w400, 
          color: Colors.white.withOpacity(0.6),
          height: 1.5,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white70, size: 20),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}

enum AuraThemeMode { aura, spotify, sunset, neon }
