import 'package:flutter/material.dart';

import '../models/answer.dart';
import '../theme/app_theme.dart';

/// Botão de uma das cinco respostas. A cor varia um pouco entre "sim",
/// "não" e os intermediários para dar uma pista visual rápida.
class AnswerButton extends StatelessWidget {
  final Answer answer;
  final VoidCallback onPressed;

  const AnswerButton({super.key, required this.answer, required this.onPressed});

  Color get _color {
    switch (answer) {
      case Answer.yes:
        return const Color(0xFF22C55E);
      case Answer.probablyYes:
        return const Color(0xFF4ADE80);
      case Answer.dontKnow:
        return AppColors.lavender;
      case Answer.probablyNo:
        return const Color(0xFFF59E0B);
      case Answer.no:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _color,
          foregroundColor: AppColors.ink,
        ),
        child: Text(answer.label),
      ),
    );
  }
}
