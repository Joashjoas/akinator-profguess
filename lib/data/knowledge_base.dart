import '../models/professor.dart';
import '../models/question.dart';

/// Base de conhecimento do jogo: perguntas e o perfil de cada professor.
///
/// MODELAGEM POR TAGS
/// ------------------
/// Em vez de uma matriz com um valor para cada par (professor, pergunta) — que
/// ficava enorme e cheia de zeros — cada professor declara apenas as perguntas
/// que responde "sim". Tudo o que não está na lista é tratado como "não".
///
/// Para adicionar/editar um professor, basta mexer na lista de ids dele em
/// [_profiles]; para uma pergunta nova, acrescente em [questions] e cite o id
/// nos professores que a possuem. Não há mais valores soltos para errar.
///
/// O motor de inferência continua trabalhando com probabilidades no intervalo
/// [0,1], então a conversão tag → perfil usa 1.0 (sim) e 0.0 (não). Se um dia
/// quiserem um "meio-termo" para alguma característica, dá para trocar o
/// `Set<String>` por um `Map<String,double>` que [_buildProfile] já aceitaria.

const List<Question> questions = [
  Question(id: 'q01', text: 'O professor que você está pensando usa óculos?', trait: 'usa óculos'),
  Question(id: 'q02', text: 'Esse professor tem barba?', trait: 'tem barba'),
  Question(id: 'q03', text: 'Esse professor tem cabelo curto?', trait: 'tem cabelo curto'),
  Question(id: 'q04', text: 'Esse professor tem cabelo comprido?', trait: 'tem cabelo comprido'),
  Question(id: 'q05', text: 'Costuma usar camiseta nas aulas?', trait: 'costuma usar camiseta'),
  Question(id: 'q06', text: 'Costuma usar camisa social nas aulas?', trait: 'costuma usar camisa social'),
  Question(id: 'q07', text: 'Fala bastante sobre mercado de trabalho?', trait: 'fala sobre mercado de trabalho'),
  Question(id: 'q08', text: 'Gosta de trabalhar seminários com os alunos?', trait: 'trabalha com seminários'),
  Question(id: 'q09', text: 'Passa exercícios em laboratório?', trait: 'passa exercícios em laboratório'),
  Question(id: 'q10', text: 'Escreve bastante no quadro?', trait: 'escreve bastante no quadro'),
  Question(id: 'q11', text: 'Costuma trabalhar os alunos com projetos?', trait: 'trabalha com projetos'),
  Question(id: 'q12', text: 'Trabalha com programação?', trait: 'trabalha com programação'),
  Question(id: 'q13', text: 'Trabalha como gestor ou coordenador?', trait: 'trabalha como gestor ou coordenador'),
  Question(id: 'q14', text: 'Trabalha com redes?', trait: 'trabalha com redes'),
  Question(id: 'q15', text: 'Está dando aula para sua turma neste semestre?', trait: 'dá aula para a turma este semestre'),
  Question(id: 'q16', text: 'O professor que você está pensando pinta o cabelo?', trait: 'pinta o cabelo'),
];

/// Cada entrada é `id do professor` -> (nome, conjunto de perguntas "sim").
/// A ordem aqui também é a ordem de desempate do palpite.
const Map<String, ({String name, Set<String> yes})> _profiles = {
  'jeferson_vorpagel': (
    name: 'Jefferson dos Santos Vorpagel',
    yes: {'q02', 'q06', 'q07', 'q08', 'q11', 'q13', 'q15'},
  ),
  'willian': (
    name: 'Willian Douglas Ferrari Mendonça',
    yes: {'q01', 'q02', 'q03', 'q05', 'q11', 'q12', 'q15'},
  ),
  'marcos_guido': (
    name: 'Marcos Antonio Guido',
    yes: {'q03', 'q06', 'q08', 'q09', 'q10', 'q12', 'q13', 'q14', 'q15'},
  ),
  'jefferson_speck': (
    name: 'Jefferson Rodrigo Speck',
    yes: {'q01', 'q02', 'q05', 'q07', 'q08', 'q10', 'q11', 'q12', 'q15', 'q16'},
  ),
  'guilherme_alves': (
    name: 'Guilherme Alves',
    yes: {'q01', 'q05', 'q07', 'q10', 'q11', 'q12', 'q15'},
  ),
  'andre_dorr': (
    name: 'André Luis Dorr',
    yes: {'q01', 'q02', 'q05'},
  ),
  'leticia': (
    name: 'Letícia Siguinolfi de Lima',
    yes: {'q01', 'q04', 'q05', 'q07', 'q16'},
  ),
  'marcel': (
    name: 'Marcel Augusto Colling',
    yes: {'q02', 'q06', 'q07', 'q08'},
  ),
  'fabiano': (
    name: 'Fabiano do Carmo Dicheti',
    yes: {'q01', 'q02', 'q05', 'q07', 'q10', 'q11', 'q12'},
  ),
  'fabiane': (
    name: 'Fabiane Sorbar',
    yes: {'q01', 'q04', 'q05', 'q13'},
  ),
  'jhoni': (
    name: 'Jhoni Eldor Schulz',
    yes: {'q05', 'q12'},
  ),
  'vinicius': (
    name: 'Vinícius Tessele',
    yes: {'q05', 'q07', 'q12'},
  ),
  'allan': (
    name: 'Allan Bossoni Escher',
    yes: {'q01', 'q06'},
  ),
  'hiago': (
    name: 'Hiago Bruno Costa Pereira',
    yes: {'q03', 'q06', 'q07', 'q08', 'q10', 'q13'},
  ),
  'daniele': (
    name: 'Daniele Wolfart Mantovani',
    yes: {'q04', 'q05', 'q08'},
  ),
  'renato': (
    name: 'Renato Estevam Pereira',
    yes: {'q06', 'q07', 'q08', 'q10', 'q13'},
  ),
  'vander': (
    name: 'Vander',
    yes: {'q01', 'q03', 'q06', 'q09', 'q10', 'q11'},
  ),
};

/// Converte o conjunto de tags "sim" no mapa de respostas esperadas (1.0/0.0)
/// que o motor consome.
Map<String, double> _buildProfile(Set<String> yes) => {
      for (final q in questions) q.id: yes.contains(q.id) ? 1.0 : 0.0,
    };

/// Lista de professores derivada de [_profiles]. É o que o jogo usa.
final List<Professor> professors = [
  for (final entry in _profiles.entries)
    Professor(
      id: entry.key,
      name: entry.value.name,
      answerProfile: _buildProfile(entry.value.yes),
    ),
];
