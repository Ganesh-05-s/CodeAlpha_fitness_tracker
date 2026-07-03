import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Theme Colors (from the FitTrack Logo)
  static const Color primaryGreen = Color(0xFF16A34A);      // Beautiful rich forest/emerald green
  static const Color accentLime = Color(0xFF86EFAC);        // Soft neon green
  static const Color backgroundDark = Color(0xFFF8FAFC);    // Light premium slate off-white
  static const Color surfaceDark = Color(0xFFFFFFFF);       // White card surface
  static const Color textDarkPrimary = Color(0xFF0F172A);   // Deep charcoal/slate
  static const Color textDarkSecondary = Color(0xFF475569); // Muted slate grey

  // Legacy Theme Aliases (for backward compatibility with other files)
  static const Color primaryPurple = primaryGreen;
  static const Color primaryLightPurple = surfaceDark;
  static const Color accentLavender = accentLime;
  static const Color backgroundLight = backgroundDark;
  static const Color surfaceLight = surfaceDark;
  static const Color textDark = textDarkPrimary;
  static const Color textLight = textDarkSecondary;

  // Gradient Colors for Premium Cards (matching logo neon-green theme)
  static const List<Color> purpleGradient = [
    Color(0xFF151F32),
    Color(0xFF1E293B),
  ];
  
  static const List<Color> blueGradient = [
    Color(0xFF0D9488), // Teal
    Color(0xFF2DD4BF),
  ];

  static const List<Color> orangeGradient = [
    Color(0xFFEA580C), // Orange
    Color(0xFFF97316),
  ];

  static const List<Color> greenGradient = [
    Color(0xFF16A34A), // Green
    Color(0xFF4ADE80),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light, // Setup light theme configuration
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentLime,
        surface: surfaceDark,
        background: backgroundDark,
        error: Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: backgroundDark,
      dividerColor: Colors.black.withOpacity(0.08),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        titleLarge: GoogleFonts.poppins(
          color: textDarkPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        titleMedium: GoogleFonts.poppins(
          color: textDarkPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: textDarkPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: textDarkSecondary,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.black.withOpacity(0.06),
            width: 1.0,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDarkPrimary),
        titleTextStyle: TextStyle(
          color: textDarkPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white, // White text on green background
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white, // White icon on green button
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9), // Light grey fill
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.08), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.04), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        labelStyle: const TextStyle(color: textDarkSecondary, fontFamily: 'Poppins'),
        floatingLabelStyle: const TextStyle(color: primaryGreen, fontFamily: 'Poppins'),
      ),
    );
  }
}
