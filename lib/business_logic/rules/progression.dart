import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';

/// Regole che combinano stato di gioco e catalogo: maestria, desiderata, ripassi. Le ricette stanno in `recipes/`.

const masteryDraws = 3;
const masteryDistinctTraits = 2;

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
  final draws = state.draws[species.sci] ?? const [];
  return MasteryProgress(
    consolidatedFacts: facts.where((f) => state.progressOf(f.id).consolidated).length,
    totalFacts: facts.length,
    draws: draws.length,
    // Un'essenza porta più tratti: contano quelli distinti su tutte le essenze della specie.
    distinctTraits: draws.expand((traits) => traits).toSet().length,
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

/// Fatti da ripassare oggi, risolti sul catalogo. Si ignorano i fatti di specie sparite dal catalogo e quelli
/// ritirati (es. la stagione), che non si chiedono più.
List<Fact> dueFacts(Catalog catalog, GameState state, DateTime now) => [
  for (final id in state.dueFactIds(now))
    if ((catalog.speciesBySci(Fact.parseId(id).speciesSci), Fact.parseId(id).kind) case (
      final species?,
      final kind,
    ) when !kind.retired)
      Fact(species, kind),
];

/// Specie che stai studiando: incontrate, o con almeno una risposta o un livello di studio. Si studia anche ciò che
/// non si è ancora incontrato.
Set<String> speciesInStudy(GameState state) => {
  ...state.firstEncounters.keys,
  ...state.passedLevels.keys,
  for (final id in state.facts.keys) Fact.parseId(id).speciesSci,
};

/// Quante specie si propongono al primo avvio.
const firstStudySuggestions = 3;

/// Specie "In stagione adesso" da studiare (e da segnare come desiderata), le più comuni prima.
///
/// Al primo avvio (nessuna specie in studio) sono [firstStudySuggestions], scelte tra quelle sicure: niente
/// tossiche né protette. Se in stagione non ce ne sono abbastanza si completano con le più comuni fuori stagione:
/// la sicurezza non si allenta mai. Dopo, tutte le specie in stagione non ancora in studio, fino a [limit].
List<Species> seasonalSuggestions(Catalog catalog, GameState state, DateTime now, {int limit = 8}) {
  final inStudy = speciesInStudy(state);
  bool inSeason(Species s) => s.bestMonths.contains(now.month);
  final candidates = catalog.species.where((s) => !inStudy.contains(s.sci)).toList()
    ..sort((a, b) => b.observations.compareTo(a.observations));
  if (inStudy.isNotEmpty) return candidates.where(inSeason).take(limit).toList();
  final safe = candidates.where((s) => !catalog.safety.containsKey(s.sci) && !s.isProtected);
  return [...safe.where(inSeason), ...safe.where((s) => !inSeason(s))].take(firstStudySuggestions).toList();
}
