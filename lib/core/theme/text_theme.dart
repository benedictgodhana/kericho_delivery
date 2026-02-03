import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  // Main text styles using GoogleFonts.lexend
  static TextStyle get displayLarge => GoogleFonts.lexend(
        fontWeight: FontWeight.w900,
        fontSize: 57,
        letterSpacing: -0.25,
      );

  static TextStyle get displayMedium => GoogleFonts.lexend(
        fontWeight: FontWeight.w900,
        fontSize: 45,
      );

  static TextStyle get displaySmall => GoogleFonts.lexend(
        fontWeight: FontWeight.w900,
        fontSize: 36,
      );

  static TextStyle get headlineLarge => GoogleFonts.lexend(
        fontWeight: FontWeight.w800,
        fontSize: 32,
      );

  static TextStyle get headlineMedium => GoogleFonts.lexend(
        fontWeight: FontWeight.w800,
        fontSize: 28,
      );

  static TextStyle get headlineSmall => GoogleFonts.lexend(
        fontWeight: FontWeight.w800,
        fontSize: 24,
      );

  static TextStyle get titleLarge => GoogleFonts.lexend(
        fontWeight: FontWeight.w700,
        fontSize: 22,
      );

  static TextStyle get titleMedium => GoogleFonts.lexend(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => GoogleFonts.lexend(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyLarge => GoogleFonts.lexend(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.lexend(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => GoogleFonts.lexend(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        letterSpacing: 0.4,
      );

  static TextStyle get labelLarge => GoogleFonts.lexend(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.lexend(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => GoogleFonts.lexend(
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 0.5,
      );

  // Custom styles for specific use cases
  static TextStyle get buttonLarge => GoogleFonts.lexend(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: 1.25,
      );

  static TextStyle get buttonMedium => GoogleFonts.lexend(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: 1.25,
      );

  static TextStyle get buttonSmall => GoogleFonts.lexend(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        letterSpacing: 1.25,
      );

  static TextStyle get caption => GoogleFonts.lexend(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        letterSpacing: 0.4,
      );

  static TextStyle get overline => GoogleFonts.lexend(
        fontWeight: FontWeight.w400,
        fontSize: 10,
        letterSpacing: 1.5,
      );
}