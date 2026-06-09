import 'package:flutter/material.dart';

import '../models/answer.dart';

/// Botão de uma das cinco respostas. Estilo "pill" tonal: fundo translúcido
/// na cor da resposta, com um ícone à esquerda. Mais leve e limpo que um
/// bloco totalmente preenchido, mantendo a pista de cor (sim → verde,
/// não → vermelho, intermediários no meio).
class AnswerButton extends StatelessWidget {
  final Answer answer;
  final VoidCallback onPressed;

  const AnswerButton({super.key, required this.answer, required this.onPressed});

  Color get _color {
    switch (answer) {
      case Answer.yes:
        return const Color(0xFF34D399);
      case Answer.probablyYes:
        return const Color(0xFF6EE7B7);
      case Answer.dontKnow:
        return const Color(0xFFA5B4FC);
      case Answer.probablyNo:
        return const Color(0xFFFBBF24);
      case Answer.no:
        return const Color(0xFFF87171);
    }
  }

  IconData get _icon {
    switch (answer) {
      case Answer.yes:
        return Icons.check_circle_rounded;
      case Answer.probablyYes:
        return Icons.thumb_up_alt_rounded;
      case Answer.dontKnow:
        return Icons.help_outline_rounded;
      case Answer.probablyNo:
        return Icons.thumb_down_alt_rounded;
      case Answer.no:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.18),
        highlightColor: color.withValues(alpha: 0.10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Icon(_icon, color: color, size: 22),
                const SizedBox(width: 14),
                Text(
                  answer.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
