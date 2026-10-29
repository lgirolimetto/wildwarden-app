import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/tutorial.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../helpers/test_app.dart';

void main() {
  tearDown(Get.reset);
  final day = DateTime(2027, 2, 14, 9);
  OnboardingMarked mark(OnboardingMark m) => OnboardingMarked(mark: m, occurredAt: day);

  Finder navLabel(String label) => find.descendant(of: find.byType(ClayNavBar), matching: find.text(label));

  testWidgets('"Inizia": il primo passo, e nella barra solo Home e Attingi', (tester) async {
    registerTestDependencies();
    await pumpDruidApp(tester);
    expect(navLabel('Erbario'), findsOneWidget);

    await scrollAndTap(tester, find.byKey(const ValueKey('tutorial-action')));

    expect(find.byKey(const ValueKey('tutorial-photograph')), findsOneWidget);
    expect(find.text("Fotografa un'aromatica"), findsOneWidget);
    expect(navLabel('Home'), findsOneWidget);
    expect(navLabel('Erbario'), findsNothing);
    expect(navLabel('Laboratorio'), findsNothing);
    expect(navLabel('Bottino'), findsNothing);
    // Durante il tutorial la Home mostra solo il passo: il resto si nasconde.
    expect(find.byKey(const ValueKey('seasonal-Malva sylvestris'), skipOffstage: false), findsNothing);
  });

  testWidgets('al passo della pozione il Laboratorio mostra solo le Ricette pronte', (tester) async {
    registerTestDependencies(
      events: [
        mark(OnboardingMark.tutorialStarted),
        SpeciesEncountered(speciesSci: 'Salvia officinalis', method: EncounterMethod.photo, occurredAt: day),
        LevelPassed(speciesSci: 'Salvia officinalis', level: 1, xp: 20, occurredAt: day),
        SpeciesEncountered(speciesSci: 'Laurus nobilis', method: EncounterMethod.photo, occurredAt: day),
      ],
    );
    await pumpDruidApp(tester);
    await scrollAndTap(tester, find.byKey(const ValueKey('tutorial-action')));

    expect(find.byKey(const ValueKey('ready-count')), findsOneWidget);
    expect(find.byKey(const ValueKey('lab-tab-recipe-book')), findsNothing);
  });

  testWidgets('al passo del Bottino il pulsante lo apre e il passo si completa', (tester) async {
    registerTestDependencies(
      events: [
        mark(OnboardingMark.tutorialStarted),
        SpeciesEncountered(speciesSci: 'Salvia officinalis', method: EncounterMethod.photo, occurredAt: day),
        LevelPassed(speciesSci: 'Salvia officinalis', level: 1, xp: 20, occurredAt: day),
        SpeciesEncountered(speciesSci: 'Laurus nobilis', method: EncounterMethod.photo, occurredAt: day),
        PotionBrewed(recipeId: 'r', essences: const {}, potency: 3, xp: 30, occurredAt: day),
      ],
    );
    await pumpDruidApp(tester);
    expect(find.byKey(const ValueKey('tutorial-trove')), findsOneWidget);
    expect(navLabel('Bottino'), findsOneWidget);

    await scrollAndTap(tester, find.byKey(const ValueKey('tutorial-action')));
    expect(currentTutorialStep(Get.find<ProgressController>().state), TutorialStep.apprentice);

    await openTab(tester, 'Home');
    await scrollAndTap(tester, find.byKey(const ValueKey('tutorial-action')));
    expect(tutorialStatus(Get.find<ProgressController>().state), TutorialStatus.finished);
    expect(find.byKey(const ValueKey('tutorial-apprentice')), findsNothing);
    expect(find.text('Curioso'), findsNothing);
  });

  testWidgets('"Salta il tutorial": la card sparisce, la barra si accende tutta, si è Apprendista', (tester) async {
    registerTestDependencies(events: [mark(OnboardingMark.tutorialStarted)]);
    await pumpDruidApp(tester);
    expect(find.text('Curioso'), findsOneWidget);

    await scrollAndTap(tester, find.byKey(const ValueKey('tutorial-skip')));

    expect(find.byKey(const ValueKey('tutorial-photograph')), findsNothing);
    expect(navLabel('Erbario'), findsOneWidget);
    expect(navLabel('Bottino'), findsOneWidget);
    expect(find.text('Apprendista'), findsOneWidget);
  });
}
