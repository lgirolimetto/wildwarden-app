import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
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
    // Livello 1: aspetto, nome scientifico, forma di crescita.
    expect(study.summary!.xp, 3 * XpRules.correctFirstTry + XpRules.levelPassed);
    expect(progress.state.levelOf('Helleborus viridis'), 1);
    expect(progress.state.xpToCash, study.summary!.xp, reason: 'mai attinta: PE da incassare');
    expect(store.events.whereType<AnswerGiven>(), hasLength(3));
  });

  test('livello 1 superato: si impara la Comune della pianta, salvata come evento', () async {
    study.startLevel(catalog, 'Malva sylvestris', 1);
    await answerAll();

    final learned = study.summary!.learnedRecipe!;
    expect(learned.id, recipeBookOf(catalog).pageOf('Malva sylvestris')!.recipes.first.id);
    expect(learned.plant.sci, 'Malva sylvestris');
    expect(store.events.whereType<RecipeLearned>().single.recipeId, learned.id);
    expect(progress.state.learnedRecipes.keys, {learned.id});
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
    expect(study.summary!.answers, 4);
    expect(study.summary!.correct, 3);
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
    // Primo ripasso: i fatti sono nella scatola 1.
    expect(study.summary!.xp, 3 * XpRules.review(correct: true, box: 1));
  });

  test('le opzioni della domanda corrente non cambiano finché non si risponde', () async {
    await progress.encounter('Fagus sylvatica', method: EncounterMethod.simulated);
    study.startLevel(catalog, 'Fagus sylvatica', 2);
    final first = study.question!;
    expect(identical(study.question, first), isTrue);
    expect(first.options, isA<List<AnswerOption>>());
  });
}
