# ProfGuess

Jogo de adivinhação no estilo Akinator, feito em Flutter, que tenta descobrir
em qual **professor do curso de ADS** o jogador está pensando. O app faz uma
sequência de perguntas sobre características observáveis e, a cada resposta,
ajusta a probabilidade de cada professor até arriscar um palpite.

## Como jogar

1. Pense em um professor do curso.
2. Toque em **Começar**.
3. Responda cada pergunta com uma das cinco opções:
   Sim · Provavelmente sim · Não sei · Provavelmente não · Não.
4. Quando o "Gênio do Campus" estiver confiante, ele dá o palpite. Você diz se
   ele acertou ou errou; se errou e ainda houver pistas, ele continua tentando.

## Como rodar

Pré-requisito: Flutter SDK instalado.

As pastas de plataforma (`android/`, `ios/`, `windows/`, etc.) não estão no
repositório. Gere-as rodando:

```bash
flutter create .
```

Depois:

```bash
flutter pub get
flutter run            # no emulador/dispositivo conectado
flutter run -d chrome  # no navegador
```

Build do APK de release:

```bash
flutter build apk --release
```

## Testes

A lógica de inferência tem testes unitários (atualização de probabilidades,
seleção de perguntas, condição de palpite e exclusão de candidato após erro):

```bash
flutter test
```

## Como a lógica funciona

O coração do jogo é o `GuessEngine` (em `lib/engine/`), escrito em Dart puro
para poder ser testado isoladamente. O modelo é uma inferência bayesiana
simplificada:

- **Probabilidades.** Cada professor começa com a mesma probabilidade (1/15).
  Cada um tem um *perfil*: para cada pergunta, um valor esperado entre 0 (não) e
  1 (sim).
- **Atualização.** A cada resposta, calculamos a verossimilhança
  `max(0.05, 1 - |resposta - esperado|)` e multiplicamos pela probabilidade do
  professor, normalizando em seguida. O piso de `0.05` garante que ninguém é
  eliminado por uma única resposta divergente — o sistema tolera ruído.
- **Escolha da pergunta.** Entre as perguntas ainda não feitas, escolhemos a de
  maior **variância ponderada** das respostas esperadas: a que melhor separa os
  suspeitos atuais. Como as probabilidades mudam a cada resposta, a ordem das
  perguntas muda a cada partida (a lógica não é fixa).
- **Palpite.** O gênio arrisca quando o líder tem ≥ 70% de probabilidade e o
  dobro do segundo colocado (com pelo menos 6 perguntas), ou ao chegar a 15
  perguntas.

## Estrutura

```
lib/
├── main.dart                 # MaterialApp, tema e troca de telas
├── models/                   # Answer, Professor, Question
├── data/knowledge_base.dart  # 15 professores, 20 perguntas e a matriz
├── engine/guess_engine.dart  # motor de inferência (Dart puro)
├── controllers/              # GameController (ChangeNotifier)
├── screens/                  # tela inicial, pergunta e resultado
├── widgets/                  # mascote, botões e barra de confiança
└── theme/                    # cores e tema
```

## Calibração da matriz

Os valores em `lib/data/knowledge_base.dart` são uma primeira estimativa. Vale
jogar algumas partidas simulando cada professor e ajustar os valores para
melhorar a taxa de acerto. Dica: cada professor fica mais fácil de adivinhar
quando tem vários valores extremos (1.0 ou 0.0) que o diferenciam dos demais.
