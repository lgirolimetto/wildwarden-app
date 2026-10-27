import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/essence.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/potion.dart';
import 'package:druid_app/business_logic/rules/essences.dart';
import 'package:druid_app/business_logic/rules/recipes/potion_effects.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';
import 'package:druid_app/business_logic/rules/study/review_schedule.dart';

/// Stato di gioco derivato dagli eventi. Immutabile: `apply` restituisce un nuovo stato.
/// Non conosce il catalogo: le regole che servono anche i dati delle specie stanno in `rules/`.
class GameState {
  /// Data del primo incontro di ogni specie, per nome scientifico.
  final Map<String, DateTime> firstEncounters;

  /// PE di **carriera**: incassati, non calano mai. Decidono il rango.
  final int xp;

  /// PE **virtuali** dello studio, per specie: si incassano alla prima essenza attinta di quella specie (decisione 🟢
  /// "PE virtuali"). Non scadono.
  final Map<String, int> pendingXp;

  /// PE spesi (Bottino dell'Esperienza, tappa C): il **saldo** è carriera meno spesi.
  final int spentXp;

  /// Le Essenze attinte, nell'ordine: la Dispensa. Le Vis stanno nelle Essenze (vedi [vis]).
  final List<Essence> essences;

  /// Ultima raccolta di ogni specie: una al giorno.
  final Map<String, DateTime> lastDraws;

  /// Livello di studio più alto superato con le domande (1-3), per specie.
  final Map<String, int> passedLevels;
  final Set<String> mastered;

  /// Avanzamento dei fatti, per `Fact.id`.
  final Map<String, FactProgress> facts;

  /// Essenze attinte, per specie: per ognuna i suoi tratti (vuoto = nessun tratto).
  final Map<String, List<List<String>>> draws;
  final Set<String> desiderata;
  final Set<String> fulfilledDesiderata;

  /// Curiosità consegnate, con il giorno di consegna.
  final Map<String, DateTime> revealedFunFacts;
  final Map<String, String> notes;
  final Set<String> notebook;
  final Set<OnboardingMark> onboardingMarks;

  /// Ricette imparate (ricette ad affissi e Mitiche), per id, con il giorno in cui si sono imparate. Gli id delle
  /// ricette scritte a mano prima della tappa C restano qui ma non corrispondono più a nessuna ricetta.
  final Map<String, DateTime> learnedRecipes;

  /// Tavole trovate incomplete, per id, con i pezzi del nome che mancano ancora (sempre più di 0: completata, passa
  /// in [learnedRecipes]).
  final Map<String, int> missingPieces;

  /// Riciclati per grado: i doppioni usciti dal Bottino (si spendono nel riciclo, step 6).
  final Map<Grade, int> recycled;

  /// Bottini dell'Esperienza aperti, con il grado e il momento.
  final List<(Grade, DateTime)> troves;

  /// Quando sono state attinte le Essenze, in ordine.
  final List<DateTime> essenceTimes;

  /// Le pozioni preparate (lo Scaffale), nell'ordine.
  final List<Potion> potions;

  /// Quando si è preparato (anche le pozioni guastate): al massimo 2 al giorno.
  final List<DateTime> brewTimes;

  /// La potenza migliore raggiunta per ogni ricetta: la mostra la Tavola.
  final Map<String, int> bestPotency;

  /// Le piante che sai tossiche perché ti hanno guastato una pozione.
  final Set<String> knownToxic;

  /// Gli effetti delle pozioni usate, anche quelli finiti (vedi `activeEffects` in `rules/recipes/potion_effects.dart`).
  final List<ActiveEffect> effects;

  /// Momento del primo evento: quando si è cominciato a giocare.
  final DateTime? startedAt;

  /// Quando è stato offerto il regalo "bentornato" (`null` = mai).
  final DateTime? welcomeOfferedAt;
  final bool welcomeRedeemed;

  const GameState({
    this.firstEncounters = const {},
    this.xp = 0,
    this.pendingXp = const {},
    this.spentXp = 0,
    this.essences = const [],
    this.lastDraws = const {},
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
    this.learnedRecipes = const {},
    this.missingPieces = const {},
    this.recycled = const {},
    this.troves = const [],
    this.essenceTimes = const [],
    this.potions = const [],
    this.brewTimes = const [],
    this.bestPotency = const {},
    this.knownToxic = const {},
    this.effects = const [],
    this.startedAt,
    this.welcomeOfferedAt,
    this.welcomeRedeemed = false,
  });

  static const empty = GameState();

  /// Rilegge tutti gli eventi in ordine. Rileggere gli stessi eventi dà sempre lo stesso stato.
  factory GameState.replay(Iterable<GameEvent> events) => events.fold(empty, (state, event) => state.apply(event));

  bool hasEncountered(String speciesSci) => firstEncounters.containsKey(speciesSci);

  int get encounteredCount => firstEncounters.length;

  /// PE da incassare, in tutto.
  int get xpToCash => pendingXp.values.fold(0, (sum, xp) => sum + xp);

  /// PE che si possono spendere.
  int get balance => xp - spentXp;

  /// Vis che restano, per specie (anche 0, se le hai spese tutte).
  Map<String, int> get vis {
    final total = <String, int>{};
    for (final e in essences) {
      total[e.speciesSci] = (total[e.speciesSci] ?? 0) + e.vis;
    }
    return total;
  }

  /// Almeno un'essenza di questa specie è stata attinta: i suoi PE sono reali.
  bool hasDrawn(String speciesSci) => draws.containsKey(speciesSci);

  /// 0 = incontrata (o no) ma non studiata; 1-3 livelli superati; 4 = maestria.
  int levelOf(String speciesSci) => mastered.contains(speciesSci) ? 4 : (passedLevels[speciesSci] ?? 0);

  FactProgress progressOf(String factId) => facts[factId] ?? FactProgress.initial;

  /// Fatti da ripassare oggi.
  List<String> dueFactIds(DateTime now) => [
    for (final entry in facts.entries)
      if (entry.value.isDue(now)) entry.key,
  ];

  GameState apply(GameEvent event) {
    final started = startedAt == null ? _copy(startedAt: event.occurredAt) : this;
    final next = started._withXp(event);
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
      // La prima essenza di una specie incassa i suoi PE virtuali.
      EssenceDrawn(:final speciesSci, :final traits, :final occurredAt, :final purity, vis: final gained) => next._copy(
        xp: next.xp + (next.pendingXp[speciesSci] ?? 0),
        pendingXp: {...next.pendingXp}..remove(speciesSci),
        draws: {
          ...draws,
          speciesSci: [...?draws[speciesSci], traits],
        },
        essences: [
          ...essences,
          Essence(
            index: essences.length,
            speciesSci: speciesSci,
            traits: traits,
            // Gli eventi di prima della Dispensa non hanno la purezza: quella del livello di studio di allora.
            purity: purity ?? purityOfLevel(levelOf(speciesSci)),
            vis: gained,
            drawnAt: occurredAt,
          ),
        ],
        lastDraws: {...lastDraws, speciesSci: occurredAt},
        essenceTimes: [...essenceTimes, occurredAt],
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
      RecipeLearned(:final recipeId, :final occurredAt) =>
        learnedRecipes.containsKey(recipeId)
            ? next
            : next._copy(learnedRecipes: {...learnedRecipes, recipeId: occurredAt}),
      TroveOpened() => next._openTrove(event),
      WelcomeGiftOffered(:final occurredAt) => next._copy(welcomeOfferedAt: welcomeOfferedAt ?? occurredAt),
      XpGranted() => next,
      RecipeRecycled() => next._recycle(event),
      PotionBrewed() => next._brew(event),
      PotionUsed() => next._use(event),
    };
  }

  GameState _use(PotionUsed event) {
    final until = event.occurredAt.add(const Duration(days: potionEffectDays));
    return _copy(
      potions: [for (final p in potions) p.index == event.potionIndex ? p.used(event.occurredAt) : p],
      effects: [
        ...effects,
        ActiveEffect(effect: event.effect, strength: event.strength, until: until),
        if (event.touch case final touch?) ActiveEffect(effect: touch, strength: touchStrength, until: until),
      ],
    );
  }

  GameState _brew(PotionBrewed event) {
    final spent = [
      for (final e in essences)
        if (event.essences[e.index] case final int vis) e.withVis(e.vis - vis) else e,
    ];
    if (event.spoiled) {
      return _copy(
        essences: spent,
        brewTimes: [...brewTimes, event.occurredAt],
        knownToxic: {...knownToxic, ?event.freeSpecies},
      );
    }
    final best = bestPotency[event.recipeId] ?? 0;
    return _copy(
      essences: spent,
      brewTimes: [...brewTimes, event.occurredAt],
      potions: [
        ...potions,
        Potion(
          index: potions.length,
          recipeId: event.recipeId,
          potency: event.potency,
          touch: event.touch,
          brewedAt: event.occurredAt,
        ),
      ],
      bestPotency: {...bestPotency, event.recipeId: event.potency > best ? event.potency : best},
    );
  }

  GameState _recycle(RecipeRecycled event) {
    final missing = {...missingPieces};
    final learned = {...learnedRecipes};
    final left = (missing[event.recipeId] ?? 1) - 1;
    if (left > 0) {
      missing[event.recipeId] = left;
    } else {
      missing.remove(event.recipeId);
      learned.putIfAbsent(event.recipeId, () => event.occurredAt);
    }
    return _copy(
      missingPieces: missing,
      learnedRecipes: learned,
      recycled: {...recycled, event.fromGrade: (recycled[event.fromGrade] ?? 0) - event.used},
      essences: event.vis.entries.fold<List<Essence>>(essences, (list, e) => spendVis(list, e.key, e.value)),
    );
  }

  GameState _openTrove(TroveOpened event) {
    final learned = {...learnedRecipes};
    final missing = {...missingPieces};
    final recycledNow = {...recycled};
    for (final find in event.finds) {
      switch (find.kind) {
        case TroveFindKind.recipe when find.missing <= 0:
          learned.putIfAbsent(find.recipeId, () => event.occurredAt);
        case TroveFindKind.recipe:
          if (!learned.containsKey(find.recipeId)) missing[find.recipeId] = find.missing;
        case TroveFindKind.piece:
          final left = (missing[find.recipeId] ?? 1) - 1;
          if (left > 0) {
            missing[find.recipeId] = left;
          } else {
            missing.remove(find.recipeId);
            learned.putIfAbsent(find.recipeId, () => event.occurredAt);
          }
        case TroveFindKind.recycled:
          recycledNow[find.grade] = (recycledNow[find.grade] ?? 0) + 1;
      }
    }
    return _copy(
      spentXp: spentXp + event.price,
      learnedRecipes: learned,
      missingPieces: missing,
      recycled: recycledNow,
      troves: [...troves, (event.grade, event.occurredAt)],
      welcomeRedeemed: welcomeRedeemed || event.gift,
    );
  }

  /// Aggiunge i PE dell'evento: virtuali se vengono dallo studio di una specie mai attinta, reali altrimenti
  /// (raccolte, desiderata trovate, studio di specie già attinte).
  GameState _withXp(GameEvent event) {
    if (event.xp == 0) return this;
    final species = switch (event) {
      AnswerGiven(:final factId) => Fact.parseId(factId).speciesSci,
      LevelPassed(:final speciesSci) || MasteryReached(:final speciesSci) => speciesSci,
      _ => null,
    };
    if (species == null || hasDrawn(species)) return _copy(xp: xp + event.xp);
    return _copy(pendingXp: {...pendingXp, species: (pendingXp[species] ?? 0) + event.xp});
  }

  GameState _copy({
    Map<String, DateTime>? firstEncounters,
    int? xp,
    Map<String, int>? pendingXp,
    int? spentXp,
    List<Essence>? essences,
    Map<String, DateTime>? lastDraws,
    Map<String, int>? passedLevels,
    Set<String>? mastered,
    Map<String, FactProgress>? facts,
    Map<String, List<List<String>>>? draws,
    Set<String>? desiderata,
    Set<String>? fulfilledDesiderata,
    Map<String, DateTime>? revealedFunFacts,
    Map<String, String>? notes,
    Set<String>? notebook,
    Set<OnboardingMark>? onboardingMarks,
    Map<String, DateTime>? learnedRecipes,
    Map<String, int>? missingPieces,
    Map<Grade, int>? recycled,
    List<(Grade, DateTime)>? troves,
    List<DateTime>? essenceTimes,
    List<Potion>? potions,
    List<DateTime>? brewTimes,
    Map<String, int>? bestPotency,
    Set<String>? knownToxic,
    List<ActiveEffect>? effects,
    DateTime? startedAt,
    DateTime? welcomeOfferedAt,
    bool? welcomeRedeemed,
  }) => GameState(
    firstEncounters: firstEncounters ?? this.firstEncounters,
    xp: xp ?? this.xp,
    pendingXp: pendingXp ?? this.pendingXp,
    spentXp: spentXp ?? this.spentXp,
    essences: essences ?? this.essences,
    lastDraws: lastDraws ?? this.lastDraws,
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
    learnedRecipes: learnedRecipes ?? this.learnedRecipes,
    missingPieces: missingPieces ?? this.missingPieces,
    recycled: recycled ?? this.recycled,
    troves: troves ?? this.troves,
    essenceTimes: essenceTimes ?? this.essenceTimes,
    potions: potions ?? this.potions,
    brewTimes: brewTimes ?? this.brewTimes,
    bestPotency: bestPotency ?? this.bestPotency,
    knownToxic: knownToxic ?? this.knownToxic,
    effects: effects ?? this.effects,
    startedAt: startedAt ?? this.startedAt,
    welcomeOfferedAt: welcomeOfferedAt ?? this.welcomeOfferedAt,
    welcomeRedeemed: welcomeRedeemed ?? this.welcomeRedeemed,
  );
}
