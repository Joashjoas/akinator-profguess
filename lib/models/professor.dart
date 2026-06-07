/// Um professor candidato, com o perfil de respostas esperadas dele.
class Professor {
  final String id;
  final String name;

  /// Mapa de `questionId` para o valor esperado no intervalo [0,1].
  ///
  /// 1.0 = "para esse professor a resposta é claramente sim",
  /// 0.0 = "claramente não", 0.5 = não se aplica / depende.
  final Map<String, double> answerProfile;

  const Professor({
    required this.id,
    required this.name,
    required this.answerProfile,
  });

  /// Valor esperado do professor para uma pergunta. Quando a pergunta não
  /// estiver no perfil, assume 0.5 (neutro) para não penalizar ninguém.
  double expected(String questionId) => answerProfile[questionId] ?? 0.5;
}
