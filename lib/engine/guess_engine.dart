import 'dart:math' as math;

import '../models/answer.dart';
import '../models/professor.dart';
import '../models/question.dart';

/// Motor de inferência do ProfGuess.
///
/// É uma inferência bayesiana simplificada: cada professor começa com a mesma
/// probabilidade e, a cada resposta, multiplicamos essa probabilidade pela
/// verossimilhança da resposta dada. Depois normalizamos para que a soma volte
/// a ser 1. A próxima pergunta é escolhida pela que melhor "divide" os suspeitos
/// (maior variância ponderada), então a ordem das perguntas muda a cada partida.
///
/// Esta classe é Dart puro — não importa nada do Flutter — para poder ser
/// testada isoladamente e explicada com tranquilidade na apresentação.
class GuessEngine {
  GuessEngine({
    required List<Professor> professors,
    required List<Question> questions,
  })  : _professors = List.unmodifiable(professors),
        _questions = List.unmodifiable(questions) {
    reset();
  }

  final List<Professor> _professors;
  final List<Question> _questions;

  /// Probabilidade atual de cada professor, indexada pelo id.
  late Map<String, double> _probabilities;

  /// Perguntas que já foram feitas nesta partida (não se repetem).
  final Set<String> _askedQuestionIds = <String>{};

  /// Piso de verossimilhança: ninguém é eliminado por uma única contradição.
  static const double _likelihoodFloor = 0.05;

  /// Abaixo deste poder discriminativo, perguntar mais não ajuda: palpite.
  static const double _minDiscriminativeScore = 0.01;

  /// Limite rígido de perguntas por partida.
  static const int _maxQuestions = 15;

  /// Quantas perguntas no mínimo antes de aceitar um palpite por confiança.
  static const int _minQuestionsBeforeGuess = 6;

  /// Confiança mínima do líder para palpitar antecipadamente.
  static const double _confidenceThreshold = 0.70;

  int _questionsAsked = 0;
  int get questionsAsked => _questionsAsked;

  /// Reinicia a partida: probabilidades uniformes e nenhuma pergunta feita.
  void reset() {
    final uniform = _professors.isEmpty ? 0.0 : 1.0 / _professors.length;
    _probabilities = {for (final p in _professors) p.id: uniform};
    _askedQuestionIds.clear();
    _questionsAsked = 0;
  }

  /// Professores que ainda têm chance de serem o escolhido (P > 0).
  List<Professor> get _viableProfessors =>
      _professors.where((p) => (_probabilities[p.id] ?? 0) > 0).toList();

  bool get hasViableCandidates => _viableProfessors.isNotEmpty;

  /// Professor com a maior probabilidade no momento.
  Professor get currentGuess {
    var leader = _professors.first;
    var best = _probabilities[leader.id] ?? 0;
    for (final p in _professors) {
      final prob = _probabilities[p.id] ?? 0;
      if (prob > best) {
        best = prob;
        leader = p;
      }
    }
    return leader;
  }

  /// Probabilidade do líder atual — usada na barra de confiança e no mascote.
  double get confidence => _probabilities[currentGuess.id] ?? 0;

  /// Atualiza as probabilidades com a resposta dada para uma pergunta.
  ///
  /// likelihood(p) = max(0.05, 1 - |u - e(p,q)|)
  /// P(p) <- P(p) * likelihood(p), depois normaliza.
  void submitAnswer(Question question, Answer answer) {
    if (_askedQuestionIds.contains(question.id)) return;

    final u = answer.value;
    for (final p in _professors) {
      final current = _probabilities[p.id] ?? 0;
      if (current <= 0) continue; // candidato já eliminado
      final expected = p.expected(question.id);
      final likelihood = math.max(_likelihoodFloor, 1 - (u - expected).abs());
      _probabilities[p.id] = current * likelihood;
    }

    _normalize();
    _askedQuestionIds.add(question.id);
    _questionsAsked++;
  }

  /// Próxima pergunta a fazer, ou `null` quando é hora de palpitar.
  ///
  /// Escolhe a pergunta ainda não feita com maior variância ponderada das
  /// respostas esperadas — a que mais separa os candidatos prováveis.
  Question? nextQuestion() {
    if (shouldGuess) return null;

    Question? best;
    var bestScore = double.negativeInfinity;

    for (final q in _questions) {
      if (_askedQuestionIds.contains(q.id)) continue;

      // Média esperada ponderada pelas probabilidades atuais.
      var mean = 0.0;
      for (final p in _professors) {
        mean += (_probabilities[p.id] ?? 0) * p.expected(q.id);
      }

      // Variância ponderada em torno dessa média.
      var score = 0.0;
      for (final p in _professors) {
        final diff = p.expected(q.id) - mean;
        score += (_probabilities[p.id] ?? 0) * diff * diff;
      }

      if (score > bestScore) {
        bestScore = score;
        best = q;
      }
    }

    // Se nenhuma pergunta restante discrimina mais nada, vamos para o palpite.
    if (best == null || bestScore < _minDiscriminativeScore) return null;
    return best;
  }

  /// Verdadeiro quando o motor já tem confiança (ou perguntas) suficiente.
  ///
  /// (perguntas >= 6 E P(líder) >= 0.70 E P(líder) >= 2 x P(vice))
  ///   ou (perguntas >= 15)
  bool get shouldGuess {
    if (_questionsAsked >= _maxQuestions) return true;
    if (_questionsAsked < _minQuestionsBeforeGuess) return false;

    final leaderProb = confidence;
    final runnerUpProb = _runnerUpProbability();
    return leaderProb >= _confidenceThreshold &&
        leaderProb >= 2 * runnerUpProb;
  }

  /// Chamado quando o jogador diz que o palpite estava errado: elimina o
  /// professor e redistribui a probabilidade entre os restantes.
  void rejectGuess(Professor professor) {
    _probabilities[professor.id] = 0;
    _normalize();
  }

  // -- Helpers internos ----------------------------------------------------

  void _normalize() {
    final total = _probabilities.values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return; // nada a normalizar (todos zerados)
    _probabilities.updateAll((_, value) => value / total);
  }

  double _runnerUpProbability() {
    final leaderId = currentGuess.id;
    var second = 0.0;
    _probabilities.forEach((id, prob) {
      if (id != leaderId && prob > second) second = prob;
    });
    return second;
  }
}
