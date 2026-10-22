import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';
import 'package:druid_app/business_logic/rules/study/review_schedule.dart';

/// Stato di gioco derivato dagli eventi. Immutabile: `apply` restituisce un nuovo stato.
/// Non conosce il catalogo: le regole che servono anche i dati delle specie stanno in `rules/`.
class GameState {
  /// Data del primo incontro di ogni specie, per nome scientifico.
  final Map<String, DateTime> firstEncounters;
  final int xp;

  /// Livello di studio più alto superato con le domande (1-3), per specie.
  final Map<String, int> passedLevels;
  final Set<String> mastered;

  /// Avanzamento dei fatti, per `Fact.id`.
  final Map<String, FactProgress> facts;

  /// Tratti delle essenze attinte, per specie (`null` = nessun tratto).
  final Map<String, List<String?>> draws;
  final Set<String> desiderata;
  final Set<String> fulfilledDesiderata;

  /// Curiosità consegnate, con il giorno di consegna.
  final Map<String, DateTime> revealedFunFacts;
  final Map<String, String> notes;
  final Set<String> notebook;
  final Set<OnboardingMark> onboardingMarks;

  const GameState({
    this.firstEncounters = const {},
    this.xp = 0,
    this.passedLevels = const {},
    this.mastered = const {},
    this.facts = const {},
    this.draws = const {},
    this.desiderata = const {},
    this.fulfilledDesiderata = const {},
    this.revealedFunFacts = const {},
    this.notes = const {},
    this.notebook = const {},
    this.onboardingMarks = const {},
  });

  static const empty = GameState();

  /// Rilegge tutti gli eventi in ordine. Rileggere gli stessi eventi dà sempre lo stesso stato.
  factory GameState.replay(Iterable<GameEvent> events) => events.fold(empty, (state, event) => state.apply(event));

  bool hasEncountered(String speciesSci) => firstEncounters.containsKey(speciesSci);

  int get encounteredCount => firstEncounters.length;

  /// 0 = incontrata (o no) ma non studiata; 1-3 livelli superati; 4 = maestria.
  int levelOf(String speciesSci) => mastered.contains(speciesSci) ? 4 : (passedLevels[speciesSci] ?? 0);

  FactProgress progressOf(String factId) => facts[factId] ?? FactProgress.initial;

  /// Fatti da ripassare oggi.
  List<String> dueFactIds(DateTime now) => [
    for (final entry in facts.entries)
      if (entry.value.isDue(now)) entry.key,
  ];

  GameState apply(GameEvent event) {
    final next = _withXp(event.xp);
    return switch (event) {
      SpeciesEncountered(:final speciesSci, :final occurredAt) =>
        next.hasEncountered(speciesSci)
            ? next
            : next._copy(firstEncounters: {...firstEncounters, speciesSci: occurredAt}),
      AnswerGiven(:final factId, :final correct, :final mode, :final occurredAt) => next._copy(
        facts: {
          ...facts,
          factId: mode == AnswerMode.learning
              ? progressOf(factId).afterLearningAnswer(correct: correct)
              : progressOf(factId).afterReview(correct: correct, at: occurredAt),
        },
      ),
      LevelPassed(:final speciesSci, :final level, :final occurredAt) => next._copy(
        passedLevels: {
          ...passedLevels,
          speciesSci: level > (passedLevels[speciesSci] ?? 0) ? level : passedLevels[speciesSci]!,
        },
        facts: {
          ...facts,
          for (final kind in FactKind.values.where((k) => k.level == level))
            if (facts.containsKey(Fact.idOf(speciesSci, kind)))
              Fact.idOf(speciesSci, kind): progressOf(Fact.idOf(speciesSci, kind)).afterLevelPassed(occurredAt),
        },
      ),
      MasteryReached(:final speciesSci) => next._copy(mastered: {...mastered, speciesSci}),
      EssenceDrawn(:final speciesSci, :final trait) => next._copy(
        draws: {
          ...draws,
          speciesSci: [...?draws[speciesSci], trait],
        },
      ),
      DesiderataChanged(:final speciesSci, :final marked) => next._copy(
        desiderata: marked ? {...desiderata, speciesSci} : ({...desiderata}..remove(speciesSci)),
      ),
      DesiderataFulfilled(:final speciesSci) => next._copy(
        desiderata: {...desiderata}..remove(speciesSci),
        fulfilledDesiderata: {...fulfilledDesiderata, speciesSci},
      ),
      FunFactRevealed(:final funFactId, :final occurredAt) => next._copy(
        revealedFunFacts: {...revealedFunFacts, funFactId: occurredAt},
      ),
      NoteSaved(:final speciesSci, :final text) => next._copy(notes: {...notes, speciesSci: text}),
      NotebookEntrySaved(:final factId) => next._copy(notebook: {...notebook, factId}),
      OnboardingMarked(:final mark) => next._copy(onboardingMarks: {...onboardingMarks, mark}),
    };
  }

  GameState _withXp(int gained) => gained == 0 ? this : _copy(xp: xp + gained);

  GameState _copy({
    Map<String, DateTime>? firstEncounters,
    int? xp,
    Map<String, int>? passedLevels,
    Set<String>? mastered,
    Map<String, FactProgress>? facts,
    Map<String, List<String?>>? draws,
    Set<String>? desiderata,
    Set<String>? fulfilledDesiderata,
    Map<String, DateTime>? revealedFunFacts,
    Map<String, String>? notes,
    Set<String>? notebook,
    Set<OnboardingMark>? onboardingMarks,
  }) => GameState(
    firstEncounters: firstEncounters ?? this.firstEncounters,
    xp: xp ?? this.xp,
    passedLevels: passedLevels ?? this.passedLevels,
    mastered: mastered ?? this.mastered,
    facts: facts ?? this.facts,
    draws: draws ?? this.draws,
    desiderata: desiderata ?? this.desiderata,
    fulfilledDesiderata: fulfilledDesiderata ?? this.fulfilledDesiderata,
    revealedFunFacts: revealedFunFacts ?? this.revealedFunFacts,
    notes: notes ?? this.notes,
    notebook: notebook ?? this.notebook,
    onboardingMarks: onboardingMarks ?? this.onboardingMarks,
  );
}
