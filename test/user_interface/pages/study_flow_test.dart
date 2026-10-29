import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/business_logic/rules/study/xp_rules.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/controllers/study/study_controller.dart';
import 'package:druid_app/controllers/subscription/subscription_controller.dart';
import 'package:druid_app/user_interface/common_widgets/potion_vessel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

final _feb = DateTime(2027, 2, 1);

SpeciesEncountered _met(String sci) =>
    SpeciesEncountered(speciesSci: sci, method: EncounterMethod.photo, occurredAt: _feb);

LevelPassed _passed(String sci) => LevelPassed(speciesSci: sci, level: 1, xp: 20, occurredAt: _feb);

void main() {
  tearDown(Get.reset);

  group('primo giro e desiderata', () {
    testWidgets('primo avvio: la card del tutorial e le specie proposte da studiare, anche mai incontrate', (
      tester,
    ) async {
      registerTestDependencies();
      await pumpDruidApp(tester);
      expect(find.byKey(const ValueKey('tutorial-intro')), findsOneWidget);
      expect(find.text('Curioso'), findsOneWidget);

      // A febbraio le specie in stagione sono tossiche: si propongono le sicure più comuni.
      expect(find.byKey(const ValueKey('seasonal-Malva sylvestris')), findsOneWidget);
      expect(find.byKey(const ValueKey('seasonal-Eranthis hyemalis')), findsNothing);

      await scrollAndTap(tester, find.byKey(const ValueKey('study-suggestion-Malva sylvestris')));
      expect(find.textContaining('Riconoscerla ·'), findsOneWidget);
      await completeSession(tester);
      await scrollAndTap(tester, find.byKey(const ValueKey('close-session')));

      expect(Get.find<ProgressController>().state.levelOf('Malva sylvestris'), 1);
      await scrollTo(tester, find.byKey(const ValueKey('my-Malva sylvestris')));
      expect(find.textContaining('Non ancora Incontrata'), findsOneWidget);
    });

    testWidgets('la stellina della stagione segna una desiderata', (tester) async {
      registerTestDependencies(events: [_passed('Fagus sylvatica')]);
      await pumpDruidApp(tester);

      // Dopo il primo avvio si propongono tutte le specie in stagione, anche le tossiche.
      await scrollAndTap(tester, find.byKey(const ValueKey('add-desiderata-Eranthis hyemalis')));
      expect(Get.find<ProgressController>().state.desiderata, {'Eranthis hyemalis'});
    });

    testWidgets('incontrare una desiderata la compie: PE in più', (tester) async {
      registerTestDependencies(
        events: [
          _passed('Fagus sylvatica'),
          DesiderataChanged(speciesSci: 'Eranthis hyemalis', marked: true, occurredAt: _feb),
        ],
      );
      await pumpDruidApp(tester);
      final xpBefore = Get.find<ProgressController>().state.xp;

      await openTab(tester, 'Erbario');
      await scrollAndTap(tester, find.byKey(const ValueKey('simulate-Eranthis hyemalis')));

      expect(Get.find<ProgressController>().state.xp - xpBefore, XpRules.desiderataFulfilled);
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

      await openSettings(tester);
      final advance = find.byKey(const ValueKey('advance-1'));
      await scrollTo(tester, advance);
      await tester.tap(advance);
      await tester.pumpAndSettle();
      expect(find.text('Giorno simulato: +1'), findsOneWidget);

      await goBack(tester);
      await scrollToTop(tester);
      expect(find.text('3 Fatti da ripassare oggi'), findsOneWidget);
      await scrollAndTap(tester, find.byKey(const ValueKey('start-review')));
      await answerCurrentQuestion(tester);
      expect(find.textContaining('Te lo ricordavi!'), findsOneWidget);
    });
  });

  group('maestria da mantenere', () {
    const sci = 'Helleborus viridis';
    final mastered = <GameEvent>[
      _met(sci),
      LevelPassed(speciesSci: sci, level: 3, xp: 0, occurredAt: _feb),
      MasteryReached(speciesSci: sci, xp: 0, occurredAt: _feb),
    ];

    Future<void> answerQuiz(WidgetTester tester, {required int wrong}) async {
      final study = Get.find<StudyController>();
      var left = wrong;
      while (study.question != null) {
        await answerCurrentQuestion(tester, correctly: left-- <= 0);
        await goToNextQuestion(tester);
      }
    }

    testWidgets('dopo 30 giorni la Home propone di risvegliarla; 4 giuste su 5 bastano', (tester) async {
      final deps = registerTestDependencies(events: mastered);
      deps.clock.advance(const Duration(days: 20));
      await pumpDruidApp(tester);

      await scrollTo(tester, find.byKey(const ValueKey('my-$sci')));
      expect(find.text('Maestria da risvegliare'), findsOneWidget);
      await scrollAndTap(tester, find.byKey(const ValueKey('awaken-$sci')));
      expect(find.textContaining('Risveglio della Maestria ·'), findsOneWidget);

      await answerQuiz(tester, wrong: 1);
      expect(find.byKey(const ValueKey('summary-awakened')), findsOneWidget);
      expect(Get.find<ProgressController>().masteryDormant(sci), isFalse);
      await scrollAndTap(tester, find.byKey(const ValueKey('close-session')));
      expect(find.text('Maestria da risvegliare'), findsNothing);
    });

    testWidgets('nella scheda: sopita, mini-quiz sbagliato, riprova subito e si risveglia', (tester) async {
      final deps = registerTestDependencies(events: mastered);
      deps.clock.advance(const Duration(days: 20));
      await pumpDruidApp(tester);
      await openTab(tester, 'Erbario');
      await tester.tap(find.byKey(const ValueKey('met-$sci')));
      await tester.pumpAndSettle();
      expect(find.text('Maestria sopita'), findsWidgets, reason: 'nella testata, al posto di "Maestria"');

      await scrollTo(tester, find.byKey(const ValueKey('mastery-dormant')));
      expect(find.textContaining('pure al 90 % invece che al 100 %'), findsOneWidget);
      await scrollAndTap(tester, find.byKey(const ValueKey('awaken-mastery')));
      await answerQuiz(tester, wrong: 2);
      expect(find.byKey(const ValueKey('summary-still-dormant')), findsOneWidget);
      expect(Get.find<ProgressController>().masteryDormant(sci), isTrue);

      await scrollAndTap(tester, find.byKey(const ValueKey('retry-awakening')));
      await completeSession(tester);
      expect(find.byKey(const ValueKey('summary-awakened')), findsOneWidget);
      await scrollAndTap(tester, find.byKey(const ValueKey('close-session')));

      await scrollTo(tester, find.textContaining('dopo 30 giorni senza, si assopisce'));
      expect(find.byKey(const ValueKey('mastery-dormant')), findsNothing);
      expect(find.text('Maestria raggiunta'), findsOneWidget);
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

    testWidgets('Ricettario: le pagine delle piante che conosci, con gli slot vuoti e la ricetta aperta', (
      tester,
    ) async {
      registerTestDependencies(events: [_passed('Malva sylvestris')]);
      await pumpDruidApp(tester);
      await openTab(tester, 'Laboratorio');

      final malva = recipeBookOf(smallCatalog()).pageOf('Malva sylvestris')!;
      expect(find.text('1 Tavola'), findsOneWidget);
      expect(find.text('1 Pagina su 4 · 0 complete'), findsOneWidget);
      expect(find.text('1 Tavola su 3'), findsOneWidget);
      await scrollAndTap(tester, find.byKey(const ValueKey('recipe-book-page-Malva sylvestris')));

      // La pagina: la Comune imparata studiando, le altre Tavole come slot vuoti con il solo grado.
      expect(find.text('1 Tavola su 3'), findsOneWidget);
      expect(find.text("Tratti d'elezione"), findsOneWidget);
      expect(find.byKey(ValueKey('plate-${malva.recipes.first.id}')), findsOneWidget);
      expect(find.byKey(ValueKey('empty-slot-${malva.recipes[1].id}')), findsOneWidget);
      expect(find.text(malva.recipes[1].name('it')), findsNothing, reason: 'lo slot vuoto non svela il nome');
      // Il recipiente della base in tutte e due; il liquido (colore dei tratti) solo nella Tavola che hai.
      final vessels = tester.widgetList<PotionVessel>(find.byType(PotionVessel)).toList();
      expect(vessels.map((v) => v.shape), contains(VesselShape.of(malva.recipes.first.base)));
      expect(vessels.where((v) => v.liquids.isEmpty), isNotEmpty);
      expect(vessels.where((v) => v.liquids.length == malva.recipes.first.traits.length), isNotEmpty);

      await scrollAndTap(tester, find.byKey(ValueKey('plate-${malva.recipes.first.id}')));
      expect(find.text(malva.recipes.first.name('it')), findsOneWidget);
      expect(find.text('1 × Malva selvatica'), findsOneWidget);
      expect(find.text('1 × qualsiasi specie'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('recipe-months')),
        findsNothing,
        reason: 'la stagione è nella scheda della specie',
      );
      expect(find.byKey(const ValueKey('ingredient-Malva sylvestris')), findsOneWidget);
    });

    testWidgets('un ingrediente con un tratto spiega quando vale', (tester) async {
      final eranthis = recipeBookOf(smallCatalog()).pageOf('Eranthis hyemalis')!;
      final frosty = eranthis.recipes.firstWhere((r) => r.traits.contains(Trait.frost));
      registerTestDependencies(
        events: [RecipeLearned(recipeId: frosty.id, origin: RecipeOrigin.trove, occurredAt: _feb)],
      );
      await pumpDruidApp(tester);
      await openTab(tester, 'Laboratorio');

      await scrollAndTap(tester, find.byKey(const ValueKey('recipe-book-page-Eranthis hyemalis')));
      await scrollAndTap(tester, find.byKey(ValueKey('plate-${frosty.id}')));
      expect(find.text('Quando fa sotto zero: brina e ghiaccio.'), findsOneWidget);
    });

    testWidgets('nessuna ricetta conosciuta: il Ricettario spiega come impararle; le Mitiche della Zona in cima', (
      tester,
    ) async {
      registerTestDependencies();
      await pumpDruidApp(tester);
      await openTab(tester, 'Laboratorio');

      expect(find.byKey(const ValueKey('recipe-book-empty')), findsOneWidget);
      expect(find.text('Mitiche · Provincia di Bologna'), findsOneWidget);
      expect(find.text('0 su 1'), findsOneWidget);

      await scrollAndTap(tester, find.byKey(const ValueKey('recipe-book-mythics')));
      expect(find.text('Tavola n. 1'), findsOneWidget);
      expect(find.text('Da trovare'), findsOneWidget);
      expect(find.text('La Lanterna di Santa Lucia'), findsNothing);
    });

    testWidgets('legenda e glossario: simboli e termini del gioco', (tester) async {
      registerTestDependencies();
      await pumpDruidApp(tester);
      await openSettings(tester);
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
      await openSettings(tester);
      await scrollAndTap(tester, find.byKey(const ValueKey('open-grade-preview')));

      for (final key in ['preview-common', 'preview-uncommon', 'preview-rare', 'preview-mythic']) {
        await scrollTo(tester, find.byKey(ValueKey(key)));
        expect(find.byKey(ValueKey(key)), findsOneWidget);
      }
    });

    testWidgets('prova sul campo: si apre dagli strumenti di prova e avvisa se manca la chiave Pl@ntNet', (
      tester,
    ) async {
      registerTestDependencies();
      await pumpDruidApp(tester);
      await openSettings(tester);
      await scrollAndTap(tester, find.byKey(const ValueKey('open-field-test')));

      expect(find.byKey(const ValueKey('field-test-run')), findsOneWidget);
      expect(find.textContaining('Manca la chiave Pl@ntNet'), findsOneWidget);
      expect(find.text('Nessuna prova salvata'), findsOneWidget);
    });

    testWidgets('il consiglio del giorno al posto della curiosità (che per ora non si consegna)', (tester) async {
      registerTestDependencies(events: [_met('Eranthis hyemalis')]);
      await pumpDruidApp(tester);
      await scrollTo(tester, find.byKey(const ValueKey('tip-of-day')));

      expect(find.text('Consiglio del giorno'), findsOneWidget);
      expect(Get.find<ProgressController>().state.revealedFunFacts, isEmpty);
    });

    testWidgets('azzerare i progressi richiede due tocchi', (tester) async {
      registerTestDependencies(events: [_met('Eranthis hyemalis')]);
      await pumpDruidApp(tester);
      await openSettings(tester);
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
