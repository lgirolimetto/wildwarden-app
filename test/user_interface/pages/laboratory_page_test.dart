import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/fakes.dart';
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

  group('preparare', () {
    final malvaCommon = recipeBookOf(smallCatalog()).pageOf('Malva sylvestris')!.recipes.first;
    List<GameEvent> events(String freeSci) => [
      LevelPassed(speciesSci: 'Malva sylvestris', level: 1, xp: 0, occurredAt: _feb),
      EssenceDrawn(speciesSci: 'Malva sylvestris', simulated: true, vis: 10, purity: 1.0, occurredAt: _feb),
      EssenceDrawn(speciesSci: freeSci, simulated: true, vis: 10, purity: 1.0, occurredAt: _feb),
    ];

    Future<void> openReady(WidgetTester tester) async {
      await pumpDruidApp(tester);
      await openTab(tester, 'Laboratorio');
      await tester.ensureVisible(find.byKey(const ValueKey('lab-tab-ready')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('lab-tab-ready')));
      await tester.pumpAndSettle();
    }

    testWidgets('dalle Ricette pronte: Prepara, la pianta dello slot libero, la pozione e lo Scaffale', (tester) async {
      registerTestDependencies(events: events('Fagus sylvatica'));
      await openReady(tester);

      expect(find.text('1 pronta'), findsOneWidget);
      await scrollAndTap(tester, find.byKey(ValueKey('brew-${malvaCommon.id}')));
      await tester.tap(find.byKey(const ValueKey('free-slot-Fagus sylvatica')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('potion-result')), findsOneWidget);
      final state = Get.find<ProgressController>().state;
      expect(state.potions, hasLength(1));
      expect(find.text('Potenza ${state.potions.single.potency}'), findsOneWidget);
      expect(find.text('Prima pozione di questa ricetta: +30 PE'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('potion-done')));
      await tester.pumpAndSettle();
      await scrollToTop(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('lab-tab-shelf')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('lab-tab-shelf')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('potion-0')), findsOneWidget);

      // Usarla: lascia lo Scaffale e l'effetto è in corso.
      await tester.tap(find.byKey(const ValueKey('use-potion-0')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('potion-0')), findsNothing);
      expect(find.byKey(const ValueKey('active-effects')), findsOneWidget);
      expect(Get.find<ProgressController>().state.potions.single.onShelf, isFalse);
    });

    testWidgets('una tossica nello slot libero guasta la pozione', (tester) async {
      registerTestDependencies(events: events('Helleborus viridis'));
      await openReady(tester);

      await scrollAndTap(tester, find.byKey(ValueKey('brew-${malvaCommon.id}')));
      await tester.tap(find.byKey(const ValueKey('free-slot-Helleborus viridis')));
      await tester.pumpAndSettle();

      final state = Get.find<ProgressController>().state;
      expect(state.potions, isEmpty);
      expect(state.knownToxic, {'Helleborus viridis'});
      expect(find.text('La pozione si è guastata'), findsOneWidget);
      expect(find.text('+30 PE'), findsOneWidget);
    });
  });
}
