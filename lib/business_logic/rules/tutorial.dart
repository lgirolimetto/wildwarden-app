import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/study/xp_rules.dart';

/// Tutorial da casa (blocco 2b, capitolo 03): un giro del gioco con le aromatiche di cucina, prima di uscire. Prende il
/// posto dell'Apprendistato. Lo stato si ricava dagli eventi: i segni dell'onboarding e quello che hai fatto davvero.

/// Le piante del tutorial: le aromatiche del supermercato (🟢 capitolo 03, 2026-10-28). L'alloro è anche della Zona.
const tutorialSpecies = {'Salvia officinalis', 'Salvia rosmarinus', 'Ocimum basilicum', 'Laurus nobilis'};

/// I passi, in ordine. Ognuno si completa da sé quando succede la cosa, tranne l'ultimo ("Sei Apprendista").
enum TutorialStep {
  /// Fotografa un'aromatica: Incontro, Stazione ed Essenza.
  photograph,

  /// Supera il Livello 1 di un'aromatica Incontrata: impari la sua Comune.
  study,

  /// Fotografa un'altra aromatica: la Comune vuole la pianta e un'altra specie.
  secondPhotograph,

  /// Prepara la prima pozione nel Laboratorio.
  brew,

  /// Apri il Bottino dell'Esperienza.
  trove,

  /// "Sei Apprendista": si chiude con un tocco.
  apprentice,
}

enum TutorialStatus { notStarted, inProgress, skipped, finished }

/// Le sezioni della barra in basso, nell'ordine della barra.
enum HomeSection { home, erbario, laboratory, trove }

TutorialStatus tutorialStatus(GameState state) {
  final marks = state.onboardingMarks;
  if (marks.contains(OnboardingMark.tutorialFinished)) return TutorialStatus.finished;
  if (marks.contains(OnboardingMark.tutorialSkipped)) return TutorialStatus.skipped;
  if (marks.contains(OnboardingMark.tutorialStarted)) return TutorialStatus.inProgress;
  return TutorialStatus.notStarted;
}

/// Le aromatiche del tutorial che hai Incontrato, nell'ordine dell'Incontro.
List<String> encounteredTutorialSpecies(GameState state) =>
    (state.firstEncounters.entries.where((e) => tutorialSpecies.contains(e.key)).toList()
          ..sort((a, b) => a.value.compareTo(b.value)))
        .map((e) => e.key)
        .toList();

bool isStepDone(TutorialStep step, GameState state) {
  final herbs = encounteredTutorialSpecies(state);
  return switch (step) {
    TutorialStep.photograph => herbs.isNotEmpty,
    TutorialStep.study => herbs.any((sci) => state.levelOf(sci) >= 1),
    TutorialStep.secondPhotograph => herbs.length >= 2,
    TutorialStep.brew => state.potions.isNotEmpty,
    TutorialStep.trove => state.onboardingMarks.contains(OnboardingMark.troveVisited),
    TutorialStep.apprentice => state.onboardingMarks.contains(OnboardingMark.tutorialFinished),
  };
}

/// Il passo del momento: il primo non ancora fatto. Null se il tutorial non è in corso.
TutorialStep? currentTutorialStep(GameState state) {
  if (tutorialStatus(state) != TutorialStatus.inProgress) return null;
  return TutorialStep.values.firstWhere((s) => !isStepDone(s, state));
}

/// L'aromatica da studiare al passo [TutorialStep.study]: la prima Incontrata.
String? tutorialSpeciesToStudy(GameState state) => encounteredTutorialSpecies(state).firstOrNull;

/// Le sezioni della barra accese: durante il tutorial si accendono quando il passo ci arriva (Erbario allo studio,
/// Laboratorio alla pozione, Bottino al suo passo); fuori dal tutorial tutte.
Set<HomeSection> visibleSections(GameState state) {
  final step = currentTutorialStep(state);
  if (step == null) return HomeSection.values.toSet();
  return {
    HomeSection.home,
    if (step.index >= TutorialStep.study.index) HomeSection.erbario,
    if (step.index >= TutorialStep.brew.index) HomeSection.laboratory,
    if (step.index >= TutorialStep.trove.index) HomeSection.trove,
  };
}

/// Curioso: il rango sotto Apprendista, finché il tutorial non è finito o saltato. Dai 50 PE in su contano i Ranghi
/// dei PE (🟡 proposta del piano del blocco 2b).
bool isCurious(GameState state) {
  final status = tutorialStatus(state);
  final done = status == TutorialStatus.finished || status == TutorialStatus.skipped;
  return !done && Rank.of(state.xp) == Rank.apprentice;
}
