import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/answer.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../widgets/answer_button.dart';
import '../widgets/confidence_bar.dart';
import '../widgets/mascot.dart';
import '../widgets/scores_sheet.dart';

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

  /// Abre o painel com o placar (pontuação de cada professor).
  void _showScores(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScoresSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = controller.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        // Em telas baixas o conteúdo passa a rolar em vez de "estourar"; em
        // telas normais o ConstrainedBox garante a altura mínima e o Expanded
        // abaixo continua distribuindo o espaço como antes.
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: _buildContent(context, question),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Question question) {
    return Column(
          children: [
            // Barra superior: "Voltar" à esquerda (cancela a resposta anterior
            // e volta para a pergunta), "Pontuações" à direita.
            Row(
              children: [
                // Ocupa o espaço mesmo quando invisível, para o layout não
                // "pular" entre a primeira pergunta e as seguintes.
                Opacity(
                  opacity: controller.canGoBack ? 1 : 0,
                  child: TextButton.icon(
                    onPressed: controller.canGoBack ? controller.goBack : null,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Voltar'),
                    style:
                        TextButton.styleFrom(foregroundColor: Colors.white70),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showScores(context),
                  icon: const Icon(Icons.leaderboard_outlined, size: 18),
                  label: const Text('Pontuações'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                ),
              ],
            ),
            Mascot(expression: controller.mascotExpression, size: 120),
            const SizedBox(height: 14),
            ConfidenceBar(confidence: controller.confidence),
            const SizedBox(height: 16),
            _StepChip(
              current: controller.questionNumber,
              total: controller.maxQuestions,
            ),
            const SizedBox(height: 12),
            // AnimatedSwitcher faz a pergunta trocar com um fade suave.
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _QuestionCard(
                  key: ValueKey(question.id),
                  text: question.text,
                ),
              ),
            ),
            const SizedBox(height: 4),
            for (final answer in _answers) ...[
              AnswerButton(
                answer: answer,
                onPressed: () => controller.answer(answer),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
  }
}

/// Indicador discreto "Pergunta X de até Y" em forma de chip.
class _StepChip extends StatelessWidget {
  final int current;
  final int total;

  const _StepChip({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(
        'Pergunta $current de até $total',
        style: const TextStyle(
          fontSize: 12.5,
          color: Colors.white60,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Card translúcido que envolve o texto da pergunta.
class _QuestionCard extends StatelessWidget {
  final String text;

  const _QuestionCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
