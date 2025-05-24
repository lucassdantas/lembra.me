// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Cores personalizadas
  static const Color blue = Color(0xFF9CCFEC);
  static const Color middleBlue = Color(0xFF5487B0);
  static const Color darkBlue = Color(0xFF3A4E5C);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: white,
      primaryColor: middleBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: blue,
        primary: middleBlue,
        secondary: blue,
        background: white,
        onPrimary: white,
        onSecondary: black,
        onBackground: black,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: darkBlue, foregroundColor: white),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: middleBlue, foregroundColor: white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkBlue,
        foregroundColor: white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: darkBlue)),
        border: OutlineInputBorder(),
      ),
    );
  }
}
