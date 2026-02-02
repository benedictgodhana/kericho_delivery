import 'package:flutter/material.dart';
import 'text_theme.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00B14F);
  static const Color secondaryColor = Color(0xFFFFD600);
  static const Color accentColor = Color(0xFFFF6B00);
  static const Color kerichoGreen = Color(0xFF1A5632);
  static const Color teaGreen = Color(0xFF8BC34A);

  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFFADB5BD);

  static const Color successColor = Color(0xFF28A745);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFDC3545);
  static const Color infoColor = Color(0xFF17A2B8);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    primarySwatch: createMaterialColor(primaryColor),
    scaffoldBackgroundColor: scaffoldBackground,
    cardColor: cardColor,
    fontFamily: 'BrandonGrotesque',
    
    textTheme: TextTheme(
      displayLarge: AppTextTheme.displayLarge.copyWith(color: textPrimary),
      displayMedium: AppTextTheme.displayMedium.copyWith(color: textPrimary),
      displaySmall: AppTextTheme.displaySmall.copyWith(color: textPrimary),
      headlineLarge: AppTextTheme.headlineLarge.copyWith(color: textPrimary),
      headlineMedium: AppTextTheme.headlineMedium.copyWith(color: textPrimary),
      headlineSmall: AppTextTheme.headlineSmall.copyWith(color: textPrimary),
      titleLarge: AppTextTheme.titleLarge.copyWith(color: textPrimary),
      titleMedium: AppTextTheme.titleMedium.copyWith(color: textPrimary),
      titleSmall: AppTextTheme.titleSmall.copyWith(color: textPrimary),
      bodyLarge: AppTextTheme.bodyLarge.copyWith(color: textPrimary),
      bodyMedium: AppTextTheme.bodyMedium.copyWith(color: textPrimary),
      bodySmall: AppTextTheme.bodySmall.copyWith(color: textSecondary),
      labelLarge: AppTextTheme.labelLarge.copyWith(color: textPrimary),
      labelMedium: AppTextTheme.labelMedium.copyWith(color: textPrimary),
      labelSmall: AppTextTheme.labelSmall.copyWith(color: textSecondary),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'BrandonGrotesque',
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: textPrimary,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: AppTextTheme.buttonLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: AppTextTheme.buttonMedium,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: const BorderSide(color: primaryColor),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      hintStyle: AppTextTheme.bodyMedium.copyWith(color: textTertiary),
      labelStyle: AppTextTheme.labelMedium.copyWith(color: textSecondary),
    ),
    
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF8F9FA),
      selectedColor: primaryColor,
      labelStyle: AppTextTheme.labelSmall,
      secondaryLabelStyle: AppTextTheme.labelSmall.copyWith(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    ),
  );


 static final ThemeData simpleLightTheme = ThemeData(
    brightness: Brightness.light,
    // Add your light theme customizations here
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    // Add your dark theme customizations here
  );
  // Helper to create MaterialColor from a Color
  static MaterialColor createMaterialColor(Color color) {
    List<double> strengths = [.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}