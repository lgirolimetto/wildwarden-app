import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/tutorial_intermediate.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

void main() {
  tearDown(Get.reset);
  final day = DateTime(2027, 2, 14, 9);
  OnboardingMarked mark(OnboardingMark m) => OnboardingMarked(mark: m, occurredAt: day);
  final baseDone = [mark(OnboardingMark.tutorialStarted), mark(OnboardingMark.tutorialFinished)];
  IntermediateStatus status() => intermediateStatus(Get.find<ProgressController>().state);

  testWidgets('durante il Base la card dell\'Intermedio non c\'è', (tester) async {
    registerTestDependencies(events: [mark(OnboardingMark.tutorialStarted)]);
    await pumpDruidApp(tester);

    expect(find.byKey(const ValueKey('intermediate-intro'), skipOffstage: false), findsNothing);
  });

  testWidgets('finito il Base: "Inizia", il passo con il nome dell\'aromatica, e la Home resta completa', (
    tester,
  ) async {
    registerTestDependencies(
      events: [
        ...baseDone,
        SpeciesEncountered(speciesSci: 'Salvia rosmarinus', method: EncounterMethod.photo, occurredAt: day),
        LevelPassed(speciesSci: 'Salvia rosmarinus', level: 1, xp: 20, occurredAt: day),
      ],
      catalog: Valid(smallCatalog(kitchen: true)),
    );
    await pumpDruidApp(tester);
    expect(find.byKey(const ValueKey('intermediate-intro')), findsOneWidget);

    await scrollAndTap(tester, find.byKey(const ValueKey('intermediate-action')));

    expect(status(), IntermediateStatus.inProgress);
    expect(find.byKey(const ValueKey('intermediate-study')), findsOneWidget);
    expect(find.text('Tutorial intermedio · passo 2 di 6'), findsOneWidget);
    expect(find.textContaining('Supera il Livello 2 di Rosmarino'), findsOneWidget);
    expect(find.byKey(const ValueKey('tip-of-day'), skipOffstage: false), findsOneWidget);
  });

  testWidgets('"Salta il tutorial intermedio": la card sparisce', (tester) async {
    registerTestDependencies(events: [...baseDone, mark(OnboardingMark.intermediateStarted)]);
    await pumpDruidApp(tester);

    await scrollAndTap(tester, find.byKey(const ValueKey('intermediate-skip')));

    expect(status(), IntermediateStatus.skipped);
    expect(find.byKey(const ValueKey('intermediate-herb'), skipOffstage: false), findsNothing);
  });
}
