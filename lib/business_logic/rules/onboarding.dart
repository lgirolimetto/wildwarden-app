import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/business_logic/rules/recipes/album.dart';

/// Missioni dell'apprendistato (onboarding). Ogni missione si completa quando lo stato di gioco lo dice:
/// niente codice sparso nelle pagine.
///
/// Si comincia da casa, studiando; poi l'erbario, le desiderata e il campo; infine l'album, dove c'è la Ricetta
/// Comune imparata studiando. Stazione e ritorno arrivano nei blocchi 2-3.
enum Mission {
  firstLevel,
  visitErbario,
  markDesiderata,
  firstEncounter,
  firstRecipe;

  bool isDone(GameState state, Catalog catalog) => switch (this) {
    Mission.visitErbario => state.onboardingMarks.contains(OnboardingMark.erbarioVisited),
    Mission.markDesiderata => state.desiderata.isNotEmpty || state.fulfilledDesiderata.isNotEmpty,
    Mission.firstEncounter => state.encounteredCount > 0,
    Mission.firstLevel => state.passedLevels.isNotEmpty,
    Mission.firstRecipe =>
      state.onboardingMarks.contains(OnboardingMark.albumVisited) && knownRecipeIds(catalog, state).isNotEmpty,
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

/// Specie da studiare per la missione "Studia la tua prima specie": una già in studio con un livello da superare
/// (prima le incontrate, in ordine di incontro), altrimenti la prima proposta in stagione.
String? speciesToStudyFirst(GameState state, Catalog catalog, DateTime now) {
  final byEncounter = state.firstEncounters.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
  final inStudy = [
    for (final entry in byEncounter) entry.key,
    ...speciesInStudy(state).difference(state.firstEncounters.keys.toSet()).toList()..sort(),
  ];
  for (final sci in inStudy) {
    final species = catalog.speciesBySci(sci);
    if (species != null && nextStudyLevel(species, catalog, state) != null) return species.sci;
  }
  return seasonalSuggestions(catalog, state, now).firstOrNull?.sci;
}
