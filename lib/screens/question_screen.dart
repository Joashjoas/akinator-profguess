import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/answer.dart';
import '../widgets/answer_button.dart';
import '../widgets/confidence_bar.dart';
import '../widgets/mascot.dart';

/// Tela de pergunta: o mascote em cima, a pergunta atual e os cinco botões.
class QuestionScreen extends StatelessWidget {
  final GameController controller;

  const QuestionScreen({super.key, required this.controller});

  // Ordem fixa exigida pela atividade.
  static const _answers = [
    Answer.yes,
    Answer.probablyYes,
    Answer.dontKnow,
    Answer.probablyNo,
    Answer.no,
  ];

  @override
  Widget build(BuildContext context) {
    final question = controller.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Mascot(expression: controller.mascotExpression, size: 140),
            const SizedBox(height: 12),
            ConfidenceBar(confidence: controller.confidence),
            const SizedBox(height: 20),
            Text(
              'Pergunta ${controller.questionNumber}',
              style: const TextStyle(fontSize: 14, color: Colors.white54),
            ),
            const SizedBox(height: 8),
            // AnimatedSwitcher faz a pergunta trocar com um fade suave.
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Center(
                  key: ValueKey(question.id),
                  child: Text(
                    question.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
            for (final answer in _answers) ...[
              AnswerButton(
                answer: answer,
                onPressed: () => controller.answer(answer),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
