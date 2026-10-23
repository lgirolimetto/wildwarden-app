import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/study/xp_rules.dart';
import 'package:druid_app/controllers/home/home_controller.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/controllers/study/study_controller.dart';
import 'package:druid_app/controllers/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/test_app.dart';

final _feb = DateTime(2027, 2, 1);

SpeciesEncountered _met(String sci) =>
    SpeciesEncountered(speciesSci: sci, method: EncounterMethod.photo, occurredAt: _feb);

LevelPassed _passed(String sci) => LevelPassed(speciesSci: sci, level: 1, xp: 20, occurredAt: _feb);

OnboardingMarked _erbarioVisited() => OnboardingMarked(mark: OnboardingMark.erbarioVisited, occurredAt: _feb);

void main() {
  tearDown(Get.reset);

  group('apprendistato e desiderata', () {
    testWidgets('primo avvio: si comincia studiando una delle specie proposte, anche mai incontrata', (tester) async {
      registerTestDependencies();
      await pumpDruidApp(tester);
      expect(find.byKey(const ValueKey('mission-firstLevel')), findsOneWidget);

      // A febbraio le specie in stagione sono tossiche: si propongono le sicure più comuni.
      expect(find.byKey(const ValueKey('seasonal-Malva sylvestris')), findsOneWidget);
      expect(find.byKey(const ValueKey('seasonal-Eranthis hyemalis')), findsNothing);

      await scrollAndTap(tester, find.byKey(const ValueKey('study-suggestion-Malva sylvestris')));
      expect(find.text('Malva selvatica · livello 1'), findsOneWidget);
      await completeSession(tester);
      await scrollAndTap(tester, find.byKey(const ValueKey('close-session')));

      expect(Get.find<ProgressController>().state.levelOf('Malva sylvestris'), 1);
      expect(find.byKey(const ValueKey('mission-visitErbario')), findsOneWidget);
      await scrollTo(tester, find.byKey(const ValueKey('my-Malva sylvestris')));
      expect(find.textContaining('Non ancora incontrata'), findsOneWidget);
    });

    testWidgets('la stellina della stagione segna una desiderata', (tester) async {
      registerTestDependencies(events: [_passed('Fagus sylvatica'), _erbarioVisited()]);
      await pumpDruidApp(tester);
      expect(find.text('Scegli le tue desiderata'), findsOneWidget);

      // Dopo il primo avvio si propongono tutte le specie in stagione, anche le tossiche.
      await scrollAndTap(tester, find.byKey(const ValueKey('add-desiderata-Eranthis hyemalis')));
      await scrollToTop(tester);
      expect(find.text('Incontra una specie'), findsOneWidget);
      await scrollTo(tester, find.byKey(const ValueKey('desiderata-Eranthis hyemalis')));
      expect(find.byKey(const ValueKey('desiderata-Eranthis hyemalis')), findsOneWidget);
    });

    testWidgets('incontrare una desiderata la compie: PE e missione successiva', (tester) async {
      registerTestDependencies(
        events: [
          _passed('Fagus sylvatica'),
          _erbarioVisited(),
          DesiderataChanged(speciesSci: 'Eranthis hyemalis', marked: true, occurredAt: _feb),
        ],
      );
      await pumpDruidApp(tester);
      final xpBefore = Get.find<ProgressController>().state.xp;

      await scrollAndTap(tester, find.byKey(const ValueKey('simulate-desiderata-Eranthis hyemalis')));

      expect(Get.find<ProgressController>().state.xp - xpBefore, XpRules.desiderataFulfilled);
      await scrollToTop(tester);
      expect(find.byKey(const ValueKey('mission-firstRecipe')), findsOneWidget);
    });

    testWidgets('il pulsante della missione porta all\'erbario e la compie', (tester) async {
      registerTestDependencies(events: [_passed('Fagus sylvatica')]);
      await pumpDruidApp(tester);

      await tester.tap(find.byKey(const ValueKey('mission-action-visitErbario')));
      await tester.pumpAndSettle();

      expect(find.text('0/4 trovate'), findsOneWidget);
      expect(Get.find<HomeController>().tab, HomeController.erbarioTab);
      expect(Get.find<ProgressController>().state.onboardingMarks, contains(OnboardingMark.erbarioVisited));
    });

    testWidgets('il pulsante della prima missione apre il livello 1 della prima specie proposta', (tester) async {
      registerTestDependencies();
      await pumpDruidApp(tester);

      await tester.tap(find.byKey(const ValueKey('mission-action-firstLevel')));
      await tester.pumpAndSettle();

      expect(find.text('Malva selvatica · livello 1'), findsOneWidget);
    });

    testWidgets('il glossario si apre dalla missione e l\'apprendistato si può saltare', (tester) async {
      registerTestDependencies(events: [_passed('Fagus sylvatica')]);
      await pumpDruidApp(tester);

      await tester.tap(find.widgetWithText(ActionChip, 'Erbario'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Collezione di piante'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('skip-apprenticeship')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('mission-visitErbario')), findsNothing);
    });
  });

  group('studio', () {
    testWidgets('studiare un livello fino al riepilogo: livello e PE salvati', (tester) async {
      registerTestDependencies(events: [_met('Helleborus viridis')]);
      await pumpDruidApp(tester);

      final study = find.byKey(const ValueKey('study-Helleborus viridis'));
      await scrollTo(tester, study);
      await tester.tap(study);
      await tester.pumpAndSettle();
      expect(find.text('Elleboro verde · livello 1'), findsOneWidget);

      await completeSession(tester);

      expect(find.text('Fine sessione'), findsOneWidget);
      expect(find.textContaining('Livello 1 superato'), findsOneWidget);
      expect(Get.find<ProgressController>().state.levelOf('Helleborus viridis'), 1);

      await scrollAndTap(tester, find.byKey(const ValueKey('close-session')));
      expect(find.text('Studia il livello 2'), findsOneWidget);
    });

    testWidgets('una risposta sbagliata mostra la soluzione e il fatto torna', (tester) async {
      registerTestDependencies(events: [_met('Helleborus viridis')]);
      await pumpDruidApp(tester);
      await scrollAndTap(tester, find.byKey(const ValueKey('study-Helleborus viridis')));

      await answerCurrentQuestion(tester, correctly: false);

      expect(find.text('Non proprio.'), findsOneWidget);
      expect(find.text('Tornerà tra poco, in un\'altra forma.'), findsOneWidget);
      expect(find.text('+2 PE'), findsOneWidget);
      await goToNextQuestion(tester);
      await completeSession(tester);
      expect(Get.find<StudyController>().summary!.answers, 3);
    });

    testWidgets('senza Diario il taccuino è bloccato e spiega cosa offre', (tester) async {
      registerTestDependencies(events: [_met('Helleborus viridis')]);
      await pumpDruidApp(tester);
      await scrollAndTap(tester, find.byKey(const ValueKey('study-Helleborus viridis')));
      await answerCurrentQuestion(tester);

      await scrollAndTap(tester, find.byKey(const ValueKey('notebook-locked')));

      expect(find.byKey(const ValueKey('diario-upsell')), findsOneWidget);
    });

    testWidgets('con il Diario si salva nel taccuino e lo si ritrova cercando', (tester) async {
      registerTestDependencies(
        events: [_met('Helleborus viridis')],
        preferences: {SubscriptionController.simulatedKey: 'true'},
      );
      await pumpDruidApp(tester);
      await scrollAndTap(tester, find.byKey(const ValueKey('study-Helleborus viridis')));
      await answerCurrentQuestion(tester);

      await scrollAndTap(tester, find.byKey(const ValueKey('notebook-save')));
      expect(find.text('Nel taccuino'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('open-notebook')));
      await tester.pumpAndSettle();
      expect(find.text('Elleboro verde'), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('notebook-search')), 'faggio');
      await tester.pumpAndSettle();
      expect(find.text('Nessun risultato.'), findsOneWidget);
    });

    testWidgets('i ripassi arrivano dopo aver fatto passare un giorno', (tester) async {
      registerTestDependencies(events: [_met('Helleborus viridis')]);
      await pumpDruidApp(tester);
      await scrollAndTap(tester, find.byKey(const ValueKey('study-Helleborus viridis')));
      await completeSession(tester);
      await scrollAndTap(tester, find.byKey(const ValueKey('close-session')));
      expect(find.byKey(const ValueKey('start-review')), findsNothing);

      await openTab(tester, 'Impostazioni');
      final advance = find.byKey(const ValueKey('advance-1'));
      await scrollTo(tester, advance);
      await tester.tap(advance);
      await tester.pumpAndSettle();
      expect(find.text('Giorno simulato: +1'), findsOneWidget);

      await openTab(tester, 'Studio');
      await scrollToTop(tester);
      expect(find.text('2 fatti da ripassare oggi'), findsOneWidget);
      await scrollAndTap(tester, find.byKey(const ValueKey('start-review')));
      await answerCurrentQuestion(tester);
      expect(find.textContaining('Te lo ricordavi!'), findsOneWidget);
    });
  });

  group('erbario, ricette, curiosità', () {
    testWidgets('la scheda della specie si rivela livello per livello', (tester) async {
      registerTestDependencies(
        events: [
          _met('Helleborus viridis'),
          LevelPassed(speciesSci: 'Helleborus viridis', level: 1, xp: 20, occurredAt: _feb),
        ],
      );
      await pumpDruidApp(tester);
      await openTab(tester, 'Erbario');
      await tester.tap(find.byKey(const ValueKey('met-Helleborus viridis')));
      await tester.pumpAndSettle();

      final level2 = find.text('Si rivela al livello 2 (Conoscere)');
      await scrollTo(tester, level2);
      expect(find.text('Helleborus viridis'), findsOneWidget, reason: 'nome scientifico: rivelato al livello 1');
      expect(level2, findsOneWidget);
      expect(find.text('Ranunculaceae'), findsNothing, reason: 'famiglia: ancora chiusa');
      final level3 = find.text('Si rivela al livello 3 (Dove e quando)');
      await scrollTo(tester, level3.first);
      expect(level3, findsWidgets);
    });

    testWidgets('ricetta bloccata: un ingrediente ignoto mostra un indizio', (tester) async {
      registerTestDependencies(events: [_met('Eranthis hyemalis')]);
      await pumpDruidApp(tester);
      await openTab(tester, 'Ricette');

      expect(find.text('Bloccata'), findsWidgets);
      expect(find.textContaining('???'), findsWidgets);
      expect(find.textContaining('Indizio: Una pianta della famiglia Ranunculaceae'), findsOneWidget);
    });

    testWidgets('curiosità del giorno: consegnata all\'apertura dello Studio', (tester) async {
      registerTestDependencies(events: [_met('Eranthis hyemalis')]);
      await pumpDruidApp(tester);
      await tester.pumpAndSettle();

      expect(Get.find<ProgressController>().state.revealedFunFacts, hasLength(1));
      expect(find.textContaining('posto tra le piante spontanee'), findsOneWidget);
    });

    testWidgets('azzerare i progressi richiede due tocchi', (tester) async {
      registerTestDependencies(events: [_met('Eranthis hyemalis')]);
      await pumpDruidApp(tester);
      await openTab(tester, 'Impostazioni');
      final reset = find.byKey(const ValueKey('debug-reset'));
      await scrollTo(tester, reset);

      await tester.tap(reset);
      await tester.pumpAndSettle();
      expect(Get.find<ProgressController>().state.encounteredCount, 1);
      expect(find.text('Tocca di nuovo per cancellare tutto'), findsOneWidget);

      await tester.tap(reset);
      await tester.pumpAndSettle();
      expect(Get.find<ProgressController>().state.encounteredCount, 0);
    });
  });
}
