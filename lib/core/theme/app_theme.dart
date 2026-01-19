import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Duolingo-inspired Color Palette
  static const Color primaryGreen = Color(0xFF58CC02); // 58cc02
  static const Color duoGreen = Color(0xFF58CC02);
  static const Color duoDarkGreen = Color(0xFF46A302);
  static const Color duoBlue = Color(0xFF1CB0F6);
  static const Color duoDarkBlue = Color(0xFF1899D6);
  static const Color duoOrange = Color(0xFFFF9600);
  static const Color duoRed = Color(0xFFFF4B4B);
  static const Color duoYellow = Color(0xFFFFC800);
  static const Color duoGray = Color(0xFFAFAFAF);
  static const Color duoLightGray = Color(0xFFE5E5E5);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: duoGreen,
      primary: duoGreen,
      secondary: duoBlue,
      tertiary: duoOrange,
      error: duoRed,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: GoogleFonts.nunitoTextTheme().apply(
      bodyColor: const Color(0xFF4B4B4B),
      displayColor: const Color(0xFF4B4B4B),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: duoLightGray, width: 2),
      ),
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: duoGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ).copyWith(
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          return const BorderSide(color: duoDarkGreen, width: 2, strokeAlign: BorderSide.strokeAlignOutside);
        }),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: duoBlue,
        side: const BorderSide(color: duoLightGray, width: 2),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: duoLightGray, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: duoLightGray, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: duoBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: duoGreen,
      primary: duoGreen,
      secondary: duoBlue,
      surface: const Color(0xFF131F24),
    ),
    scaffoldBackgroundColor: const Color(0xFF131F24),
    textTheme: GoogleFonts.nunitoTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF37464F), width: 2),
      ),
      color: const Color(0xFF131F24),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF202F36),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF37464F), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF37464F), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: duoBlue, width: 2),
      ),
    ),
  );
}
