/// Uma pergunta do jogo. O texto é exibido exatamente como cadastrado.
class Question {
  final String id;

  /// O texto exibido ao jogador, em forma de pergunta.
  final String text;

  /// Frase curta e afirmativa da característica, usada quando o gênio explica
  /// o palpite (ex.: "tem barba", "usa óculos"). Quando vazia, a pergunta não
  /// entra na explicação.
  final String trait;

  const Question({required this.id, required this.text, this.trait = ''});
}
