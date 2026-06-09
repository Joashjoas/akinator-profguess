import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Barra que mostra o quanto o gênio já está confiante no palpite.
/// O texto acompanha o nível para dar um clima de "ele está chegando lá",
/// e a porcentagem à direita dá um retorno mais concreto.
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
    final value = confidence.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _label,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
        ),
      ],
    );
  }
}
