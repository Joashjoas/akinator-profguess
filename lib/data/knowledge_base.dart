import '../models/professor.dart';
import '../models/question.dart';

/// Base de conhecimento do jogo: perguntas e o perfil de cada professor.
///
/// Os valores da matriz são uma primeira calibração feita pelo grupo e podem
/// (e devem) ser ajustados depois de algumas partidas de teste. A escala é:
///   1.0  = sim, com certeza
///   0.75 = provavelmente sim
///   0.5  = não se aplica / depende / incerto
///   0.25 = provavelmente não
///   0.0  = não, com certeza
///
/// Todas as perguntas tratam apenas de características neutras e observáveis,
/// como exige a atividade.

const List<Question> questions = [
  Question(id: 'q01', text: 'O professor que você está pensando usa óculos?'),
  Question(id: 'q02', text: 'Esse professor tem barba?'),
  Question(id: 'q03', text: 'Esse professor tem cabelo curto?'),
  Question(id: 'q04', text: 'Costuma usar camisa social nas aulas?'),
  Question(id: 'q05', text: 'Costuma usar camiseta nas aulas?'),
  Question(id: 'q06', text: 'Usa slides com frequência nas aulas?'),
  Question(id: 'q07', text: 'Escreve bastante no quadro?'),
  Question(id: 'q08', text: 'Costuma dar aula em laboratório?'),
  Question(id: 'q09', text: 'Passa muitos exercícios práticos?'),
  Question(id: 'q10', text: 'Costuma trabalhar com projetos nas disciplinas?'),
  Question(id: 'q11', text: 'Gosta de discutir código ao vivo durante a aula?'),
  Question(id: 'q12', text: 'Usa muitos exemplos práticos do dia a dia?'),
  Question(id: 'q13', text: 'Fala bastante sobre mercado de trabalho?'),
  Question(id: 'q14', text: 'Cobra bastante organização nas entregas?'),
  Question(id: 'q15', text: 'Trabalha com programação?'),
  Question(id: 'q16', text: 'Trabalha com banco de dados?'),
  Question(id: 'q17', text: 'Trabalha com redes de computadores?'),
  Question(id: 'q18', text: 'Trabalha com engenharia de software?'),
  Question(id: 'q19', text: 'Trabalha com matemática ou lógica?'),
  Question(id: 'q20', text: 'Trabalha com gestão ou áreas administrativas?'),
];

const List<Professor> professors = [
  Professor(
    id: 'fabiane',
    name: 'Fabiane',
    answerProfile: {
      'q01': 0.75, 'q02': 0.0, 'q03': 0.25, 'q04': 0.75, 'q05': 0.25,
      'q06': 1.0, 'q07': 0.5, 'q08': 0.25, 'q09': 0.5, 'q10': 0.5,
      'q11': 0.0, 'q12': 0.75, 'q13': 0.75, 'q14': 1.0, 'q15': 0.0,
      'q16': 0.0, 'q17': 0.0, 'q18': 0.25, 'q19': 0.25, 'q20': 1.0,
    },
  ),
  Professor(
    id: 'jefferson_speck',
    name: 'Jefferson Speck',
    answerProfile: {
      'q01': 0.75, 'q02': 1.0, 'q03': 0.75, 'q04': 0.25, 'q05': 0.75,
      'q06': 0.5, 'q07': 0.5, 'q08': 1.0, 'q09': 0.75, 'q10': 0.5,
      'q11': 0.5, 'q12': 0.5, 'q13': 0.5, 'q14': 0.5, 'q15': 0.5,
      'q16': 0.25, 'q17': 1.0, 'q18': 0.25, 'q19': 0.25, 'q20': 0.0,
    },
  ),
  Professor(
    id: 'jhoni',
    name: 'Jhoni',
    answerProfile: {
      'q01': 0.5, 'q02': 0.75, 'q03': 0.5, 'q04': 0.25, 'q05': 1.0,
      'q06': 0.25, 'q07': 0.5, 'q08': 0.5, 'q09': 1.0, 'q10': 0.75,
      'q11': 1.0, 'q12': 1.0, 'q13': 0.75, 'q14': 0.25, 'q15': 1.0,
      'q16': 0.5, 'q17': 0.0, 'q18': 0.5, 'q19': 0.5, 'q20': 0.0,
    },
  ),
  Professor(
    id: 'willian',
    name: 'Willian',
    answerProfile: {
      'q01': 1.0, 'q02': 0.25, 'q03': 0.75, 'q04': 0.5, 'q05': 0.5,
      'q06': 0.75, 'q07': 0.5, 'q08': 0.5, 'q09': 0.75, 'q10': 0.5,
      'q11': 0.25, 'q12': 0.5, 'q13': 0.5, 'q14': 0.75, 'q15': 0.5,
      'q16': 1.0, 'q17': 0.25, 'q18': 0.5, 'q19': 0.25, 'q20': 0.0,
    },
  ),
  Professor(
    id: 'guilherme_alves',
    name: 'Guilherme Alves',
    answerProfile: {
      'q01': 0.75, 'q02': 0.5, 'q03': 0.75, 'q04': 0.5, 'q05': 0.25,
      'q06': 0.75, 'q07': 0.25, 'q08': 0.5, 'q09': 0.5, 'q10': 1.0,
      'q11': 0.5, 'q12': 0.5, 'q13': 0.75, 'q14': 1.0, 'q15': 0.75,
      'q16': 0.5, 'q17': 0.25, 'q18': 1.0, 'q19': 0.25, 'q20': 0.5,
    },
  ),
  Professor(
    id: 'marcos_guido',
    name: 'Marcos Guido',
    answerProfile: {
      'q01': 0.75, 'q02': 0.25, 'q03': 0.75, 'q04': 0.5, 'q05': 0.5,
      'q06': 0.25, 'q07': 1.0, 'q08': 0.25, 'q09': 1.0, 'q10': 0.25,
      'q11': 0.25, 'q12': 0.5, 'q13': 0.25, 'q14': 0.75, 'q15': 0.25,
      'q16': 0.0, 'q17': 0.0, 'q18': 0.25, 'q19': 1.0, 'q20': 0.0,
    },
  ),
  Professor(
    id: 'leticia',
    name: 'Letícia',
    answerProfile: {
      'q01': 0.5, 'q02': 0.0, 'q03': 0.25, 'q04': 1.0, 'q05': 0.0,
      'q06': 1.0, 'q07': 0.25, 'q08': 0.0, 'q09': 0.5, 'q10': 0.75,
      'q11': 0.0, 'q12': 0.75, 'q13': 1.0, 'q14': 1.0, 'q15': 0.0,
      'q16': 0.0, 'q17': 0.0, 'q18': 0.25, 'q19': 0.25, 'q20': 1.0,
    },
  ),
  Professor(
    id: 'jeferson_vorpagel',
    name: 'Jeferson Vorpagel',
    answerProfile: {
      'q01': 0.5, 'q02': 0.5, 'q03': 0.5, 'q04': 0.25, 'q05': 0.75,
      'q06': 0.25, 'q07': 0.75, 'q08': 0.75, 'q09': 1.0, 'q10': 0.5,
      'q11': 0.75, 'q12': 0.75, 'q13': 0.5, 'q14': 0.5, 'q15': 1.0,
      'q16': 0.5, 'q17': 0.25, 'q18': 0.5, 'q19': 0.5, 'q20': 0.0,
    },
  ),
  Professor(
    id: 'andre_dorr',
    name: 'André Dorr',
    answerProfile: {
      'q01': 0.5, 'q02': 0.5, 'q03': 0.5, 'q04': 0.25, 'q05': 1.0,
      'q06': 0.5, 'q07': 0.5, 'q08': 1.0, 'q09': 0.75, 'q10': 0.5,
      'q11': 0.75, 'q12': 0.5, 'q13': 0.5, 'q14': 0.5, 'q15': 0.75,
      'q16': 0.25, 'q17': 1.0, 'q18': 0.5, 'q19': 0.25, 'q20': 0.0,
    },
  ),
  Professor(
    id: 'renato',
    name: 'Renato',
    answerProfile: {
      'q01': 0.75, 'q02': 0.5, 'q03': 0.75, 'q04': 0.75, 'q05': 0.25,
      'q06': 0.75, 'q07': 0.5, 'q08': 0.5, 'q09': 1.0, 'q10': 0.5,
      'q11': 0.25, 'q12': 0.5, 'q13': 0.5, 'q14': 1.0, 'q15': 0.5,
      'q16': 1.0, 'q17': 0.25, 'q18': 0.25, 'q19': 0.5, 'q20': 0.25,
    },
  ),
  Professor(
    id: 'marcel',
    name: 'Marcel',
    answerProfile: {
      'q01': 1.0, 'q02': 0.0, 'q03': 0.5, 'q04': 0.5, 'q05': 0.5,
      'q06': 0.5, 'q07': 0.75, 'q08': 0.5, 'q09': 1.0, 'q10': 0.5,
      'q11': 0.75, 'q12': 0.5, 'q13': 0.5, 'q14': 0.5, 'q15': 1.0,
      'q16': 0.5, 'q17': 0.25, 'q18': 0.5, 'q19': 1.0, 'q20': 0.0,
    },
  ),
  Professor(
    id: 'hiago',
    name: 'Hiago',
    answerProfile: {
      'q01': 0.5, 'q02': 0.5, 'q03': 0.5, 'q04': 0.25, 'q05': 0.75,
      'q06': 0.5, 'q07': 0.25, 'q08': 0.5, 'q09': 0.5, 'q10': 1.0,
      'q11': 0.5, 'q12': 0.75, 'q13': 0.75, 'q14': 0.75, 'q15': 0.75,
      'q16': 0.5, 'q17': 0.25, 'q18': 1.0, 'q19': 0.25, 'q20': 0.5,
    },
  ),
  Professor(
    id: 'wander',
    name: 'Wander',
    answerProfile: {
      'q01': 1.0, 'q02': 0.75, 'q03': 0.5, 'q04': 0.5, 'q05': 0.5,
      'q06': 0.25, 'q07': 1.0, 'q08': 0.25, 'q09': 1.0, 'q10': 0.25,
      'q11': 0.25, 'q12': 0.5, 'q13': 0.25, 'q14': 0.75, 'q15': 0.75,
      'q16': 0.25, 'q17': 0.25, 'q18': 0.25, 'q19': 1.0, 'q20': 0.0,
    },
  ),
  Professor(
    id: 'alan',
    name: 'Alan',
    answerProfile: {
      'q01': 0.5, 'q02': 0.5, 'q03': 0.75, 'q04': 0.25, 'q05': 0.75,
      'q06': 0.5, 'q07': 0.25, 'q08': 0.5, 'q09': 0.75, 'q10': 0.75,
      'q11': 0.75, 'q12': 1.0, 'q13': 1.0, 'q14': 0.5, 'q15': 1.0,
      'q16': 0.5, 'q17': 0.25, 'q18': 0.5, 'q19': 0.25, 'q20': 0.25,
    },
  ),
  Professor(
    id: 'fabiano',
    name: 'Fabiano',
    answerProfile: {
      'q01': 0.5, 'q02': 0.5, 'q03': 0.75, 'q04': 0.75, 'q05': 0.25,
      'q06': 1.0, 'q07': 0.25, 'q08': 0.0, 'q09': 0.5, 'q10': 1.0,
      'q11': 0.0, 'q12': 0.75, 'q13': 1.0, 'q14': 1.0, 'q15': 0.25,
      'q16': 0.25, 'q17': 0.0, 'q18': 0.5, 'q19': 0.25, 'q20': 1.0,
    },
  ),
];
