import 'package:flutter/material.dart';

/// Centralized color palette for NEST app
/// Supports both Light and Dark modes with warm, grounded aesthetic
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ============ LIGHT MODE ============
  static const Color lightBackground = Color(0xFFFDFCF8); // Soft Cream
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White
  static const Color lightPrimary = Color(0xFFF28C28); // Sunset Orange
  static const Color lightSecondary = Color(0xFFE67E22); // Terracotta
  static const Color lightTextPrimary = Color(0xFF2D2926); // Deep Coffee
  static const Color lightTextSecondary = Color(0xFF6D675B); // Taupe
  static const Color lightBorder = Color(0xFFE5E2D9); // Stone

  // ============ DARK MODE ============
  static const Color darkBackground = Color(0xFF1A1918); // Warm Charcoal
  static const Color darkSurface = Color(0xFF252422); // Soft Ebony
  static const Color darkPrimary = Color(0xFFFFB347); // Pastel Orange
  static const Color darkSecondary = Color(0xFFF39C12); // Honey
  static const Color darkTextPrimary = Color(0xFFEEEBE6); // Off-White
  static const Color darkTextSecondary = Color(0xFFB0A99F); // Warm Grey
  static const Color darkBorder = Color(0xFF3D3B38); // Deep Stone

  // ============ THEME DATA ============

  /// Light theme configuration
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

  /// Dark theme configuration
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
