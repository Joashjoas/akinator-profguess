import 'package:flutter/material.dart';

import 'controllers/game_controller.dart';
import 'screens/home_screen.dart';
import 'screens/question_screen.dart';
import 'screens/result_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_background.dart';

void main() {
  runApp(const ProfGuessApp());
}

class ProfGuessApp extends StatelessWidget {
  const ProfGuessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProfGuess',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const GameRoot(),
    );
  }
}

/// Mantém o [GameController] vivo e troca a tela conforme o estado da partida.
class GameRoot extends StatefulWidget {
  const GameRoot({super.key});

  @override
  State<GameRoot> createState() => _GameRootState();
}

class _GameRootState extends State<GameRoot> {
  final GameController _controller = GameController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final screen = _screenFor(_controller.status);
            // Transição suave entre as telas.
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: KeyedSubtree(
                key: ValueKey(_screenKey(_controller.status)),
                child: screen,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _screenFor(GameStatus status) {
    switch (status) {
      case GameStatus.home:
        return HomeScreen(controller: _controller);
      case GameStatus.asking:
        return QuestionScreen(controller: _controller);
      case GameStatus.guessing:
      case GameStatus.won:
      case GameStatus.lost:
        return ResultScreen(controller: _controller);
    }
  }

  // As telas de resultado compartilham a mesma "página" para não animar à toa
  // na transição guessing → won/lost.
  String _screenKey(GameStatus status) {
    switch (status) {
      case GameStatus.home:
        return 'home';
      case GameStatus.asking:
        return 'asking';
      case GameStatus.guessing:
      case GameStatus.won:
      case GameStatus.lost:
        return 'result';
    }
  }
}
