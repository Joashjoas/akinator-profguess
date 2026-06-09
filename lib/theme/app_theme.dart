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

  // Tons usados nas superfícies translúcidas (cards de vidro, botões tonais).
  static const Color backgroundTop = Color(0xFF241B45);
  static const Color backgroundBottom = Color(0xFF130F26);
  static const Color glass = Color(0x14FFFFFF); // branco ~8%
  static const Color glassBorder = Color(0x1FFFFFFF); // branco ~12%

  /// Gradiente de fundo do app, do topo (mais claro) para a base (mais escuro).
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundBottom],
  );
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
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
