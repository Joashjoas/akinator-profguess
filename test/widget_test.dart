import 'package:flutter_test/flutter_test.dart';

import 'package:profguess/main.dart';

void main() {
  testWidgets('tela inicial mostra título e botão Começar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProfGuessApp());

    expect(find.text('ProfGuess'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
  });

  testWidgets('iniciar partida leva à primeira pergunta',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProfGuessApp());

    await tester.tap(find.text('Começar'));
    await tester.pump(); // inicia transição
    await tester.pump(const Duration(milliseconds: 400)); // conclui

    // Os cinco botões de resposta devem aparecer.
    expect(find.text('Sim'), findsOneWidget);
    expect(find.text('Não sei'), findsOneWidget);
    expect(find.text('Não'), findsOneWidget);
  });
}
