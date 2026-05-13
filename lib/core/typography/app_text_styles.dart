import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppTextStyles {
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
