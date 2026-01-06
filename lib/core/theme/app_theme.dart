import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Aura Theme Colors
  static const Color auraPrimary = Color(0xFF818CF8);
  static const Color auraPrimaryDark = Color(0xFF4F46E5);
  static const Color auraBackground = Color(0xFF0F172A);
  static const Color auraSurface = Color(0xFF1E293B);
  static const Color auraAccent = Color(0xFFF472B6);

  // Spotify Theme Colors
  static const Color spotifyPrimary = Color(0xFF1DB954);
  static const Color spotifyBackground = Color(0xFF121212);
  static const Color spotifySurface = Color(0xFF181818);
  static const Color spotifyAccent = Color(0xFF1ED760);

  // Sunset Theme Colors
  static const Color sunsetPrimary = Color(0xFFFF5722); // Deep Orange
  static const Color sunsetBackground = Color(0xFF2D2424); // Dark Warm Grey
  static const Color sunsetSurface = Color(0xFF4E3D3D); // Warm Brownish Grey
  static const Color sunsetAccent = Color(0xFFFFC107); // Amber

  // Theme-aware values
  static Color getPrimary(AuraThemeMode mode) {
    switch (mode) {
      case AuraThemeMode.aura:
        return auraPrimary;
      case AuraThemeMode.spotify:
        return spotifyPrimary;
      case AuraThemeMode.sunset:
        return sunsetPrimary;
    }
  }

  static Color getBackground(AuraThemeMode mode) {
    switch (mode) {
      case AuraThemeMode.aura:
        return auraBackground;
      case AuraThemeMode.spotify:
        return spotifyBackground;
      case AuraThemeMode.sunset:
        return sunsetBackground;
    }
  }

  static Color getSurface(AuraThemeMode mode) {
    switch (mode) {
      case AuraThemeMode.aura:
        return auraSurface;
      case AuraThemeMode.spotify:
        return spotifySurface;
      case AuraThemeMode.sunset:
        return sunsetSurface;
    }
  }

  // Glassmorphism Constants
  static const double glassBorderRadius = 24.0;
  static const double glassBlur = 20.0;
  static const Color glassBorderColor = Colors.white12;
  static const Color glassBackgroundColor = Color(0x1AFFFFFF);

  static ThemeData getTheme(AuraThemeMode mode) {
    final isAura = mode == AuraThemeMode.aura;
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
            : (mode == AuraThemeMode.spotify ? spotifyAccent : sunsetAccent),
        surface: surface,
        onSurface: Colors.white,
        background: background,
        onBackground: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: GoogleFonts.outfit(fontWeight: FontWeight.w400, color: Colors.white),
        bodyMedium: GoogleFonts.outfit(fontWeight: FontWeight.w400, color: Colors.white70),
      ),
      /*
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(glassBorderRadius),
          side: const BorderSide(color: glassBorderColor, width: 1),
        ),
      ),
      */
      iconTheme: const IconThemeData(color: Colors.white70, size: 20),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}

enum AuraThemeMode { aura, spotify, sunset }
