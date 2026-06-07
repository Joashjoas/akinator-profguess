import 'package:flutter/material.dart';

/// Paleta e tema do app. Mantemos as cores em um só lugar para ser fácil
/// ajustar a identidade visual.
class AppColors {
  static const Color indigo = Color(0xFF4F46E5);
  static const Color indigoLight = Color(0xFF7C73F0);
  static const Color lavender = Color(0xFFA5B4FC);
  static const Color ink = Color(0xFF1F2937);
  static const Color gold = Color(0xFFFBBF24);
  static const Color background = Color(0xFF1B1633);
  static const Color surface = Color(0xFF2A2350);
}

class AppTheme {
  static ThemeData build() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.indigo,
        secondary: AppColors.gold,
        surface: AppColors.surface,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.indigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
