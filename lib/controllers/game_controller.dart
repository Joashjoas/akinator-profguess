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

  /// "Placar" atual: probabilidade (pontuação) de cada professor, da maior para
  /// a menor. A UI usa isso para mostrar como cada candidato está se saindo.
  List<({Professor professor, double probability})> get scores =>
      _engine.scores;

  /// Quanto a pergunta atual "espera" de cada professor: 1.0 = ele responderia
  /// sim, 0.0 = não. Usado para exibir, no placar, o que cada candidato diria à
  /// pergunta em tela. Retorna null quando não há pergunta ativa.
  double? expectedForCurrent(Professor professor) {
    final question = _currentQuestion;
    if (question == null) return null;
    return professor.expected(question.id);
  }

  /// Limite de perguntas por partida (para exibir "Pergunta X de até N").
  int get maxQuestions => GuessEngine.maxQuestions;

  /// Pode voltar para a pergunta anterior?
  bool get canGoBack => _status == GameStatus.asking && _engine.canUndo;

  /// Frases curtas que justificam o palpite atual, montadas a partir das
  /// características que o jogador confirmou e que o professor possui.
  /// Vazio quando não há nada marcante a destacar.
  List<String> get guessReasons {
    final guess = currentGuess;
    final reasons = <String>[];
    for (final step in _engine.history) {
      final confirmed =
          step.answer == Answer.yes || step.answer == Answer.probablyYes;
      final hasTrait = guess.expected(step.question.id) >= 0.5;
      if (confirmed && hasTrait && step.question.trait.isNotEmpty) {
        reasons.add(step.question.trait);
      }
    }
    return reasons;
  }

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

  /// Volta para a pergunta anterior, desfazendo a última resposta.
  void goBack() {
    if (!canGoBack) return;
    _engine.undoLast();
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

    if (_engine.canContinue) {
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
