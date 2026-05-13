import 'package:flutter/material.dart';


class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  static const Color lightBackground = Color(0xFFFDFCF8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFFF28C28);
  static const Color lightSecondary = Color(0xFFE67E22);
  static const Color lightTextPrimary = Color(0xFF2D2926);
  static const Color lightTextSecondary = Color(0xFF6D675B);
  static const Color lightBorder = Color(0xFFE5E2D9);

  // ============ DARK MODE ============
  static const Color darkBackground = Color(0xFF1A1918);
  static const Color darkSurface = Color(0xFF252422);
  static const Color darkPrimary = Color(0xFFFFB347);
  static const Color darkSecondary = Color(0xFFF39C12);
  static const Color darkTextPrimary = Color(0xFFEEEBE6);
  static const Color darkTextSecondary = Color(0xFFB0A99F);
  static const Color darkBorder = Color(0xFF3D3B38);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        surface: lightSurface,
        primary: lightPrimary,
        secondary: lightSecondary,
        error: const Color(0xFFB3261E),
        onSurface: lightTextPrimary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: lightSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: lightTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        surface: darkSurface,
        primary: darkPrimary,
        secondary: darkSecondary,
        error: const Color(0xFFF9DEDC),
        onSurface: darkTextPrimary,
        onPrimary: darkBackground,
        onSecondary: darkBackground,
      ),
      scaffoldBackgroundColor: darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
