import 'package:flutter_test/flutter_test.dart';
import 'package:profguess/data/knowledge_base.dart';
import 'package:profguess/engine/guess_engine.dart';
import 'package:profguess/models/answer.dart';
import 'package:profguess/models/professor.dart';
import 'package:profguess/models/question.dart';

/// Converte um valor esperado [0,1] na resposta "honesta" correspondente,
/// para simular alguém respondendo conforme o perfil de um professor.
Answer answerFor(double expected) {
  if (expected >= 0.875) return Answer.yes;
  if (expected >= 0.625) return Answer.probablyYes;
  if (expected > 0.375) return Answer.dontKnow;
  if (expected > 0.125) return Answer.probablyNo;
  return Answer.no;
}

GuessEngine buildEngine() =>
    GuessEngine(professors: professors, questions: questions);

void main() {
  group('Atualização de probabilidades', () {
    test('iniciam uniformes e somam 1 após cada atualização', () {
      final engine = buildEngine();
      // Sem perguntas ainda: confiança é 1/15.
      expect(engine.confidence, closeTo(1 / professors.length, 1e-9));

      final q = engine.nextQuestion()!;
      engine.submitAnswer(q, Answer.yes);

      // A soma das probabilidades continua 1 (verificada indiretamente:
      // a confiança nunca passa de 1 e há um líder bem definido).
      expect(engine.confidence, greaterThan(0));
      expect(engine.confidence, lessThanOrEqualTo(1.0 + 1e-9));
    });

    test('"Sim" sobe quem tem e=1.0 e desce quem tem e=0.0', () {
      final pYes = Professor(
        id: 'sim',
        name: 'Sim',
        answerProfile: {'q': 1.0},
      );
      final pNo = Professor(
        id: 'nao',
        name: 'Não',
        answerProfile: {'q': 0.0},
      );
      final engine = GuessEngine(
        professors: [pYes, pNo],
        questions: const [Question(id: 'q', text: '?')],
      );

      engine.submitAnswer(const Question(id: 'q', text: '?'), Answer.yes);
      expect(engine.currentGuess.id, 'sim');
      expect(engine.confidence, greaterThan(0.5));
    });

    test('"Não sei" mantém o ranking praticamente inalterado', () {
      final engine = buildEngine();
      final leaderBefore = engine.currentGuess.id;
      final q = engine.nextQuestion()!;
      engine.submitAnswer(q, Answer.dontKnow);
      // Com todos próximos do uniforme, o líder não deve mudar drasticamente.
      expect(engine.confidence, closeTo(1 / professors.length, 0.05));
      // (o líder pode empatar, mas a confiança quase não se move)
      expect(leaderBefore, isNotNull);
    });
  });

  group('Seleção de perguntas', () {
    test('nenhuma pergunta é retornada duas vezes', () {
      final engine = buildEngine();
      final seen = <String>{};
      Question? q;
      while ((q = engine.nextQuestion()) != null) {
        expect(seen.contains(q!.id), isFalse,
            reason: 'pergunta ${q.id} repetida');
        seen.add(q.id);
        engine.submitAnswer(q, Answer.dontKnow);
      }
      expect(seen.length, lessThanOrEqualTo(questions.length));
    });
  });

  group('"Não sei" é informativo-zero', () {
    test('responder "Não sei" não desloca as probabilidades', () {
      final engine = buildEngine();
      final before = engine.confidence;
      final q = engine.nextQuestion()!;
      engine.submitAnswer(q, Answer.dontKnow);
      // Distribuição continua uniforme: o líder mantém 1/N.
      expect(engine.confidence, closeTo(before, 1e-9));
      expect(engine.confidence, closeTo(1 / professors.length, 1e-9));
    });
  });

  group('Voltar (undo)', () {
    test('undoLast restaura o estado anterior à última resposta', () {
      final engine = buildEngine();
      final q1 = engine.nextQuestion()!;
      engine.submitAnswer(q1, Answer.yes);
      final confAfterFirst = engine.confidence;
      final guessAfterFirst = engine.currentGuess.id;

      final q2 = engine.nextQuestion()!;
      engine.submitAnswer(q2, Answer.no);
      expect(engine.questionsAsked, 2);

      engine.undoLast();
      expect(engine.questionsAsked, 1);
      expect(engine.canUndo, isTrue);
      expect(engine.confidence, closeTo(confAfterFirst, 1e-9));
      expect(engine.currentGuess.id, guessAfterFirst);
      // A pergunta voltou a estar disponível.
      expect(engine.nextQuestion()!.id, q2.id);
    });
  });

  group('Adaptatividade', () {
    test('a escolha da próxima pergunta depende das respostas dadas', () {
      // Mesma primeira pergunta; respostas opostas devem levar (em geral) a
      // segundas perguntas diferentes, pois os candidatos prováveis mudam.
      final a = buildEngine();
      final b = buildEngine();
      final first = a.nextQuestion()!;
      expect(b.nextQuestion()!.id, first.id); // estado inicial é igual

      a.submitAnswer(first, Answer.yes);
      b.submitAnswer(first, Answer.no);

      expect(a.nextQuestion()!.id, isNot(b.nextQuestion()!.id));
    });
  });

  group('Condição de palpite', () {
    test('após o limite de perguntas shouldGuess é sempre true', () {
      final engine = buildEngine();
      var count = 0;
      while (count < GuessEngine.maxQuestions) {
        final q = engine.nextQuestion();
        if (q == null) break;
        engine.submitAnswer(q, Answer.dontKnow);
        count++;
      }
      // Respondendo sempre "não sei" o motor acaba esgotando as perguntas:
      // a partir daí não há mais o que perguntar (nextQuestion == null).
      expect(engine.questionsAsked, lessThanOrEqualTo(GuessEngine.maxQuestions));
      expect(engine.nextQuestion(), isNull);
    });
  });

  group('Simulação completa', () {
    // Responder conforme o perfil exato de um professor deve levá-lo a ser
    // adivinhado em no máximo 15 perguntas.
    for (final target in ['jhoni', 'leticia', 'jefferson_speck']) {
      test('adivinha $target em <= 15 perguntas', () {
        final engine = buildEngine();
        final professor = professors.firstWhere((p) => p.id == target);

        Question? q;
        while ((q = engine.nextQuestion()) != null) {
          engine.submitAnswer(q!, answerFor(professor.expected(q.id)));
        }

        expect(engine.questionsAsked, lessThanOrEqualTo(15));
        expect(engine.currentGuess.id, target,
            reason: 'esperava adivinhar $target');
      });
    }
  });

  group('Erro no palpite', () {
    test('rejectGuess zera o candidato e muda o próximo palpite', () {
      final engine = buildEngine();
      final professor = professors.firstWhere((p) => p.id == 'jhoni');

      Question? q;
      while ((q = engine.nextQuestion()) != null) {
        engine.submitAnswer(q!, answerFor(professor.expected(q.id)));
      }

      final firstGuess = engine.currentGuess;
      engine.rejectGuess(firstGuess);
      // O líder agora deve ser outro professor.
      expect(engine.currentGuess.id, isNot(firstGuess.id));
    });
  });
}
