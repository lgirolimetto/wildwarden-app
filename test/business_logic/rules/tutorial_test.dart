import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/tutorial.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final day = DateTime(2026, 10, 29, 10);
  OnboardingMarked mark(OnboardingMark m) => OnboardingMarked(mark: m, occurredAt: day);
  SpeciesEncountered met(String sci, {int minutes = 0}) => SpeciesEncountered(
    speciesSci: sci,
    method: EncounterMethod.photo,
    occurredAt: day.add(Duration(minutes: minutes)),
  );
  LevelPassed passed(String sci) => LevelPassed(speciesSci: sci, level: 1, xp: 20, occurredAt: day);
  GameState play(List<GameEvent> events) => GameState.replay(events);

  test('stato: da cominciare, in corso, saltato, finito', () {
    expect(tutorialStatus(GameState.empty), TutorialStatus.notStarted);
    expect(tutorialStatus(play([mark(OnboardingMark.tutorialStarted)])), TutorialStatus.inProgress);
    expect(
      tutorialStatus(play([mark(OnboardingMark.tutorialStarted), mark(OnboardingMark.tutorialSkipped)])),
      TutorialStatus.skipped,
    );
    expect(tutorialStatus(play([mark(OnboardingMark.tutorialFinished)])), TutorialStatus.finished);
    expect(currentTutorialStep(GameState.empty), isNull, reason: 'il passo c\'è solo a tutorial in corso');
  });

  test('i passi si completano da sé, in ordine; l\'ultimo con un tocco', () {
    var state = play([mark(OnboardingMark.tutorialStarted)]);
    expect(currentTutorialStep(state), TutorialStep.photograph);

    // Una pianta della Zona che non è un'aromatica non conta.
    state = state.apply(met('Fagus sylvatica'));
    expect(currentTutorialStep(state), TutorialStep.photograph);

    state = state.apply(met('Salvia rosmarinus', minutes: 1));
    expect(currentTutorialStep(state), TutorialStep.study);
    expect(tutorialSpeciesToStudy(state), 'Salvia rosmarinus');

    state = state.apply(passed('Salvia rosmarinus'));
    expect(currentTutorialStep(state), TutorialStep.secondPhotograph);

    state = state.apply(met('Ocimum basilicum', minutes: 2));
    expect(currentTutorialStep(state), TutorialStep.brew);

    state = state.apply(PotionBrewed(recipeId: 'r', essences: const {}, potency: 3, xp: 30, occurredAt: day));
    expect(currentTutorialStep(state), TutorialStep.trove);

    state = state.apply(mark(OnboardingMark.troveVisited));
    expect(currentTutorialStep(state), TutorialStep.apprentice);

    state = state.apply(mark(OnboardingMark.tutorialFinished));
    expect(tutorialStatus(state), TutorialStatus.finished);
    expect(currentTutorialStep(state), isNull);
  });

  test('la barra si accende man mano durante il tutorial; fuori tutta', () {
    expect(visibleSections(GameState.empty), HomeSection.values.toSet());

    var state = play([mark(OnboardingMark.tutorialStarted)]);
    expect(visibleSections(state), {HomeSection.home});

    state = state.apply(met('Salvia officinalis'));
    expect(visibleSections(state), {HomeSection.home, HomeSection.erbario});

    state = state
        .apply(passed('Salvia officinalis'))
        .apply(met('Laurus nobilis', minutes: 1))
        .apply(PotionBrewed(recipeId: 'r', essences: const {}, potency: 3, xp: 30, occurredAt: day));
    expect(visibleSections(state), HomeSection.values.toSet());

    final skipped = play([mark(OnboardingMark.tutorialStarted), mark(OnboardingMark.tutorialSkipped)]);
    expect(visibleSections(skipped), HomeSection.values.toSet());
  });

  test('Curioso fino alla fine o allo skip del tutorial, solo sotto i 50 PE', () {
    expect(isCurious(GameState.empty), isTrue);
    expect(isCurious(play([mark(OnboardingMark.tutorialStarted)])), isTrue);
    expect(isCurious(play([mark(OnboardingMark.tutorialSkipped)])), isFalse);
    expect(isCurious(play([mark(OnboardingMark.tutorialFinished)])), isFalse);
    expect(isCurious(play([XpGranted(xp: 60, reason: 'test', occurredAt: day)])), isFalse);
  });
}
