import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';
import 'package:druid_app/business_logic/rules/study/questions.dart';
import 'package:druid_app/business_logic/rules/study/xp_rules.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/controllers/study/study_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late InMemoryGameEventStore store;
  late FakeClock clock;
  late Catalog catalog;
  late ProgressController progress;
  late StudyController study;

  setUp(() async {
    store = InMemoryGameEventStore();
    clock = FakeClock();
    catalog = smallCatalog();
    progress = ProgressController(store, clock, catalog: () => catalog);
    await progress.load();
    study = StudyController(progress, random: Random(2));
  });

  Future<void> answerAll({bool firstWrong = false}) async {
    var first = true;
    while (study.question != null) {
      final q = study.question!;
      await study.answer(firstWrong && first ? q.options.firstWhere((o) => o != q.answer) : q.answer);
      first = false;
      await study.next();
    }
  }

  test('superare un livello: risposte e livello salvati, PE nel riepilogo', () async {
    await progress.encounter('Helleborus viridis', method: EncounterMethod.simulated);
    study.startLevel(catalog, 'Helleborus viridis', 1);

    await answerAll();

    expect(study.summary!.levelPassed, 1);
    expect(study.summary!.xp, 2 * XpRules.correctFirstTry + XpRules.levelPassed);
    expect(progress.state.levelOf('Helleborus viridis'), 1);
    expect(progress.state.xp, study.summary!.xp);
    expect(store.events.whereType<AnswerGiven>(), hasLength(2));
  });

  test('un errore: la risposta resta visibile finché non si va avanti, e il fatto torna', () async {
    await progress.encounter('Helleborus viridis', method: EncounterMethod.simulated);
    study.startLevel(catalog, 'Helleborus viridis', 1);
    final q = study.question!;

    await study.answer(q.options.firstWhere((o) => o != q.answer));
    expect(study.lastOutcome!.correct, isFalse);
    expect(study.lastOutcome!.willReturn, isTrue);

    await study.answer(q.answer); // ignorata: prima bisogna andare avanti
    expect(store.events.whereType<AnswerGiven>(), hasLength(1));

    await study.next();
    await answerAll();
    expect(study.summary!.answers, 3);
    expect(study.summary!.correct, 2);
  });

  test('ripassi: niente da ripassare subito, poi i fatti tornano il giorno dopo', () async {
    await progress.encounter('Helleborus viridis', method: EncounterMethod.simulated);
    study.startLevel(catalog, 'Helleborus viridis', 1);
    await answerAll();

    expect(study.startReview(catalog), isFalse);

    clock.advance(const Duration(days: 1));
    expect(study.startReview(catalog), isTrue);
    expect(study.mode, AnswerMode.review);
    await answerAll();
    expect(study.summary!.xp, 2 * XpRules.reviewRemembered);
  });

  test('un livello senza fatti si salta: finito il 2, la specie passa al 3 senza domande', () async {
    // Malva modificata: né stagione né quota prevalenti ⇒ nessun fatto al livello 3.
    final json = jsonDecode(File('test/fixtures/catalog_small.json').readAsStringSync()) as Map<String, dynamic>;
    final malva = (json['species'] as List).cast<Map<String, dynamic>>().firstWhere(
      (s) => s['sci'] == 'Malva sylvestris',
    );
    malva['bandShare'] = {'plain': 0.4, 'hill': 0.3, 'mountain': 0.3};
    catalog = Catalog.fromJson(json);
    expect(factsAtLevel(catalog.speciesBySci('Malva sylvestris')!, catalog, 3), isEmpty);

    await progress.encounter('Malva sylvestris', method: EncounterMethod.simulated);
    for (final level in [1, 2]) {
      study.startLevel(catalog, 'Malva sylvestris', level);
      await answerAll();
    }

    expect(progress.state.levelOf('Malva sylvestris'), 3);
    final skipped = store.events.whereType<LevelPassed>().last;
    expect(skipped.level, 3);
    expect(skipped.xp, 0, reason: 'un livello saltato non dà PE');
  });

  test('le opzioni della domanda corrente non cambiano finché non si risponde', () async {
    await progress.encounter('Fagus sylvatica', method: EncounterMethod.simulated);
    study.startLevel(catalog, 'Fagus sylvatica', 2);
    final first = study.question!;
    expect(identical(study.question, first), isTrue);
    expect(first.options, isA<List<AnswerOption>>());
  });
}
