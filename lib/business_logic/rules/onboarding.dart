import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/progression.dart';

/// Missioni dell'apprendistato (onboarding). Ogni missione si completa quando lo stato di gioco lo dice:
/// niente codice sparso nelle pagine.
///
/// Nel blocco 1 ci sono i passi che non richiedono il campo; stazione e ritorno arrivano nei blocchi 2-3.
enum Mission {
  visitErbario,
  markDesiderata,
  firstEncounter,
  firstLevel,
  firstRecipe;

  bool isDone(GameState state, Catalog catalog) => switch (this) {
    Mission.visitErbario => state.onboardingMarks.contains(OnboardingMark.erbarioVisited),
    Mission.markDesiderata => state.desiderata.isNotEmpty || state.fulfilledDesiderata.isNotEmpty,
    Mission.firstEncounter => state.encounteredCount > 0,
    Mission.firstLevel => state.passedLevels.isNotEmpty,
    Mission.firstRecipe => catalog.recipes.any((r) => r.unlock != null && isRecipeUnlocked(r, state)),
  };
}

/// Missione corrente dell'apprendistato; `null` se è completo o se l'utente l'ha saltato.
Mission? currentMission(GameState state, Catalog catalog) {
  if (state.onboardingMarks.contains(OnboardingMark.skipped)) return null;
  for (final mission in Mission.values) {
    if (!mission.isDone(state, catalog)) return mission;
  }
  return null;
}

bool isApprenticeshipComplete(GameState state, Catalog catalog) =>
    Mission.values.every((m) => m.isDone(state, catalog));

/// Specie da studiare per la missione "Studiala": la prima incontrata che ha ancora un livello da superare.
String? speciesToStudyFirst(GameState state, Catalog catalog) {
  final byEncounter = state.firstEncounters.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
  for (final entry in byEncounter) {
    final species = catalog.speciesBySci(entry.key);
    if (species != null && nextStudyLevel(species, catalog, state) != null) return species.sci;
  }
  return null;
}
