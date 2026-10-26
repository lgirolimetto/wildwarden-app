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
      expect(find.textContaining('Riconoscerla ·'), findsOneWidget);
      await completeSession(tester);
      await scrollAndTap(tester, find.byKey(const ValueKey('close-session')));

      expect(Get.find<ProgressController>().state.levelOf('Malva sylvestris'), 1);
      expect(find.byKey(const ValueKey('mission-visitErbario')), findsOneWidget);
      await scrollTo(tester, find.byKey(const ValueKey('my-Malva sylvestris')));
      expect(find.textContaining('Non ancora Incontrata'), findsOneWidget);
    });

    testWidgets('la stellina della stagione segna una desiderata', (tester) async {
      registerTestDependencies(events: [_passed('Fagus sylvatica'), _erbarioVisited()]);
      await pumpDruidApp(tester);
      expect(find.text('Scegli le tue Desiderata'), findsOneWidget);

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

      expect(find.textContaining('Riconoscerla ·'), findsOneWidget);
    });

    testWidgets('il glossario si apre dalla missione e l\'apprendistato si può saltare', (tester) async {
      registerTestDependencies(events: [_passed('Fagus sylvatica')]);
      await pumpDruidApp(tester);

      await scrollAndTap(tester, find.widgetWithText(ActionChip, 'Erbario'));
      expect(find.textContaining('Collezione di piante'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.byKey(const ValueKey('skip-apprenticeship')));
      expect(find.byKey(const ValueKey('mission-visitErbario')), findsNothing);
    });
  });

  group('PE virtuali', () {
    testWidgets('i PE dello studio aspettano in Home; la prima essenza li incassa e la specie si esaurisce', (
      tester,
    ) async {
      registerTestDependencies(
        events: [
          _met('Helleborus viridis'),
          LevelPassed(speciesSci: 'Helleborus viridis', level: 1, xp: 20, occurredAt: _feb),
        ],
      );
      await pumpDruidApp(tester);
      expect(find.text('20 PE da Incassare: si Incassano alla prima Essenza di ogni specie'), findsOneWidget);

      await openTab(tester, 'Erbario');
      await scrollAndTap(tester, find.byKey(const ValueKey('met-Helleborus viridis')));
      await scrollTo(tester, find.byKey(const ValueKey('species-xp-to-cash')));
      // Un'essenza porta tutti i tratti veri in quel momento: se ne scelgono più d'uno.
      await scrollAndTap(tester, find.byKey(const ValueKey('draw-trait-rain')));
      await scrollAndTap(tester, find.byKey(const ValueKey('draw-trait-dusk')));
      await scrollAndTap(tester, find.byKey(const ValueKey('draw-trait-moon')));
      await scrollAndTap(tester, find.byKey(const ValueKey('simulate-draw')));

      final state = Get.find<ProgressController>().state;
      // I tratti si salvano nell'ordine in cui si mostrano: luce, luna, meteo.
      expect(state.draws['Helleborus viridis'], [
        ['dusk', 'moon', 'rain'],
      ]);
      // Tre tratti distinti, ma il contatore si ferma al traguardo.
      expect(find.text('Essenze Attinte: 1/3 · Tratti diversi: 2/2'), findsOneWidget);
      expect(state.xpToCash, 0);
      expect(state.xp, 20 + XpRules.essenceDrawn);
      expect(state.vis['Helleborus viridis'], 10);
      await scrollTo(tester, find.byKey(const ValueKey('draw-exhausted')));
      expect(find.text('Vis immagazzinate: 10'), findsOneWidget);
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
      expect(find.textContaining('Riconoscerla ·'), findsOneWidget);

      await completeSession(tester);

      expect(find.text('Fine sessione'), findsOneWidget);
      expect(find.textContaining('Livello 1 superato'), findsOneWidget);
      expect(Get.find<ProgressController>().state.levelOf('Helleborus viridis'), 1);

      await scrollAndTap(tester, find.byKey(const ValueKey('close-session')));
      expect(find.text('Studia il Livello 2'), findsOneWidget);
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
      expect(Get.find<StudyController>().summary!.answers, 4);
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
      expect(find.text('Nel Taccuino'), findsOneWidget);

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

      await openTab(tester, 'Home');
      await scrollToTop(tester);
      expect(find.text('3 Fatti da ripassare oggi'), findsOneWidget);
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

      // I livelli in lista, con i nomi interi; il pulsante in fondo dice solo "Studia".
      final study = find.widgetWithText(FilledButton, 'Studia');
      await scrollTo(tester, study);
      for (final name in ['1 · Riconoscerla', '2 · Famiglia e vita', '3 · Il suo ambiente', '4 · Maestria']) {
        expect(find.text(name), findsOneWidget);
      }
      expect(study, findsOneWidget);

      final level2 = find.text('Si rivela al Livello 2 (Famiglia e vita)');
      await scrollTo(tester, level2);
      expect(find.text('Helleborus viridis'), findsOneWidget, reason: 'nome scientifico: rivelato al livello 1');
      expect(level2, findsOneWidget);
      expect(find.text('Ranunculaceae'), findsNothing, reason: 'famiglia: ancora chiusa');
      final level3 = find.text('Si rivela al Livello 3 (Il suo ambiente)');
      await scrollTo(tester, level3.first);
      expect(level3, findsWidgets);
    });

    testWidgets('album delle ricette: solo le ricette che conosci, con il contatore', (tester) async {
      registerTestDependencies(
        events: [RecipeLearned(recipeId: 'pozione-prova-comune', origin: RecipeOrigin.study, occurredAt: _feb)],
      );
      await pumpDruidApp(tester);
      await openTab(tester, 'Ricette');

      expect(find.text('1 di 4'), findsOneWidget);
      expect(find.text('Pozione di Prova del Prato'), findsOneWidget);
      expect(find.byKey(const ValueKey('figurine-infuso-prova-faggio')), findsNothing, reason: 'niente segnaposto');
      expect(find.text('?'), findsNothing);

      // Imparata: ingredienti con il nome della pianta, anche se non incontrata.
      await scrollAndTap(tester, find.byKey(const ValueKey('figurine-pozione-prova-comune')));
      expect(find.text('2 × Malva selvatica'), findsOneWidget);
      expect(find.text('Ingredienti già Incontrati 0/2'), findsOneWidget);
      expect(find.text('Effetto di gioco di prova.'), findsOneWidget);
    });

    testWidgets('un ingrediente con un tratto spiega quando vale', (tester) async {
      registerTestDependencies(
        events: [LevelPassed(speciesSci: 'Eranthis hyemalis', level: 2, xp: 20, occurredAt: _feb)],
      );
      await pumpDruidApp(tester);
      await openTab(tester, 'Ricette');

      await scrollAndTap(tester, find.byKey(const ValueKey('figurine-tintura-lanterna-inverno')));
      expect(find.text('Quando fa sotto zero: brina e ghiaccio.'), findsOneWidget);
    });

    testWidgets('nessuna ricetta conosciuta: l\'album spiega come impararle', (tester) async {
      registerTestDependencies();
      await pumpDruidApp(tester);
      await openTab(tester, 'Ricette');

      expect(find.text('0 di 4'), findsOneWidget);
      expect(find.byKey(const ValueKey('recipes-empty')), findsOneWidget);
    });

    testWidgets('legenda e glossario: simboli e termini del gioco', (tester) async {
      registerTestDependencies();
      await pumpDruidApp(tester);
      await openTab(tester, 'Impostazioni');
      await scrollAndTap(tester, find.text('Legenda e glossario'));

      expect(find.text('Legenda'), findsOneWidget);
      for (final grade in ['Comune', 'Non comune', 'Rara', 'Mitica']) {
        expect(find.text(grade), findsOneWidget);
      }
      expect(find.text('Specie Protetta dalla legge: si guarda e si fotografa'), findsOneWidget);
      // I tratti dicono quando valgono: sempre di giorno o tutto il giorno.
      final dusk = find.text('Da circa un\'ora prima del tramonto fino al tramonto, mai a buio fatto.');
      await scrollTo(tester, dusk);
      expect(dusk, findsOneWidget);
      // Divisi per tipo: luce del giorno, luna (con crescente e calante), meteo.
      for (final group in ['Luce del giorno', 'Luna', 'Meteo', 'Luna crescente', 'Luna calante']) {
        final title = find.text(group);
        await scrollTo(tester, title);
        expect(title, findsOneWidget);
      }

      // Glossario nella seconda linguetta.
      expect(find.byKey(const ValueKey('gloss-vis')), findsNothing);
      await scrollToTop(tester);
      await tester.tap(find.text('Glossario'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byKey(const ValueKey('gloss-vis')));
      expect(find.textContaining('La linfa sottile delle piante'), findsOneWidget);
    });

    testWidgets('anteprima dei gradi: una scheda per grado, con il cerchietto', (tester) async {
      registerTestDependencies();
      await pumpDruidApp(tester);
      await openTab(tester, 'Impostazioni');
      await scrollAndTap(tester, find.byKey(const ValueKey('open-grade-preview')));

      for (final key in ['preview-common', 'preview-uncommon', 'preview-rare', 'preview-mythic']) {
        await scrollTo(tester, find.byKey(ValueKey(key)));
        expect(find.byKey(ValueKey(key)), findsOneWidget);
      }
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
