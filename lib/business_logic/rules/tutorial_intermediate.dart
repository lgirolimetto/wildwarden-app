import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/economy.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/business_logic/rules/recipes/recipe_book.dart';
import 'package:druid_app/business_logic/rules/tutorial.dart';

/// Il tutorial intermedio (capitolo 03, 2026-10-29): dopo il Base, quando vuoi, ancora da casa con le aromatiche.
/// Insegna Attingere alla propria Stazione, le Qualia, la Non comune e il Tocco dello slot libero. Come il Base, lo
/// stato si ricava dagli eventi.

/// I passi, in ordine. Ognuno si completa da sé quando succede la cosa, tranne l'ultimo.
enum IntermediateStep {
  /// Un'aromatica Incontrata (chi ha fatto il Base ce l'ha già).
  herb,

  /// Supera il Livello 2 dell'aromatica: impari la sua Non comune.
  study,

  /// Attingi alla Stazione dell'aromatica con il Sole, dopo l'inizio dell'Intermedio.
  drawSun,

  /// Le Vis del compagno che la Non comune chiede.
  companion,

  /// Prepara la Non comune, con una terza specie nello slot libero (il Tocco).
  brew,

  /// "Hai finito il tutorial intermedio": si chiude con un tocco.
  finished,
}

/// [locked] finché il Base non è finito o saltato.
enum IntermediateStatus { locked, notStarted, inProgress, skipped, finished }

IntermediateStatus intermediateStatus(GameState state) {
  final marks = state.onboardingMarks;
  if (marks.contains(OnboardingMark.intermediateFinished)) return IntermediateStatus.finished;
  if (marks.contains(OnboardingMark.intermediateSkipped)) return IntermediateStatus.skipped;
  final base = tutorialStatus(state);
  if (base != TutorialStatus.finished && base != TutorialStatus.skipped) return IntermediateStatus.locked;
  if (marks.contains(OnboardingMark.intermediateStarted)) return IntermediateStatus.inProgress;
  return IntermediateStatus.notStarted;
}

/// L'aromatica dell'Intermedio: la prima Incontrata che ha una Non comune, meglio se studiata già al Livello 2.
String? intermediateHerb(Catalog catalog, GameState state) {
  final book = recipeBookOf(catalog);
  final herbs = [
    for (final sci in encounteredTutorialSpecies(state))
      if (book.kitchenPages.any((p) => p.plant.sci == sci && p.recipes.length > 1)) sci,
  ];
  return herbs.where((sci) => state.levelOf(sci) >= kitchenUncommonLevel).firstOrNull ?? herbs.firstOrNull;
}

/// La Non comune dell'aromatica dell'Intermedio.
PlantRecipe? intermediateRecipe(Catalog catalog, GameState state) => switch (intermediateHerb(catalog, state)) {
  final sci? => recipeBookOf(catalog).pageOf(sci)?.recipes[1],
  null => null,
};

/// Il compagno della Non comune dell'Intermedio.
String? intermediateCompanion(Catalog catalog, GameState state) => switch (intermediateHerb(catalog, state)) {
  final sci? => catalog.speciesBySci(sci)?.companion,
  null => null,
};

bool isIntermediateStepDone(IntermediateStep step, Catalog catalog, GameState state) {
  final herb = intermediateHerb(catalog, state);
  final recipe = intermediateRecipe(catalog, state);
  final started = state.onboardingMarkedAt[OnboardingMark.intermediateStarted];
  return switch (step) {
    IntermediateStep.herb => herb != null,
    IntermediateStep.study => herb != null && state.levelOf(herb) >= kitchenUncommonLevel,
    IntermediateStep.drawSun =>
      herb != null &&
          state.essences.any(
            (e) =>
                e.speciesSci == herb &&
                e.vis > 0 &&
                e.traits.contains(Trait.sun.name) &&
                (started == null || !e.drawnAt.isBefore(started)),
          ),
    IntermediateStep.companion => switch ((recipe, intermediateCompanion(catalog, state))) {
      (final r?, final companion?) =>
        state.essences.where((e) => e.speciesSci == companion).fold(0, (sum, e) => sum + e.vis) >=
            r.ingredients[1].quantity * EconomyRules.visPerQuantity,
      _ => false,
    },
    IntermediateStep.brew => recipe != null && state.potions.any((p) => p.recipeId == recipe.id),
    IntermediateStep.finished => state.onboardingMarks.contains(OnboardingMark.intermediateFinished),
  };
}

/// Il passo del momento: il primo non ancora fatto. Null se l'Intermedio non è in corso.
IntermediateStep? currentIntermediateStep(Catalog catalog, GameState state) {
  if (intermediateStatus(state) != IntermediateStatus.inProgress) return null;
  return IntermediateStep.values.firstWhere((s) => !isIntermediateStepDone(s, catalog, state));
}
