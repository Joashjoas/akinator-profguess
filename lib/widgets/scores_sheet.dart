import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';

/// Painel que mostra o "placar" da partida: a pontuação (probabilidade) atual
/// de cada professor e o que cada um responderia à pergunta em tela.
///
/// É aberto como bottom sheet a partir da tela de pergunta. Serve para
/// acompanhar/depurar como o motor de inferência está raciocinando.
class ScoresSheet extends StatelessWidget {
  final GameController controller;

  const ScoresSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final scores = controller.scores;
    final question = controller.currentQuestion;
    final leaderProb = scores.isEmpty ? 0.0 : scores.first.probability;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pontuações',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                question == null
                    ? 'Probabilidade atual de cada professor'
                    : '“${question.text}”',
                style: const TextStyle(fontSize: 13, color: Colors.white60),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: scores.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = scores[index];
                    final expected =
                        controller.expectedForCurrent(entry.professor);
                    return _ScoreRow(
                      rank: index + 1,
                      name: entry.professor.name,
                      probability: entry.probability,
                      leaderProb: leaderProb,
                      expected: expected,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Uma linha do placar: posição, nome, barra proporcional, % e o que o
/// professor responderia à pergunta atual (Sim/Não).
class _ScoreRow extends StatelessWidget {
  final int rank;
  final String name;
  final double probability;
  final double leaderProb;
  final double? expected;

  const _ScoreRow({
    required this.rank,
    required this.name,
    required this.probability,
    required this.leaderProb,
    required this.expected,
  });

  @override
  Widget build(BuildContext context) {
    // A barra é relativa ao líder, para a diferença ficar visível mesmo quando
    // todas as probabilidades são pequenas.
    final fraction =
        leaderProb <= 0 ? 0.0 : (probability / leaderProb).clamp(0.0, 1.0);
    final percent = (probability * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white54,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (expected != null) ...[
            _ExpectedChip(expected: expected!),
            const SizedBox(width: 10),
          ],
          SizedBox(
            width: 52,
            child: Text(
              '$percent%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pequeno selo que mostra o que o professor responderia à pergunta atual.
class _ExpectedChip extends StatelessWidget {
  final double expected;

  const _ExpectedChip({required this.expected});

  @override
  Widget build(BuildContext context) {
    final isYes = expected >= 0.5;
    final color = isYes ? const Color(0xFF34D399) : const Color(0xFFF87171);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        isYes ? 'Sim' : 'Não',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
