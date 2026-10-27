import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';
import 'package:druid_app/business_logic/rules/study/questions.dart';
import 'package:druid_app/business_logic/rules/study/review_schedule.dart';
import 'package:druid_app/business_logic/rules/study/study_session.dart';
import 'package:druid_app/business_logic/rules/study/xp_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

AnswerOption wrongOf(Question q) => q.options.firstWhere((o) => o != q.answer);

void main() {
  late Catalog catalog;
  final at = DateTime(2027, 2, 14, 9);

  setUp(() => catalog = smallCatalog());

  StudySession level(int level, {int seed = 1}) =>
      StudySession.learning(speciesSci: 'Helleborus viridis', level: level, catalog: catalog, random: Random(seed));

  group('PE nello studio', () {
    test('giusto al primo colpo: +10', () {
      final session = level(1);
      final outcome = session.answer(session.current.answer, state: GameState.empty, at: at);
      expect(outcome.xp, XpRules.correctFirstTry);
    });

    test('primo errore: +2; giusto dopo l\'errore: +5', () {
      var state = GameState.empty;
      final session = level(1);
      final fact = session.current.fact;

      final wrong = session.answer(wrongOf(session.current), state: state, at: at);
      state = state.apply(wrong.event);
      expect(wrong.xp, XpRules.firstMistake);

      while (session.current.fact != fact) {
        state = state.apply(session.answer(session.current.answer, state: state, at: at).event);
      }
      expect(session.answer(session.current.answer, state: state, at: at).xp, XpRules.correctAfterMistake);
    });

    test('il secondo errore sullo stesso fatto non dà PE (anche in una sessione successiva)', () {
      var state = GameState.empty;
      final first = level(1);
      final fact = first.current.fact;
      state = state.apply(first.answer(wrongOf(first.current), state: state, at: at).event);

      final second = level(1);
      while (second.current.fact != fact) {
        state = state.apply(second.answer(second.current.answer, state: state, at: at).event);
      }
      expect(second.answer(wrongOf(second.current), state: state, at: at).xp, 0);
    });
  });

  group('errori che tornano', () {
    test('un fatto sbagliato torna dopo al massimo due domande, in un\'altra forma se possibile', () {
      final session = level(2, seed: 4);
      final firstQuestion = session.current;
      final outcome = session.answer(wrongOf(firstQuestion), state: GameState.empty, at: at);
      expect(outcome.willReturn, isTrue);

      var steps = 0;
      while (session.current.fact != firstQuestion.fact) {
        session.answer(session.current.answer, state: GameState.empty, at: at);
        steps++;
      }
      expect(steps, lessThanOrEqualTo(2));
      if (formsFor(firstQuestion.fact, catalog).length > 1) {
        expect(session.current.form, isNot(firstQuestion.form));
      }
    });

    test('il livello finisce solo quando ogni fatto è stato superato', () {
      final session = level(2);
      final facts = factsAtLevel(catalog.speciesBySci('Helleborus viridis')!, catalog, 2);
      session.answer(wrongOf(session.current), state: GameState.empty, at: at);

      var answers = 1;
      while (!session.isFinished) {
        session.answer(session.current.answer, state: GameState.empty, at: at);
        answers++;
      }
      expect(answers, facts.length + 1);
      expect(session.completedFacts, facts.length);
    });
  });

  group('ripassi', () {
    test('nel ripasso dimenticare non dà PE e niente torna in coda', () {
      final fact = Fact(catalog.speciesBySci('Helleborus viridis')!, FactKind.scientificName);
      final session = StudySession.review(dueFacts: [fact], catalog: catalog, random: Random(1));

      final outcome = session.answer(wrongOf(session.current), state: GameState.empty, at: at);

      expect(outcome.xp, 0);
      expect(outcome.willReturn, isFalse);
      expect(session.isFinished, isTrue);
    });

    test('le scatole: superato il livello il fatto torna domani; ricordato sale, dimenticato riparte', () {
      final passed = FactProgress.initial.afterLevelPassed(at);
      expect(passed.box, 1);
      expect(passed.isDue(at), isFalse);
      expect(passed.isDue(at.add(const Duration(days: 1))), isTrue);

      final remembered = passed.afterReview(correct: true, at: at.add(const Duration(days: 1)));
      expect(remembered.box, 2);
      expect(remembered.isDue(at.add(const Duration(days: 3))), isFalse);
      expect(remembered.isDue(at.add(const Duration(days: 4))), isTrue);

      final forgotten = remembered.afterReview(correct: false, at: at.add(const Duration(days: 4)));
      expect(forgotten.box, 1);
    });

    test('la scatola non supera la sesta (180 giorni)', () {
      var p = FactProgress.initial.afterLevelPassed(at);
      for (var i = 0; i < 10; i++) {
        p = p.afterReview(correct: true, at: at);
      }
      expect(p.box, maxBox);
      expect(p.consolidated, isTrue);
    });
  });

  test('titoli dai PE totali', () {
    expect(Rank.of(0), Rank.apprentice);
    expect(Rank.of(49), Rank.apprentice);
    expect(Rank.of(50), Rank.wanderer);
    expect(Rank.of(999), Rank.wanderer);
    expect(Rank.of(1000), Rank.seeker);
    expect(Rank.of(3500), Rank.warden);
    expect(Rank.of(17999), Rank.warden);
    expect(Rank.of(18000), Rank.botanomancer);
    expect(Rank.botanomancer.next, isNull);
  });

  test('stato: livello superato → i fatti di quel livello entrano nei ripassi', () {
    final session = level(1);
    var state = GameState.empty;
    while (!session.isFinished) {
      state = state.apply(session.answer(session.current.answer, state: state, at: at).event);
    }
    state = state.apply(
      LevelPassed(speciesSci: 'Helleborus viridis', level: 1, xp: XpRules.levelPassed, occurredAt: at),
    );

    expect(state.levelOf('Helleborus viridis'), 1);
    expect(state.dueFactIds(at), isEmpty);
    expect(state.dueFactIds(at.add(const Duration(days: 1))), hasLength(3));
    // Specie mai attinta: i PE dello studio sono virtuali.
    expect(state.pendingXp['Helleborus viridis'], 3 * XpRules.correctFirstTry + XpRules.levelPassed);
    expect(state.xp, 0);
  });
}
