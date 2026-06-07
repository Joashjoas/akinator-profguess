import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../widgets/mascot.dart';

/// Tela final. Tem três variações dependendo do estado:
///  - GUESSING: o gênio arrisca o palpite (acertou / errou).
///  - WON: comemoração.
///  - LOST: derrota elegante.
class ResultScreen extends StatelessWidget {
  final GameController controller;

  const ResultScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildContent(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    switch (controller.status) {
      case GameStatus.guessing:
        return _guessing();
      case GameStatus.won:
        return _won();
      case GameStatus.lost:
        return _lost();
      default:
        return const [SizedBox.shrink()];
    }
  }

  List<Widget> _guessing() {
    return [
      Mascot(expression: controller.mascotExpression, size: 260),
      const SizedBox(height: 16),
      const Text(
        'Você está pensando em...',
        style: TextStyle(fontSize: 18, color: Colors.white70),
      ),
      const SizedBox(height: 8),
      Text(
        '${controller.currentGuess.name}!',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 32),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: controller.confirmCorrect,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E)),
            child: const Text('Acertou! 🎉'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: controller.rejectGuess,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Errou 😅'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _won() {
    return [
      Mascot(expression: MascotExpression.celebrating, size: 260),
      const SizedBox(height: 16),
      const Text(
        'Eu sabia! 🎓',
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        'Adivinhei em ${controller.questionsAsked} '
        '${controller.questionsAsked == 1 ? 'pergunta' : 'perguntas'}.',
        style: const TextStyle(fontSize: 16, color: Colors.white70),
      ),
      const SizedBox(height: 32),
      _playAgainButton(),
    ];
  }

  List<Widget> _lost() {
    return [
      const Mascot(expression: MascotExpression.sad, size: 260),
      const SizedBox(height: 16),
      const Text(
        'Você me venceu! 🏳️',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text(
        'Dessa vez não consegui descobrir.\nMe dê outra chance?',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.4),
      ),
      const SizedBox(height: 32),
      _playAgainButton(),
    ];
  }

  Widget _playAgainButton() {
    return ElevatedButton(
      onPressed: controller.reset,
      child: const Text('Jogar novamente'),
    );
  }
}
