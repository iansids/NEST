import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography system for NEST app
/// Uses three font families: Quicksand (headings), Montserrat (subheadings), Inter (body)
class AppTextStyles {
  /// Heading style - Quicksand Bold (700)
  /// Used for titles, "NEST" app name, section headers
  static TextStyle heading(
    BuildContext context, {
    Color? color,
    double? fontSize,
  }) {
    return GoogleFonts.quicksand(
      fontSize: fontSize ?? 28,
      fontWeight: FontWeight.w700,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Subheading style - Montserrat Regular (400)
  /// Used for buttons, labels, form titles, user names
  static TextStyle subheading(
    BuildContext context, {
    Color? color,
    double? fontSize,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize ?? 16,
      fontWeight: FontWeight.w400,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Body style - Inter Regular (400)
  /// Used for content, descriptions, form hints, post text
  static TextStyle body(
    BuildContext context, {
    Color? color,
    double? fontSize,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? 14,
      fontWeight: FontWeight.w400,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }
}
