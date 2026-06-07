import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Barra que mostra o quanto o gênio já está confiante no palpite.
/// O texto acompanha o nível para dar um clima de "ele está chegando lá".
class ConfidenceBar extends StatelessWidget {
  final double confidence; // 0..1

  const ConfidenceBar({super.key, required this.confidence});

  String get _label {
    if (confidence < 0.25) return 'Ainda estou só começando a pensar...';
    if (confidence < 0.45) return 'Começando a suspeitar de alguém...';
    if (confidence < 0.70) return 'Acho que estou perto!';
    return 'Já tenho quase certeza!';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _label,
          style: const TextStyle(fontSize: 13, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: confidence.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 12,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
        ),
      ],
    );
  }
}
