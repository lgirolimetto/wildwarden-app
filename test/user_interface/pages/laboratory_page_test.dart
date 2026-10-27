import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/test_app.dart';

final _feb = DateTime(2027, 2, 1, 10);

void main() {
  tearDown(Get.reset);

  Future<void> openPantry(WidgetTester tester) async {
    await pumpDruidApp(tester);
    await openTab(tester, 'Laboratorio');
    await tester.tap(find.byKey(const ValueKey('lab-tab-pantry')));
    await tester.pumpAndSettle();
  }

  testWidgets('il Laboratorio si apre sul Ricettario', (tester) async {
    registerTestDependencies();
    await pumpDruidApp(tester);
    await openTab(tester, 'Laboratorio');

    expect(find.byKey(const ValueKey('recipe-book')), findsOneWidget);
    expect(find.byKey(const ValueKey('recipe-book-count')), findsOneWidget);
  });

  testWidgets('la Dispensa vuota spiega come si riempie', (tester) async {
    registerTestDependencies();
    await openPantry(tester);

    expect(find.byKey(const ValueKey('pantry-empty')), findsOneWidget);
    expect(find.text('0 Essenze'), findsOneWidget);
  });

  testWidgets('la Dispensa: le Essenze per specie, con tratti, purezza e Vis', (tester) async {
    registerTestDependencies(
      events: [
        EssenceDrawn(
          speciesSci: 'Malva sylvestris',
          traits: const ['dew', 'moon'],
          simulated: true,
          vis: 10,
          purity: 0.75,
          occurredAt: _feb,
        ),
        EssenceDrawn(speciesSci: 'Malva sylvestris', simulated: true, vis: 10, occurredAt: _feb),
      ],
    );
    await openPantry(tester);

    expect(find.text('2 Essenze'), findsOneWidget);
    expect(find.text('2 Essenze · 20 Vis'), findsOneWidget);
    expect(find.text('Purezza 75 % · 10 Vis'), findsOneWidget);
    expect(find.text('Purezza 40 % · 10 Vis'), findsOneWidget, reason: 'senza purezza: quella del livello 0');
    expect(find.text('Nessun tratto'), findsOneWidget);
    expect(find.textContaining('Rugiada'), findsOneWidget);
  });
}
