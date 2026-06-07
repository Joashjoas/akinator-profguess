import 'package:flutter/foundation.dart';

import '../data/knowledge_base.dart';
import '../engine/guess_engine.dart';
import '../models/answer.dart';
import '../models/professor.dart';
import '../models/question.dart';
import '../widgets/mascot.dart';

/// Em que ponto da partida estamos.
enum GameStatus { home, asking, guessing, won, lost }

/// Liga o motor de inferência à interface. A UI só conversa com este
/// controller: ela lê o estado e chama métodos de ação, sem conhecer os
/// detalhes do algoritmo.
class GameController extends ChangeNotifier {
  GameController()
      : _engine = GuessEngine(professors: professors, questions: questions);

  final GuessEngine _engine;

  GameStatus _status = GameStatus.home;
  GameStatus get status => _status;

  Question? _currentQuestion;
  Question? get currentQuestion => _currentQuestion;

  /// Número da pergunta atual para exibir ("Pergunta 3").
  int get questionNumber => _engine.questionsAsked + 1;

  /// Confiança do líder atual (0..1), usada na barra e no mascote.
  double get confidence => _engine.confidence;

  /// O palpite atual do motor.
  Professor get currentGuess => _engine.currentGuess;

  int get questionsAsked => _engine.questionsAsked;

  /// Inicia uma nova partida do zero.
  void start() {
    _engine.reset();
    _status = GameStatus.asking;
    _advance();
  }

  /// Registra a resposta do jogador à pergunta atual e segue o fluxo.
  void answer(Answer answer) {
    final question = _currentQuestion;
    if (question == null || _status != GameStatus.asking) return;
    _engine.submitAnswer(question, answer);
    _advance();
  }

  /// O jogador confirmou que o palpite estava certo.
  void confirmCorrect() {
    if (_status != GameStatus.guessing) return;
    _status = GameStatus.won;
    notifyListeners();
  }

  /// O jogador disse que o palpite estava errado.
  ///
  /// Elimina o professor palpitado. Se ainda houver candidatos viáveis e não
  /// tivermos esgotado as perguntas, voltamos a perguntar; senão, derrota.
  void rejectGuess() {
    if (_status != GameStatus.guessing) return;
    _engine.rejectGuess(currentGuess);

    if (_engine.hasViableCandidates && _engine.questionsAsked < 15) {
      _status = GameStatus.asking;
      _advance();
    } else {
      _status = GameStatus.lost;
      notifyListeners();
    }
  }

  /// Volta para a tela inicial com o estado limpo.
  void reset() {
    _engine.reset();
    _currentQuestion = null;
    _status = GameStatus.home;
    notifyListeners();
  }

  /// Decide se faz a próxima pergunta ou se é hora do palpite.
  void _advance() {
    final next = _engine.nextQuestion();
    if (next == null) {
      _currentQuestion = null;
      _status = GameStatus.guessing;
    } else {
      _currentQuestion = next;
      _status = GameStatus.asking;
    }
    notifyListeners();
  }

  /// Mapeia o estado atual do jogo para a expressão do mascote.
  MascotExpression get mascotExpression {
    switch (_status) {
      case GameStatus.home:
        return MascotExpression.neutral;
      case GameStatus.asking:
        if (confidence < 0.40) return MascotExpression.thinking;
        if (confidence < 0.70) return MascotExpression.suspicious;
        return MascotExpression.confident;
      case GameStatus.guessing:
        return MascotExpression.confident;
      case GameStatus.won:
        return MascotExpression.celebrating;
      case GameStatus.lost:
        return MascotExpression.sad;
    }
  }
}
