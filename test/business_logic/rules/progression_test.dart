import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/fun_facts.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/onboarding.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late Catalog catalog;
  final feb = DateTime(2027, 2, 14, 9);

  setUp(() => catalog = smallCatalog());

  GameState play(List<GameEvent> events) => GameState.replay(events);
  SpeciesEncountered met(String sci) =>
      SpeciesEncountered(speciesSci: sci, method: EncounterMethod.simulated, occurredAt: feb);
  LevelPassed passed(String sci, int level) => LevelPassed(speciesSci: sci, level: level, xp: 20, occurredAt: feb);

  group('maestria', () {
    const sci = 'Helleborus viridis';

    GameState studiedAndConsolidated() {
      final species = catalog.speciesBySci(sci)!;
      final events = <GameEvent>[met(sci)];
      for (final fact in factsOf(species, catalog)) {
        events.add(AnswerGiven(factId: fact.id, correct: true, mode: AnswerMode.learning, xp: 10, occurredAt: feb));
      }
      events.addAll([passed(sci, 1), passed(sci, 2), passed(sci, 3)]);
      for (final days in [1, 4]) {
        for (final fact in factsOf(species, catalog)) {
          events.add(
            AnswerGiven(
              factId: fact.id,
              correct: true,
              mode: AnswerMode.review,
              xp: 15,
              occurredAt: feb.add(Duration(days: days)),
            ),
          );
        }
      }
      return play(events);
    }

    test('solo studio e ripassi non bastano: servono le essenze attinte', () {
      final progress = masteryProgress(catalog.speciesBySci(sci)!, catalog, studiedAndConsolidated());
      expect(progress.consolidatedFacts, progress.totalFacts);
      expect(progress.reached, isFalse);
    });

    test('3 essenze con almeno 2 tratti diversi completano la maestria', () {
      var state = studiedAndConsolidated();
      for (final traits in [
        ['moon'],
        ['frost'],
        <String>[],
      ]) {
        state = state.apply(EssenceDrawn(speciesSci: sci, traits: traits, simulated: true, occurredAt: feb));
      }
      expect(masteryProgress(catalog.speciesBySci(sci)!, catalog, state).reached, isTrue);
    });

    test('3 essenze tutte con lo stesso tratto non bastano', () {
      var state = studiedAndConsolidated();
      for (var i = 0; i < 3; i++) {
        state = state.apply(EssenceDrawn(speciesSci: sci, traits: ['frost'], simulated: true, occurredAt: feb));
      }
      expect(masteryProgress(catalog.speciesBySci(sci)!, catalog, state).reached, isFalse);
    });

    test('i tratti distinti si contano su tutte le essenze, anche più tratti nella stessa', () {
      var state = studiedAndConsolidated();
      for (final traits in [
        ['rain', 'dusk'],
        ['rain'],
        <String>[],
      ]) {
        state = state.apply(EssenceDrawn(speciesSci: sci, traits: traits, simulated: true, occurredAt: feb));
      }
      final progress = masteryProgress(catalog.speciesBySci(sci)!, catalog, state);
      expect(progress.draws, 3);
      expect(progress.distinctTraits, 2);
      expect(progress.reached, isTrue);
    });
  });

  group('maestria da mantenere', () {
    const sci = 'Malva sylvestris';
    final factId = Fact.idOf(sci, FactKind.family);

    AnswerGiven review(DateTime at) =>
        AnswerGiven(factId: factId, correct: true, mode: AnswerMode.review, xp: 0, occurredAt: at);
    GameState mastered() => play([met(sci), passed(sci, 3), MasteryReached(speciesSci: sci, xp: 50, occurredAt: feb)]);

    test('resta sveglia per 29 giorni dopo la maestria, si assopisce al trentesimo', () {
      final state = mastered();
      expect(isMasteryDormant(state, sci, feb.add(const Duration(days: 29))), isFalse);
      expect(isMasteryDormant(state, sci, feb.add(const Duration(days: 30))), isTrue);
    });

    test('una domanda della specie entro i 30 giorni sposta la scadenza', () {
      final state = mastered().apply(review(feb.add(const Duration(days: 20))));
      expect(isMasteryDormant(state, sci, feb.add(const Duration(days: 45))), isFalse);
      expect(isMasteryDormant(state, sci, feb.add(const Duration(days: 50))), isTrue);
    });

    test('un ripasso arrivato dopo i 30 giorni non la risveglia', () {
      final late = feb.add(const Duration(days: 40));
      final state = mastered().apply(review(late));
      expect(state.dormantMastery, contains(sci));
      expect(isMasteryDormant(state, sci, late.add(const Duration(days: 1))), isTrue);
    });

    test('il mini-quiz superato la risveglia e fa ripartire i 30 giorni', () {
      final awake = feb.add(const Duration(days: 40));
      final state = mastered().apply(review(awake)).apply(MasteryAwakened(speciesSci: sci, occurredAt: awake));
      expect(isMasteryDormant(state, sci, awake.add(const Duration(days: 29))), isFalse);
      expect(isMasteryDormant(state, sci, awake.add(const Duration(days: 30))), isTrue);
    });

    test('le domande di prima della maestria non contano', () {
      final state = play([
        met(sci),
        review(feb.subtract(const Duration(days: 90))),
        passed(sci, 3),
        MasteryReached(speciesSci: sci, xp: 50, occurredAt: feb),
      ]);
      expect(state.dormantMastery, isEmpty);
      expect(isMasteryDormant(state, sci, feb.add(const Duration(days: 1))), isFalse);
    });

    test('senza maestria non c\'è niente da assopire', () {
      final state = play([met(sci), passed(sci, 3)]);
      expect(isMasteryDormant(state, sci, feb.add(const Duration(days: 365))), isFalse);
    });

    test('sopita, la purezza è quella del livello 3; il livello resta 4', () {
      final state = mastered();
      expect(purityLevelOf(state, sci, feb), 4);
      final later = feb.add(const Duration(days: 31));
      expect(purityLevelOf(state, sci, later), 3);
      expect(state.levelOf(sci), 4);
    });
  });

  group('livello successivo', () {
    test('si parte dal livello 1', () {
      expect(nextStudyLevel(catalog.speciesBySci('Malva sylvestris')!, catalog, play([met('Malva sylvestris')])), 1);
    });

    test('dopo il 3 le domande sono finite', () {
      final state = play([met('Fagus sylvatica'), passed('Fagus sylvatica', 3)]);
      expect(nextStudyLevel(catalog.speciesBySci('Fagus sylvatica')!, catalog, state), isNull);
    });
  });

  group('desiderata', () {
    test('primo avvio: solo specie sicure, prima quelle in stagione, poi le più comuni fuori stagione', () {
      // A febbraio sono in stagione elleboro e piè di gallo, entrambi tossici: restano fuori. Malva e faggio non sono
      // in stagione, ma sono le specie sicure più comuni.
      final first = seasonalSuggestions(catalog, GameState.empty, feb).map((s) => s.sci);
      expect(first, ['Malva sylvestris', 'Fagus sylvatica']);

      final july = seasonalSuggestions(catalog, GameState.empty, DateTime(2027, 7, 1)).map((s) => s.sci);
      expect(july, ['Malva sylvestris', 'Fagus sylvatica']);
    });

    test('primo avvio: le specie protette non si propongono', () {
      final protectedMalva = smallCatalog(
        protection: {
          'Malva sylvestris': ['regional-emilia-romagna'],
        },
      );
      expect(protectedMalva.speciesBySci('Malva sylvestris')!.isProtected, isTrue);
      expect(seasonalSuggestions(protectedMalva, GameState.empty, feb).map((s) => s.sci), ['Fagus sylvatica']);
    });

    test('dopo il primo avvio: tutte le specie in stagione non ancora in studio', () {
      final state = play([met('Fagus sylvatica')]);
      expect(seasonalSuggestions(catalog, state, feb).map((s) => s.sci), ['Helleborus viridis', 'Eranthis hyemalis']);

      final studying = state.apply(
        AnswerGiven(
          factId: Fact.idOf('Helleborus viridis', FactKind.scientificName),
          correct: true,
          mode: AnswerMode.learning,
          xp: 10,
          occurredAt: feb,
        ),
      );
      expect(seasonalSuggestions(catalog, studying, feb).map((s) => s.sci), ['Eranthis hyemalis']);
    });

    test('i fatti ritirati (stagione, nome comune) non tornano nei ripassi', () {
      final retired = Fact.idOf('Helleborus viridis', FactKind.season);
      final active = Fact.idOf('Helleborus viridis', FactKind.family);
      final state = play([
        for (final id in [retired, active])
          AnswerGiven(factId: id, correct: true, mode: AnswerMode.learning, xp: 10, occurredAt: feb),
        passed('Helleborus viridis', 2),
        passed('Helleborus viridis', 3),
      ]);
      final due = dueFacts(catalog, state, feb.add(const Duration(days: 2))).map((f) => f.id);
      expect(due, contains(active));
      expect(due, isNot(contains(retired)));
    });

    test('in studio: le incontrate e quelle con risposte o livelli, anche mai incontrate', () {
      final state = play([
        met('Fagus sylvatica'),
        AnswerGiven(
          factId: Fact.idOf('Malva sylvestris', FactKind.scientificName),
          correct: false,
          mode: AnswerMode.learning,
          xp: 2,
          occurredAt: feb,
        ),
        passed('Eranthis hyemalis', 1),
      ]);
      expect(speciesInStudy(state), {'Fagus sylvatica', 'Malva sylvestris', 'Eranthis hyemalis'});
    });

    test('una desiderata compiuta esce dall\'elenco', () {
      final state = play([
        DesiderataChanged(speciesSci: 'Eranthis hyemalis', marked: true, occurredAt: feb),
        DesiderataFulfilled(speciesSci: 'Eranthis hyemalis', xp: 15, occurredAt: feb),
      ]);
      expect(state.desiderata, isEmpty);
      expect(state.fulfilledDesiderata, {'Eranthis hyemalis'});
      expect(state.xp, 15);
    });
  });

  group('curiosità del giorno', () {
    test('nessuna curiosità senza specie incontrate', () {
      expect(funFactToRevealToday(catalog, GameState.empty, feb), isNull);
    });

    test('una al giorno, stabile nella giornata, poi un\'altra il giorno dopo', () {
      var state = play([met('Eranthis hyemalis')]);
      final first = funFactToRevealToday(catalog, state, feb)!;
      expect(funFactToRevealToday(catalog, state, feb)!.id, first.id, reason: 'stessa scelta riaprendo l\'app');

      state = state.apply(FunFactRevealed(funFactId: first.id, occurredAt: feb));
      expect(funFactToRevealToday(catalog, state, feb.add(const Duration(hours: 5))), isNull);
      expect(funFactOfToday(catalog, state, feb)!.id, first.id);

      // Al livello 0 il piè di gallo ha una sola curiosità: domani niente di nuovo...
      final tomorrow = feb.add(const Duration(days: 1));
      expect(funFactToRevealToday(catalog, state, tomorrow), isNull);
      // ...finché non si supera un livello, che sblocca le curiosità storiche.
      state = state.apply(passed('Eranthis hyemalis', 1));
      expect(funFactToRevealToday(catalog, state, tomorrow), isA<CuratedFunFactItem>());
    });

    test('le curiosità dei livelli alti arrivano solo dopo averli superati', () {
      final eranthis = catalog.speciesBySci('Eranthis hyemalis')!;
      final atZero = availableFunFacts(catalog, play([met('Eranthis hyemalis')]));
      expect(atZero.every((f) => f.level == 0), isTrue);
      expect(funFactsOf(eranthis, catalog).whereType<CuratedFunFactItem>(), isNotEmpty);

      final atOne = availableFunFacts(catalog, play([met('Eranthis hyemalis'), passed('Eranthis hyemalis', 1)]));
      expect(atOne.whereType<CuratedFunFactItem>(), isNotEmpty);
    });
  });

  group('apprendistato', () {
    test('le missioni si completano in ordine, guardando lo stato: prima lo studio, da casa', () {
      expect(currentMission(GameState.empty, catalog), Mission.firstLevel);

      var state = play([passed('Eranthis hyemalis', 1)]);
      expect(currentMission(state, catalog), Mission.visitErbario);

      state = state.apply(OnboardingMarked(mark: OnboardingMark.erbarioVisited, occurredAt: feb));
      expect(currentMission(state, catalog), Mission.firstEncounter, reason: 'le Desiderata non sono più un passo');

      state = state.apply(met('Eranthis hyemalis'));
      expect(currentMission(state, catalog), Mission.firstRecipe);

      // La Comune c'è già (livello 1): si completa aprendo il Ricettario.
      state = state.apply(OnboardingMarked(mark: OnboardingMark.albumVisited, occurredAt: feb));
      expect(currentMission(state, catalog), isNull);
      expect(isApprenticeshipComplete(state, catalog), isTrue);
    });

    test('"Studia la tua prima specie": prima le specie in studio, poi le proposte in stagione', () {
      expect(speciesToStudyFirst(GameState.empty, catalog, feb), 'Malva sylvestris');

      final earlier = SpeciesEncountered(
        speciesSci: 'Fagus sylvatica',
        method: EncounterMethod.simulated,
        occurredAt: feb.subtract(const Duration(days: 1)),
      );
      var state = play([met('Eranthis hyemalis'), earlier]);
      expect(speciesToStudyFirst(state, catalog, feb), 'Fagus sylvatica');

      // Livelli finiti: si passa alla specie successiva.
      for (var level = 1; level <= maxStudyLevel; level++) {
        state = state.apply(passed('Fagus sylvatica', level));
      }
      expect(speciesToStudyFirst(state, catalog, feb), 'Eranthis hyemalis');
    });

    test('saltare l\'apprendistato lo nasconde', () {
      final state = play([OnboardingMarked(mark: OnboardingMark.skipped, occurredAt: feb)]);
      expect(currentMission(state, catalog), isNull);
      expect(isApprenticeshipComplete(state, catalog), isFalse);
    });
  });
}
