import 'dart:math' as math;

import '../models/answer.dart';
import '../models/professor.dart';
import '../models/question.dart';

/// Motor de inferência do ProfGuess.
///
/// É uma inferência bayesiana: cada professor começa com a mesma probabilidade
/// e, a cada resposta, multiplicamos essa probabilidade pela verossimilhança da
/// resposta dada; depois normalizamos para que a soma volte a 1.
///
/// A próxima pergunta é escolhida por **ganho de informação** (redução de
/// entropia): simulamos as respostas "sim" e "não" para cada pergunta ainda não
/// feita e escolhemos a que mais reduz a incerteza sobre quem é o professor.
/// Por isso a ordem das perguntas muda a cada partida e tende a separar até os
/// candidatos mais parecidos.
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

  /// Histórico de respostas, para permitir "voltar" uma pergunta. O undo
  /// recalcula tudo do zero reaplicando este histórico — simples e sempre
  /// consistente.
  final List<({Question question, Answer answer})> _history = [];

  /// Piso de verossimilhança: ninguém é eliminado por uma única contradição.
  static const double _likelihoodFloor = 0.05;

  /// Abaixo deste ganho de informação (em bits), perguntar mais não ajuda.
  static const double _minInfoGain = 1e-4;

  /// Limite rígido de perguntas por partida.
  static const int maxQuestions = 15;

  /// Quantas perguntas no mínimo antes de aceitar um palpite por confiança.
  static const int _minQuestionsBeforeGuess = 6;

  /// Confiança mínima do líder para palpitar antecipadamente.
  static const double _confidenceThreshold = 0.70;

  int _questionsAsked = 0;
  int get questionsAsked => _questionsAsked;

  /// Respostas dadas até agora, na ordem (somente leitura). Usado pela UI para
  /// explicar o palpite.
  List<({Question question, Answer answer})> get history =>
      List.unmodifiable(_history);

  /// Reinicia a partida: probabilidades uniformes e nenhuma pergunta feita.
  void reset() {
    final uniform = _professors.isEmpty ? 0.0 : 1.0 / _professors.length;
    _probabilities = {for (final p in _professors) p.id: uniform};
    _askedQuestionIds.clear();
    _history.clear();
    _questionsAsked = 0;
  }

  /// Professores que ainda têm chance de serem o escolhido (P > 0).
  List<Professor> get _viableProfessors =>
      _professors.where((p) => (_probabilities[p.id] ?? 0) > 0).toList();

  bool get hasViableCandidates => _viableProfessors.isNotEmpty;

  /// Ainda dá para continuar perguntando? (há candidatos e não estouramos o
  /// limite de perguntas).
  bool get canContinue =>
      hasViableCandidates && _questionsAsked < maxQuestions;

  /// É possível desfazer a última resposta?
  bool get canUndo => _history.isNotEmpty;

  /// Professor com a maior probabilidade no momento. Em caso de empate, vence
  /// quem aparece primeiro na lista (ordem determinística e estável).
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

  /// "Placar" atual: a probabilidade (pontuação) de cada professor, ordenada da
  /// maior para a menor. Usado pela tela que mostra como cada candidato está se
  /// saindo durante a partida.
  List<({Professor professor, double probability})> get scores {
    final list = [
      for (final p in _professors)
        (professor: p, probability: _probabilities[p.id] ?? 0.0),
    ];
    list.sort((a, b) => b.probability.compareTo(a.probability));
    return list;
  }

  /// Atualiza as probabilidades com a resposta dada para uma pergunta.
  ///
  /// likelihood(p) = max(0.05, 1 - |u - e(p,q)|)
  /// P(p) <- P(p) * likelihood(p), depois normaliza.
  ///
  /// "Não sei" é tratado como informativo-zero: não mexe nas probabilidades,
  /// apenas consome a pergunta. (Sem isso, ele penalizaria injustamente os
  /// professores de característica marcante.)
  void submitAnswer(Question question, Answer answer) {
    if (_askedQuestionIds.contains(question.id)) return;

    if (answer != Answer.dontKnow) {
      final u = answer.value;
      for (final p in _professors) {
        final current = _probabilities[p.id] ?? 0;
        if (current <= 0) continue; // candidato já eliminado
        final expected = p.expected(question.id);
        final likelihood = math.max(_likelihoodFloor, 1 - (u - expected).abs());
        _probabilities[p.id] = current * likelihood;
      }
      _normalize();
    }

    _askedQuestionIds.add(question.id);
    _history.add((question: question, answer: answer));
    _questionsAsked++;
  }

  /// Desfaz a última resposta, recalculando o estado a partir do histórico.
  void undoLast() {
    if (_history.isEmpty) return;
    final replay = List.of(_history)..removeLast();
    reset();
    for (final step in replay) {
      submitAnswer(step.question, step.answer);
    }
  }

  /// Próxima pergunta a fazer, ou `null` quando é hora de palpitar.
  ///
  /// Escolhe a pergunta ainda não feita com maior **ganho de informação**: a
  /// que, em média, mais reduz a entropia da distribuição de candidatos.
  Question? nextQuestion() {
    if (shouldGuess) return null;

    final entropyBefore = _entropyOfCurrent();

    Question? best;
    var bestGain = double.negativeInfinity;

    for (final q in _questions) {
      if (_askedQuestionIds.contains(q.id)) continue;

      // Probabilidade (esperada) de a resposta ser "sim" para esta pergunta.
      var pYes = 0.0;
      for (final p in _professors) {
        pYes += (_probabilities[p.id] ?? 0) * p.expected(q.id);
      }
      final pNo = 1 - pYes;

      // Entropia esperada depois de conhecer a resposta.
      final hYes = _conditionalEntropy(q, yes: true, mass: pYes);
      final hNo = _conditionalEntropy(q, yes: false, mass: pNo);
      final expectedEntropy = pYes * hYes + pNo * hNo;

      final gain = entropyBefore - expectedEntropy;
      if (gain > bestGain) {
        bestGain = gain;
        best = q;
      }
    }

    // Se nenhuma pergunta restante traz informação relevante, vamos palpitar.
    if (best == null || bestGain < _minInfoGain) return null;
    return best;
  }

  /// Verdadeiro quando o motor já tem confiança (ou perguntas) suficiente.
  ///
  /// (perguntas >= 6 E P(líder) >= 0.70 E P(líder) >= 2 x P(vice))
  ///   ou (perguntas >= 15)
  bool get shouldGuess {
    if (_questionsAsked >= maxQuestions) return true;
    if (_questionsAsked < _minQuestionsBeforeGuess) return false;

    final leaderProb = confidence;
    final runnerUpProb = _runnerUpProbability();
    return leaderProb >= _confidenceThreshold &&
        leaderProb >= 2 * runnerUpProb;
  }

  /// Chamado quando o jogador diz que o palpite estava errado: elimina o
  /// professor e redistribui a probabilidade entre os restantes. Limpa o
  /// histórico de undo (não dá para "voltar" através de uma eliminação).
  void rejectGuess(Professor professor) {
    _probabilities[professor.id] = 0;
    _history.clear();
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

  /// Entropia de Shannon (em bits) da distribuição de probabilidades atual.
  double _entropyOfCurrent() {
    var h = 0.0;
    for (final p in _probabilities.values) {
      if (p > 0) h -= p * _log2(p);
    }
    return h;
  }

  /// Entropia da distribuição *posterior* caso a resposta a [q] seja "sim"
  /// (quando [yes]) ou "não". [mass] é a probabilidade total desse ramo, usada
  /// para normalizar o posterior.
  double _conditionalEntropy(Question q, {required bool yes, required double mass}) {
    if (mass <= 0) return 0.0;
    var h = 0.0;
    for (final p in _professors) {
      final prior = _probabilities[p.id] ?? 0;
      if (prior <= 0) continue;
      final e = p.expected(q.id);
      final weight = prior * (yes ? e : 1 - e);
      if (weight <= 0) continue;
      final posterior = weight / mass;
      h -= posterior * _log2(posterior);
    }
    return h;
  }

  static final double _ln2 = math.log(2);
  double _log2(double x) => math.log(x) / _ln2;
}
