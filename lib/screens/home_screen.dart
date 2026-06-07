import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../widgets/mascot.dart';

/// Tela inicial: nome, mascote, uma explicação curta e o botão "Começar".
class HomeScreen extends StatelessWidget {
  final GameController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Mascot(expression: MascotExpression.neutral, size: 240),
              const SizedBox(height: 8),
              const Text(
                'ProfGuess',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pense em um professor do curso de ADS.\n'
                'Vou fazer algumas perguntas e tentar adivinhar quem é!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: controller.start,
                child: const Text('Começar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
