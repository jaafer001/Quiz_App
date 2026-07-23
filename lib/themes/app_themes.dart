import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF4F7FA);
  static const Color primary = Color(0xFF3A5BB2);
  static const Color accent = Color(0xFF6BB9F0);
  static const Color focusDepth = Color(0xFF2D4B7A);
  static const Color tealGrey = Color(0xFF7A9FA8);
  static const Color coolSlate = Color(0xFF5D6D8A);
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,

      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: tealGrey,
        tertiary: accent,
        surface: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),


      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }
}