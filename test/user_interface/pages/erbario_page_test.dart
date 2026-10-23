import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/controllers/catalog/catalog_controller.dart';
import 'package:druid_app/user_interface/common_widgets/mystery_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('mostra anche le specie da trovare con foto e nome, senza indizio', (tester) async {
    registerTestDependencies();
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');

    expect(find.text('Erbario'), findsWidgets);
    expect(find.text('0/4 trovate'), findsOneWidget);
    expect(find.text('???'), findsNothing);
    expect(find.byType(MysteryCover), findsNothing);
    expect(
      find.descendant(of: find.byKey(const ValueKey('unknown-Eranthis hyemalis')), matching: find.text('Piè di gallo')),
      findsOneWidget,
    );
    expect(
      find.text('Una pianta della famiglia Ranunculaceae, che si fa notare soprattutto in inverno, in collina.'),
      findsNothing,
    );
  });

  testWidgets('la scheda di una specie non incontrata mostra nome e avviso di tossicità', (tester) async {
    registerTestDependencies();
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');

    await scrollAndTap(tester, find.byKey(const ValueKey('unknown-Eranthis hyemalis')));

    expect(find.text('Piè di gallo'), findsWidgets);
    expect(find.textContaining('Non ancora incontrata'), findsOneWidget);
    expect(find.text('tossica · da verificare'), findsOneWidget);
  });

  testWidgets('l\'avviso di tossicità si vede anche prima del livello 2', (tester) async {
    registerTestDependencies(
      events: [
        SpeciesEncountered(
          speciesSci: 'Eranthis hyemalis',
          method: EncounterMethod.photo,
          occurredAt: DateTime(2027, 2, 1),
        ),
      ],
    );
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');

    await scrollAndTap(tester, find.byKey(const ValueKey('met-Eranthis hyemalis')));

    expect(find.text('tossica · da verificare'), findsOneWidget);
  });

  testWidgets('"Studia" sulla tessera apre il livello, anche per una specie mai incontrata', (tester) async {
    registerTestDependencies();
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');

    await scrollAndTap(tester, find.byKey(const ValueKey('tile-study-Fagus sylvatica')));

    expect(find.text('Faggio comune'), findsWidgets);
    expect(find.textContaining('Riconoscerla ·'), findsOneWidget);
  });

  testWidgets('studiata ma mai incontrata: la scheda mostra ciò che si è imparato', (tester) async {
    registerTestDependencies(
      events: [LevelPassed(speciesSci: 'Fagus sylvatica', level: 1, xp: 20, occurredAt: DateTime(2027, 2, 1))],
    );
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');
    await scrollAndTap(tester, find.byKey(const ValueKey('unknown-Fagus sylvatica')));

    await scrollTo(tester, find.text('Forma di Faggio comune: albero.'));
    expect(find.text('Forma di Faggio comune: albero.'), findsOneWidget);
    expect(find.text('Fagus sylvatica'), findsOneWidget, reason: 'nome scientifico: rivelato al livello 1');
  });

  testWidgets('specie protetta: messaggio di rispetto con la legge che la protegge', (tester) async {
    registerTestDependencies(
      catalog: Valid(
        smallCatalog(
          protection: {
            'Fagus sylvatica': ['regional-emilia-romagna', 'habitats-annex-v'],
          },
        ),
      ),
    );
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');
    await scrollAndTap(tester, find.byKey(const ValueKey('unknown-Fagus sylvatica')));

    expect(find.byKey(const ValueKey('protected-note')), findsOneWidget);
    expect(find.textContaining('L.R. Emilia-Romagna 2/1977, Direttiva Habitat, allegato V'), findsOneWidget);
  });

  testWidgets('specie non protetta: nessun messaggio', (tester) async {
    registerTestDependencies();
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');
    await scrollAndTap(tester, find.byKey(const ValueKey('unknown-Fagus sylvatica')));

    expect(find.byKey(const ValueKey('protected-note')), findsNothing);
  });

  testWidgets('bollini: timbro con la data sulle incontrate, scudo sulle protette', (tester) async {
    registerTestDependencies(
      catalog: Valid(
        smallCatalog(
          protection: {
            'Fagus sylvatica': ['regional-emilia-romagna'],
          },
        ),
      ),
      events: [
        SpeciesEncountered(
          speciesSci: 'Eranthis hyemalis',
          method: EncounterMethod.photo,
          occurredAt: DateTime(2027, 2, 3),
        ),
      ],
    );
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');

    expect(
      find.descendant(of: find.byKey(const ValueKey('stamp-Eranthis hyemalis')), matching: find.text('3 feb')),
      findsOneWidget,
    );
    await scrollTo(tester, find.byKey(const ValueKey('unknown-Fagus sylvatica')));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('unknown-Fagus sylvatica')),
        matching: find.byTooltip('Specie protetta'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('viste: "In stagione adesso" filtra; una vista nuova si crea, si sceglie e si elimina', (tester) async {
    registerTestDependencies();
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');

    await tester.tap(find.byKey(const ValueKey('view-inSeason')));
    await tester.pumpAndSettle();
    // A febbraio sono in stagione solo elleboro e piè di gallo.
    expect(find.byKey(const ValueKey('unknown-Eranthis hyemalis')), findsOneWidget);
    expect(find.byKey(const ValueKey('unknown-Malva sylvestris')), findsNothing);
    expect(find.byKey(const ValueKey('unknown-Fagus sylvatica')), findsNothing);

    // La fila delle viste scorre in orizzontale: "Nuova vista" è in fondo.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('view-new')),
      200,
      scrollable: find
          .ancestor(of: find.byKey(const ValueKey('view-inSeason')), matching: find.byType(Scrollable))
          .first,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('view-new')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('view-new')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('view-name')), 'Alberi');
    await tester.tap(find.byKey(const ValueKey('filter-tree')));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.byKey(const ValueKey('view-save')));

    expect(find.text('Alberi'), findsOneWidget);
    expect(find.byKey(const ValueKey('unknown-Fagus sylvatica')), findsOneWidget);
    expect(find.byKey(const ValueKey('unknown-Malva sylvestris')), findsNothing);

    await tester.longPress(find.text('Alberi'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('view-remove')));
    await tester.pumpAndSettle();
    expect(find.text('Alberi'), findsNothing);
  });

  testWidgets('errore di caricamento: messaggio e pulsante Riprova che ricarica', (tester) async {
    final deps = registerTestDependencies(catalog: StateError('rotto').toInvalid());
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');

    expect(find.text('Non è stato possibile caricare i dati'), findsOneWidget);

    deps.catalog.result = Valid(smallCatalog());
    await tester.tap(find.text('Riprova'));
    await tester.pumpAndSettle();

    expect(deps.catalog.calls, 2);
    expect(Get.find<CatalogController>().uiData.isValid, isTrue);
    expect(find.text('0/4 trovate'), findsOneWidget);
  });

  testWidgets('"Simula incontro" sposta la specie tra le incontrate e la salva', (tester) async {
    final deps = registerTestDependencies();
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');

    await scrollAndTap(tester, find.byKey(const ValueKey('simulate-Eranthis hyemalis')));
    await scrollToTop(tester);

    expect(find.text('1/4 trovate'), findsOneWidget);
    expect(find.text('Incontrate'), findsOneWidget);
    expect(find.byKey(const ValueKey('met-Eranthis hyemalis')), findsOneWidget);
    expect(find.text('Piè di gallo'), findsOneWidget);
    expect(find.byKey(const ValueKey('unknown-Eranthis hyemalis')), findsNothing);
    expect(deps.events.events.whereType<SpeciesEncountered>(), hasLength(1));
  });

  testWidgets('le specie incontrate in passato compaiono all\'avvio', (tester) async {
    registerTestDependencies(
      events: [
        SpeciesEncountered(
          speciesSci: 'Fagus sylvatica',
          method: EncounterMethod.photo,
          occurredAt: DateTime(2027, 2, 1),
        ),
      ],
    );
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');

    expect(find.text('1/4 trovate'), findsOneWidget);
    expect(find.text('Faggio comune'), findsOneWidget);
    expect(find.text('Da studiare'), findsOneWidget);
  });

  testWidgets('senza strumenti di debug il pulsante "Simula incontro" non c\'è', (tester) async {
    registerTestDependencies(
      config: const AppConfig(flavor: 'produzione', plantNetApiKey: '', logHttp: false, showDebugTools: false),
    );
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');

    expect(find.text('Simula incontro'), findsNothing);
  });

  testWidgets('in inglese i nomi delle specie sono tradotti', (tester) async {
    registerTestDependencies();
    await pumpDruidApp(tester, locale: const Locale('en'));
    await openTab(tester, 'Herbarium');

    expect(find.text('Herbarium'), findsWidgets);
    final malva = smallCatalog().speciesBySci('Malva sylvestris')!;
    expect(find.text(malva.name.resolve('en')), findsOneWidget);
  });
}
