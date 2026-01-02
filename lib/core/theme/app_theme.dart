import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Premium Curated Palette
  static const Color primaryColor = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo 600
  static const Color secondaryColor = Color(0xFF2DD4BF); // Teal 400
  static const Color backgroundColorDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceColorDark = Color(0xFF1E293B); // Slate 800
  static const Color accentColor = Color(0xFFF472B6); // Pink 400

  // Glassmorphism Constants - Refined for "Aura"
  static const double glassBorderRadius = 24.0;
  static const double glassBlur = 20.0;
  static const Color glassBorderColor = Colors.white12;
  static const Color glassBackgroundColor = Color(0x1AFFFFFF); // 10% white

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColorDark,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColorDark,
        onSurface: Colors.white,
        background: backgroundColorDark,
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
        color: surfaceColorDark,
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

  static ThemeData get lightTheme {
    // Placeholder for light theme if needed, but focusing on Dark Mode for "Aura"
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      textTheme: GoogleFonts.outfitTextTheme(),
    );
  }
}
