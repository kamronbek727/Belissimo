import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color darkPurple = Color(0xFF2D0C33);
  static const Color pinkAccent = Color(0xFFD11A5B);
  static const Color bgGray = Color(0xFFF8F9FC);
  static const Color gold = Color(0xFFFFB300);
  static const Color textDark = Color(0xFF2C1A30);
  static const Color textMuted = Color(0xFF8E8A90);
  static const Color borderColor = Color(0xFFECE9F0);
  
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF4A0E4E), Color(0xFF2D0C33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFE62A70), Color(0xFFB50E4C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static double get radiusLarge => 24.0;
  static double get radiusMedium => 16.0;
  static double get radiusSmall => 12.0;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.pinkAccent,
      scaffoldBackgroundColor: AppColors.bgGray,
      colorScheme: const ColorScheme.light(
        primary: AppColors.pinkAccent,
        secondary: AppColors.darkPurple,
        background: AppColors.bgGray,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        bodyLarge: GoogleFonts.outfit(color: AppColors.textDark, fontSize: 16),
        bodyMedium: GoogleFonts.outfit(color: AppColors.textDark, fontSize: 14),
        titleLarge: GoogleFonts.outfit(color: AppColors.darkPurple, fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium: GoogleFonts.outfit(color: AppColors.darkPurple, fontWeight: FontWeight.w600, fontSize: 16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkPurple),
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.darkPurple,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: AppColors.borderColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: AppColors.pinkAccent, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 14),
      ),
    );
  }
}
