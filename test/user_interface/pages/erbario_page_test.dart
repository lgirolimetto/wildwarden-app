import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';
import 'package:druid_app/controllers/catalog/catalog_controller.dart';
import 'package:druid_app/l10n/app_localizations_en.dart';
import 'package:druid_app/user_interface/pages/erbario/hint_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('mostra le specie da trovare con il loro indizio', (tester) async {
    registerTestDependencies();
    await pumpDruidApp(tester);
    await openTab(tester, 'Erbario');

    expect(find.text('Erbario'), findsWidgets);
    expect(find.text('0/4 trovate'), findsOneWidget);
    expect(find.text('???'), findsWidgets);
    expect(
      find.text('Una pianta della famiglia Ranunculaceae, che si fa notare soprattutto in inverno, in collina.'),
      findsOneWidget,
    );
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

  testWidgets('in inglese l\'indizio è tradotto', (tester) async {
    registerTestDependencies();
    await pumpDruidApp(tester, locale: const Locale('en'));
    await openTab(tester, 'Herbarium');

    expect(find.text('Herbarium'), findsWidgets);
    final malva = smallCatalog().speciesBySci('Malva sylvestris')!;
    expect(find.text(hintText(AppLocalizationsEn(), malva.hint)), findsOneWidget);
    expect(find.text('A plant of the Malvaceae family, in the lowlands.'), findsOneWidget);
  });
}
