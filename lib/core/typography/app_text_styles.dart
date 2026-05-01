import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography system for NEST
/// Uses custom font families: Quicksand, Montserrat, Inter
class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  // ============ HEADING ============
  /// Quicksand 700 (Bold)
  /// Use for: screen titles, section headers, post titles, prominent display text
  static TextStyle heading(
    BuildContext context, {
    Color? color,
    double? fontSize,
  }) {
    return GoogleFonts.quicksand(
      fontWeight: FontWeight.w700,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      fontSize: fontSize ?? 28,
    );
  }

  // ============ SUBHEADING ============
  /// Montserrat 400 (Regular)
  /// Use for: card labels, usernames, tab labels, secondary titles
  static TextStyle subheading(
    BuildContext context, {
    Color? color,
    double? fontSize,
  }) {
    return GoogleFonts.montserrat(
      fontWeight: FontWeight.w400,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      fontSize: fontSize ?? 16,
    );
  }

  // ============ BODY ============
  /// Inter 400 (Regular)
  /// Use for: post content, captions, descriptions, input fields, general-purpose readable text
  static TextStyle body(
    BuildContext context, {
    Color? color,
    double? fontSize,
  }) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      fontSize: fontSize ?? 14,
    );
  }
}
