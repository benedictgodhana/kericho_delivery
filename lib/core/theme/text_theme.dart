import 'package:flutter/material.dart';

class AppTextTheme {
  // Main text styles using Brandon Grotesque
  static TextStyle get displayLarge => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w900,
        fontSize: 57,
        letterSpacing: -0.25,
      );

  static TextStyle get displayMedium => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w900,
        fontSize: 45,
      );

  static TextStyle get displaySmall => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w900,
        fontSize: 36,
      );

  static TextStyle get headlineLarge => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w800,
        fontSize: 32,
      );

  static TextStyle get headlineMedium => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w800,
        fontSize: 28,
      );

  static TextStyle get headlineSmall => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w800,
        fontSize: 24,
      );

  static TextStyle get titleLarge => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w700,
        fontSize: 22,
      );

  static TextStyle get titleMedium => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w400,
        fontSize: 16,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w400,
        fontSize: 12,
        letterSpacing: 0.4,
      );

  static TextStyle get labelLarge => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 0.5,
      );

  // Custom styles for specific use cases
  static TextStyle get buttonLarge => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: 1.25,
      );

  static TextStyle get buttonMedium => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: 1.25,
      );

  static TextStyle get buttonSmall => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w700,
        fontSize: 13,
        letterSpacing: 1.25,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w500,
        fontSize: 12,
        letterSpacing: 0.4,
      );

  static TextStyle get overline => const TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w400,
        fontSize: 10,
        letterSpacing: 1.5,
      );
}