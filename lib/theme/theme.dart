import 'package:flutter/material.dart';
import 'colors.dart';

class QuerierTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: QuerierColors.primaryColor,
        secondary: QuerierColors.secondaryColor,
        background: QuerierColors.backgroundColor,
        surface: QuerierColors.cardBackground,
        onPrimary: QuerierColors.backgroundColor,
        onSecondary: QuerierColors.textColor,
        onBackground: QuerierColors.textColor,
        onSurface: QuerierColors.textColor,
      ),
      scaffoldBackgroundColor: QuerierColors.backgroundColor,
      cardTheme: CardTheme(
        color: QuerierColors.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: QuerierColors.cardBackground,
        foregroundColor: QuerierColors.textColor,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: QuerierColors.cardBackground,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: QuerierColors.primaryColor),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: QuerierColors.primaryColor),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: QuerierColors.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: QuerierColors.primaryColor,
          foregroundColor: QuerierColors.backgroundColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
