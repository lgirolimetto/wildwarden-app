import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/recipe.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';

/// Regole che combinano stato di gioco e catalogo: maestria, desiderata, ricette, ripassi.

const masteryDraws = 3;
const masteryDistinctTraits = 2;
const maxDesiderata = 3;

class MasteryProgress {
  final int consolidatedFacts;
  final int totalFacts;
  final int draws;
  final int distinctTraits;
  final bool studyComplete;

  const MasteryProgress({
    required this.consolidatedFacts,
    required this.totalFacts,
    required this.draws,
    required this.distinctTraits,
    required this.studyComplete,
  });

  /// Con il solo studio non si arriva alla maestria: servono anche le essenze attinte sul campo.
  bool get reached =>
      studyComplete &&
      consolidatedFacts == totalFacts &&
      draws >= masteryDraws &&
      distinctTraits >= masteryDistinctTraits;
}

MasteryProgress masteryProgress(Species species, Catalog catalog, GameState state) {
  final facts = factsOf(species, catalog);
  final traits = state.draws[species.sci] ?? const [];
  return MasteryProgress(
    consolidatedFacts: facts.where((f) => state.progressOf(f.id).consolidated).length,
    totalFacts: facts.length,
    draws: traits.length,
    distinctTraits: traits.whereType<String>().toSet().length,
    studyComplete: state.levelOf(species.sci) >= maxStudyLevel,
  );
}

/// Prossimo livello da studiare (1-3), `null` se le domande sono finite. Un livello senza fatti (dati
/// insufficienti) si salta.
int? nextStudyLevel(Species species, Catalog catalog, GameState state) {
  for (var level = state.levelOf(species.sci) + 1; level <= maxStudyLevel; level++) {
    if (factsAtLevel(species, catalog, level).isNotEmpty) return level;
  }
  return null;
}

/// Fatti da ripassare oggi, risolti sul catalogo (i fatti di specie sparite dal catalogo si ignorano).
List<Fact> dueFacts(Catalog catalog, GameState state, DateTime now) => [
  for (final id in state.dueFactIds(now))
    if (catalog.speciesBySci(Fact.parseId(id).speciesSci) case final species?) Fact(species, Fact.parseId(id).kind),
];

bool canAddDesiderata(GameState state) => state.desiderata.length < maxDesiderata;

/// Specie consigliate come desiderata: non ancora incontrate, in stagione questo mese, le più comuni prima.
List<Species> desiderataSuggestions(Catalog catalog, GameState state, DateTime now, {int limit = 5}) =>
    (catalog.species
            .where((s) => !state.hasEncountered(s.sci) && !state.desiderata.contains(s.sci))
            .where((s) => s.bestMonths.contains(now.month))
            .toList()
          ..sort((a, b) => b.observations.compareTo(a.observations)))
        .take(limit)
        .toList();

bool isRecipeUnlocked(Recipe recipe, GameState state) =>
    recipe.unlock == null || state.levelOf(recipe.unlock!.speciesSci) >= recipe.unlock!.level;

/// Un ingrediente è noto se è "qualsiasi specie" o se la specie è già stata incontrata.
bool isIngredientKnown(Ingredient ingredient, GameState state) =>
    ingredient.speciesSci == null || state.hasEncountered(ingredient.speciesSci!);
