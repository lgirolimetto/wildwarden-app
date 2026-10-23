import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
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

  test('le opzioni della domanda corrente non cambiano finché non si risponde', () async {
    await progress.encounter('Fagus sylvatica', method: EncounterMethod.simulated);
    study.startLevel(catalog, 'Fagus sylvatica', 2);
    final first = study.question!;
    expect(identical(study.question, first), isTrue);
    expect(first.options, isA<List<AnswerOption>>());
  });
}
