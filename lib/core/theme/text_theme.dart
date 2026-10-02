import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  // Main text styles using GoogleFonts.afacad
  static TextStyle get displayLarge => GoogleFonts.afacad(
        fontWeight: FontWeight.w900,
        fontSize: 57,
        letterSpacing: -0.25,
      );

  static TextStyle get displayMedium => GoogleFonts.afacad(
        fontWeight: FontWeight.w900,
        fontSize: 45,
      );

  static TextStyle get displaySmall => GoogleFonts.afacad(
        fontWeight: FontWeight.w900,
        fontSize: 36,
      );

  static TextStyle get headlineLarge => GoogleFonts.afacad(
        fontWeight: FontWeight.w800,
        fontSize: 32,
      );

  static TextStyle get headlineMedium => GoogleFonts.afacad(
        fontWeight: FontWeight.w800,
        fontSize: 28,
      );

  static TextStyle get headlineSmall => GoogleFonts.afacad(
        fontWeight: FontWeight.w800,
        fontSize: 24,
      );

  static TextStyle get titleLarge => GoogleFonts.afacad(
        fontWeight: FontWeight.w700,
        fontSize: 22,
      );

  static TextStyle get titleMedium => GoogleFonts.afacad(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => GoogleFonts.afacad(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyLarge => GoogleFonts.afacad(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.afacad(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => GoogleFonts.afacad(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        letterSpacing: 0.4,
      );

  static TextStyle get labelLarge => GoogleFonts.afacad(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.afacad(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => GoogleFonts.afacad(
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 0.5,
      );

  // Custom styles for specific use cases
  static TextStyle get buttonLarge => GoogleFonts.afacad(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: 1.25,
      );

  static TextStyle get buttonMedium => GoogleFonts.afacad(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: 1.25,
      );

  static TextStyle get buttonSmall => GoogleFonts.afacad(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        letterSpacing: 1.25,
      );

  static TextStyle get caption => GoogleFonts.afacad(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        letterSpacing: 0.4,
      );

  static TextStyle get overline => GoogleFonts.afacad(
        fontWeight: FontWeight.w400,
        fontSize: 10,
        letterSpacing: 1.5,
      );
}