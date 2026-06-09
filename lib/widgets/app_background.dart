import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fundo padrão do app: um gradiente suave com um brilho discreto no topo,
/// onde costuma ficar o mascote. Deixa as telas com um ar mais "profundo"
/// e coeso sem poluir o conteúdo.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        children: [
          // Halo indigo translúcido atrás do mascote.
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.indigoLight.withValues(alpha: 0.25),
                      AppColors.indigoLight.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
