/// As cinco respostas possíveis que o jogador pode dar a cada pergunta.
///
/// A ordem de declaração segue a ordem em que os botões aparecem na tela
/// (Sim → Provavelmente sim → Não sei → Provavelmente não → Não).
enum Answer { yes, probablyYes, dontKnow, probablyNo, no }

extension AnswerValue on Answer {
  /// Valor numérico no eixo [0,1] que o motor usa nos cálculos.
  ///
  /// 1.0 = "sim com certeza" e 0.0 = "não com certeza". O 0.5 (Não sei) fica
  /// no meio de propósito: assim ele quase não desloca as probabilidades.
  double get value {
    switch (this) {
      case Answer.yes:
        return 1.0;
      case Answer.probablyYes:
        return 0.75;
      case Answer.dontKnow:
        return 0.5;
      case Answer.probablyNo:
        return 0.25;
      case Answer.no:
        return 0.0;
    }
  }

  /// Texto exibido no botão correspondente.
  String get label {
    switch (this) {
      case Answer.yes:
        return 'Sim';
      case Answer.probablyYes:
        return 'Provavelmente sim';
      case Answer.dontKnow:
        return 'Não sei';
      case Answer.probablyNo:
        return 'Provavelmente não';
      case Answer.no:
        return 'Não';
    }
  }
}
