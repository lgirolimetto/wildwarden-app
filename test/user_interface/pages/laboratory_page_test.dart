import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/ready_mark.dart';
import 'package:druid_app/user_interface/pages/species/species_page.dart';
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

    /// Dal Ricettario alla Tavola della Comune della malva, dove c'è Prepara.
    Future<void> openMalvaCommon(WidgetTester tester) async {
      await pumpDruidApp(tester);
      await openTab(tester, 'Laboratorio');
      await scrollAndTap(tester, find.byKey(const ValueKey('recipe-book-page-Malva sylvestris')));
      await scrollAndTap(tester, find.byKey(ValueKey('plate-${malvaCommon.id}')));
    }

    Future<void> chooseFree(WidgetTester tester, String sci) async {
      await scrollAndTap(tester, find.byKey(ValueKey('brew-${malvaCommon.id}')));
      await tester.tap(find.byKey(ValueKey('free-slot-$sci')));
      await tester.pumpAndSettle();
    }

    Future<void> confirm(WidgetTester tester) async {
      await tester.tap(find.byKey(const ValueKey('brew-confirm-button')));
      await tester.pumpAndSettle();
    }

    testWidgets('dalla Tavola: Prepara, la pianta dello slot libero, la conferma, la pozione e lo Scaffale', (
      tester,
    ) async {
      registerTestDependencies(events: events('Fagus sylvatica'));
      await openMalvaCommon(tester);
      await chooseFree(tester, 'Fagus sylvatica');

      expect(find.byKey(const ValueKey('brew-confirm')), findsOneWidget);
      await confirm(tester);

      expect(find.byKey(const ValueKey('potion-result')), findsOneWidget);
      final state = Get.find<ProgressController>().state;
      expect(state.potions, hasLength(1));
      expect(find.text('Potenza ${state.potions.single.potency}'), findsOneWidget);
      expect(find.text('Prima pozione di questa ricetta: +30 PE'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('potion-done')));
      await tester.pumpAndSettle();
      // Dalla Tavola alla pagina della pianta, poi al Laboratorio.
      for (var i = 0; i < 2; i++) {
        Get.back<void>();
        await tester.pumpAndSettle();
      }
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
      await openMalvaCommon(tester);
      await chooseFree(tester, 'Helleborus viridis');

      // La conferma non avvisa della tossica: la pozione guastata insegna.
      expect(find.textContaining('tossic'), findsNothing);
      await confirm(tester);

      final state = Get.find<ProgressController>().state;
      expect(state.potions, isEmpty);
      expect(state.knownToxic, {'Helleborus viridis'});
      expect(find.text('La pozione si è guastata'), findsOneWidget);
      expect(find.text('+30 PE'), findsOneWidget);
    });

    testWidgets('Annulla nella conferma non prepara niente', (tester) async {
      registerTestDependencies(events: events('Fagus sylvatica'));
      await openMalvaCommon(tester);
      await chooseFree(tester, 'Fagus sylvatica');

      await tester.tap(find.byKey(const ValueKey('brew-cancel')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('brew-confirm')), findsNothing);
      expect(Get.find<ProgressController>().state.potions, isEmpty);
      expect(Get.find<ProgressController>().state.essences.map((e) => e.vis), [10, 10]);
    });

    testWidgets('lo slot libero: ogni pianta con il Tocco che darebbe e il suo effetto', (tester) async {
      registerTestDependencies(events: events('Fagus sylvatica'));
      await openMalvaCommon(tester);
      await scrollAndTap(tester, find.byKey(ValueKey('brew-${malvaCommon.id}')));

      final option = find.byKey(const ValueKey('free-slot-Fagus sylvatica'));
      expect(find.descendant(of: option, matching: find.byType(Pill)), findsOneWidget);
      expect(find.descendant(of: option, matching: find.textContaining('forza 2')), findsOneWidget);
    });

    testWidgets('il Ricettario: icona "pronta" e filtro "Mostra solo preparabili"', (tester) async {
      registerTestDependencies(
        events: [
          ...events('Helleborus viridis'),
          LevelPassed(speciesSci: 'Fagus sylvatica', level: 1, xp: 0, occurredAt: _feb),
        ],
      );
      await pumpDruidApp(tester);
      await openTab(tester, 'Laboratorio');

      final malva = find.byKey(const ValueKey('recipe-book-page-Malva sylvestris'));
      final fagus = find.byKey(const ValueKey('recipe-book-page-Fagus sylvatica'));
      expect(find.descendant(of: malva, matching: find.byType(ReadyMark)), findsOneWidget);
      expect(fagus, findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('recipe-book-only-ready')));
      await tester.pumpAndSettle();
      expect(malva, findsOneWidget);
      expect(fagus, findsNothing, reason: 'la Comune del faggio vuole Vis di faggio, che non hai');
      expect(
        find.text('2 Pagine su 4 · 0 complete'),
        findsOneWidget,
        reason: 'il conto resta quello di tutto il Ricettario',
      );
    });

    testWidgets('con il filtro e niente da preparare, lo dice', (tester) async {
      registerTestDependencies(
        events: [LevelPassed(speciesSci: 'Malva sylvestris', level: 1, xp: 0, occurredAt: _feb)],
      );
      await pumpDruidApp(tester);
      await openTab(tester, 'Laboratorio');
      await tester.tap(find.byKey(const ValueKey('recipe-book-only-ready')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('recipe-book-none-ready')), findsOneWidget);
    });

    testWidgets('la Tavola: niente mesi, la pianta apre la sua scheda', (tester) async {
      registerTestDependencies(events: events('Fagus sylvatica'));
      await openMalvaCommon(tester);

      expect(find.byKey(const ValueKey('recipe-months')), findsNothing);
      await scrollAndTap(tester, find.byKey(const ValueKey('ingredient-Malva sylvestris')));
      expect(find.byType(SpeciesPage), findsOneWidget);
    });
  });
}
