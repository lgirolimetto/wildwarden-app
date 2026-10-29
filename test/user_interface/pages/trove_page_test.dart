import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/recipe_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

final _feb = DateTime(2027, 2, 1, 10);

void main() {
  tearDown(Get.reset);

  Future<void> openTrove(WidgetTester tester) async {
    await pumpDruidApp(tester);
    await openTab(tester, 'Bottino');
  }

  testWidgets('senza saldo i Bottino dell\'Esperienza dicono quanti PE mancano', (tester) async {
    registerTestDependencies(
      events: [XpGranted(xp: 100, reason: 'debug', occurredAt: _feb)],
    );
    await openTrove(tester);

    expect(find.text('100 PE da spendere'), findsOneWidget);
    expect(find.text('Comune'), findsOneWidget);
    expect(find.text('Costa 150 PE: te ne mancano 50'), findsOneWidget);
    expect(find.byKey(const ValueKey('open-trove-common')), findsNothing);
  });

  testWidgets('aprire un Bottino: si spende il saldo, la Tavola si gira e finisce nel Ricettario', (tester) async {
    registerTestDependencies(
      events: [XpGranted(xp: 1000, reason: 'debug', occurredAt: _feb)],
    );
    await openTrove(tester);

    await scrollAndTap(tester, find.byKey(const ValueKey('open-trove-uncommon')));
    expect(find.byKey(const ValueKey('trove-opening')), findsOneWidget);
    final progress = Get.find<ProgressController>();
    expect(progress.state.balance, 500);
    final opened = progress.state.troves.single;
    expect(opened.$1, Grade.uncommon);

    // Il primo Bottino non comune porta anche l'assaggio di una Rara: due Tavole coperte.
    expect(find.byKey(const ValueKey('trove-find-1')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('trove-find-0')));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.byKey(const ValueKey('trove-find-1')));
    await tester.pumpAndSettle();
    expect(
      find.text('Assaggio del grado sopra'),
      findsOneWidget,
      reason: 'quanti Componenti mancano lo dice la Tavola aperta',
    );

    final catalog = smallCatalog();
    final owned = collectedPages(catalog, progress.state).expand((p) => p.knownIds);
    expect(owned, isNotEmpty);

    await scrollAndTap(tester, find.byKey(const ValueKey('trove-done')));
    await scrollToTop(tester);
    expect(find.text('1 su 3 oggi'), findsNothing);
    expect(find.text('2 su 3 oggi'), findsOneWidget);
  });

  testWidgets('il regalo "bentornato" si riscatta dopo un\'Essenza', (tester) async {
    final deps = registerTestDependencies(
      events: [
        SpeciesEncountered(
          speciesSci: 'Malva sylvestris',
          method: EncounterMethod.simulated,
          occurredAt: DateTime(2026, 12, 1),
        ),
        XpGranted(xp: 600, reason: 'debug', occurredAt: DateTime(2026, 12, 1)),
      ],
    );
    deps.clock.current = DateTime(2027, 1, 10, 10);
    await openTrove(tester);

    expect(find.byKey(const ValueKey('welcome-gift')), findsOneWidget);
    expect(find.text("Si riscatta dopo un'Essenza: esci e Attingi da una Stazione."), findsOneWidget);

    await Get.find<ProgressController>().drawSimulated('Malva sylvestris');
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.byKey(const ValueKey('redeem-welcome-gift')));
    final state = Get.find<ProgressController>().state;
    expect(state.welcomeRedeemed, isTrue);
    expect(state.troves.single.$1, Grade.rare);
  });

  testWidgets('una Rara incompleta nel Ricettario: nome criptato, Qualia ignota, effetto da scoprire e la ⓘ', (
    tester,
  ) async {
    final page = recipeBookOf(smallCatalog()).pageOf('Eranthis hyemalis')!;
    final rare = page.recipes.firstWhere((r) => r.grade == Grade.rare);
    registerTestDependencies(
      events: [
        TroveOpened(
          grade: Grade.rare,
          price: 0,
          finds: [TroveFind(recipeId: rare.id, grade: Grade.rare, kind: TroveFindKind.recipe, missing: 2)],
          occurredAt: _feb,
        ),
      ],
    );
    await pumpDruidApp(tester);
    await openTab(tester, 'Laboratorio');
    await scrollAndTap(tester, find.byKey(const ValueKey('recipe-book-page-Eranthis hyemalis')));

    // I pezzi che mancano sono pillole "?", non "…"; il recipiente grigio e la ⓘ dicono che è incompleta.
    final plate = find.byKey(ValueKey('plate-${rare.id}'));
    // I pezzi che mancano sono criptati con "#", lunghi quanto quelli veri; fuori non si dice quanti sono.
    final full = rare.name('it');
    final known = rare.name('it', missing: 2).split('…').first;
    final title = tester.widget<RecipeTitle>(find.descendant(of: plate, matching: find.byType(RecipeTitle)));
    expect(title.full, full);
    expect(find.descendant(of: plate, matching: find.textContaining(known, findRichText: true)), findsOneWidget);
    expect(find.textContaining('…', findRichText: true), findsNothing);
    expect(
      find.descendant(
        of: plate,
        matching: find.textContaining(cipherWord(full.substring(known.length)), findRichText: true),
      ),
      findsOneWidget,
      reason: 'i pezzi criptati con "#", lunghi quanto quelli veri',
    );
    expect(find.textContaining(full.substring(known.length), findRichText: true), findsNothing);
    expect(find.text('Non si conoscono ancora 2 Componenti'), findsNothing);
    expect(find.descendant(of: plate, matching: find.byKey(const ValueKey('incomplete-info'))), findsOneWidget);
    await scrollAndTap(tester, plate);
    expect(find.text('Non si conoscono ancora 2 Componenti'), findsOneWidget);
    expect(find.byTooltip('Una Qualia che non conosci ancora'), findsOneWidget);
    expect(find.text('Da scoprire: manca un componente del nome.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('incomplete-info')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('incomplete-info-sheet')), findsOneWidget);
    expect(find.text('Dove si trovano'), findsOneWidget);
  });

  testWidgets('riciclo: 3 doppioni Non comuni e 10 Vis completano la Non comune', (tester) async {
    final uncommon = recipeBookOf(smallCatalog()).pageOf('Malva sylvestris')!.recipes[1];
    registerTestDependencies(
      events: [
        SpeciesEncountered(speciesSci: 'Malva sylvestris', method: EncounterMethod.simulated, occurredAt: _feb),
        EssenceDrawn(speciesSci: 'Malva sylvestris', simulated: true, vis: 20, occurredAt: _feb),
        TroveOpened(
          grade: Grade.uncommon,
          price: 0,
          finds: [
            TroveFind(recipeId: uncommon.id, grade: Grade.uncommon, kind: TroveFindKind.recipe, missing: 1),
            for (var i = 0; i < 3; i++)
              const TroveFind(recipeId: 'x', grade: Grade.uncommon, kind: TroveFindKind.recycled),
          ],
          occurredAt: _feb,
        ),
      ],
    );
    await openTrove(tester);

    await scrollAndTap(tester, find.byKey(ValueKey('recycle-${uncommon.id}-uncommon')));
    final state = Get.find<ProgressController>().state;
    expect(state.missingPieces, isEmpty);
    expect(state.learnedRecipes.keys, contains(uncommon.id));
    expect(state.vis['Malva sylvestris'], 10);
    expect(find.text('Tavola completata: ${uncommon.name('it')}'), findsOneWidget);
  });
}
