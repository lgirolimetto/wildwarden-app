import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/business_logic/rules/tutorial_intermediate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  final catalog = smallCatalog(kitchen: true);
  final day = DateTime(2026, 10, 29, 10);
  OnboardingMarked mark(OnboardingMark m, {int hours = 0}) => OnboardingMarked(
    mark: m,
    occurredAt: day.add(Duration(hours: hours)),
  );
  SpeciesEncountered met(String sci) =>
      SpeciesEncountered(speciesSci: sci, method: EncounterMethod.photo, occurredAt: day);
  LevelPassed passed(String sci, int level) => LevelPassed(speciesSci: sci, level: level, xp: 20, occurredAt: day);
  EssenceDrawn drawn(String sci, {List<String> traits = const ['waxingMoon'], int hours = 2, int vis = 10}) =>
      EssenceDrawn(
        speciesSci: sci,
        traits: traits,
        simulated: false,
        vis: vis,
        occurredAt: day.add(Duration(hours: hours)),
      );
  GameState play(List<GameEvent> events) => GameState.replay(events);
  final baseDone = [mark(OnboardingMark.tutorialStarted), mark(OnboardingMark.tutorialFinished)];

  test('stato: chiuso finché il Base non è finito o saltato, poi da cominciare, in corso, saltato, finito', () {
    expect(intermediateStatus(GameState.empty), IntermediateStatus.locked);
    expect(intermediateStatus(play([mark(OnboardingMark.tutorialStarted)])), IntermediateStatus.locked);
    expect(intermediateStatus(play(baseDone)), IntermediateStatus.notStarted);
    expect(intermediateStatus(play([mark(OnboardingMark.tutorialSkipped)])), IntermediateStatus.notStarted);
    expect(
      intermediateStatus(play([...baseDone, mark(OnboardingMark.intermediateStarted)])),
      IntermediateStatus.inProgress,
    );
    expect(
      intermediateStatus(play([...baseDone, mark(OnboardingMark.intermediateSkipped)])),
      IntermediateStatus.skipped,
    );
    expect(
      intermediateStatus(play([...baseDone, mark(OnboardingMark.intermediateFinished)])),
      IntermediateStatus.finished,
    );
    expect(
      currentIntermediateStep(catalog, play(baseDone)),
      isNull,
      reason: 'il passo c\'è solo a Intermedio in corso',
    );
  });

  test('i passi si completano da sé, in ordine; il Sole conta solo dopo l\'inizio; l\'ultimo con un tocco', () {
    final events = <GameEvent>[...baseDone, mark(OnboardingMark.intermediateStarted, hours: 1)];
    IntermediateStep? step() => currentIntermediateStep(catalog, play(events));

    expect(step(), IntermediateStep.herb, reason: 'chi ha saltato il Base può non avere aromatiche');
    events.add(met('Salvia rosmarinus'));
    expect(intermediateHerb(catalog, play(events)), 'Salvia rosmarinus');
    expect(intermediateCompanion(catalog, play(events)), 'Salvia officinalis');
    expect(step(), IntermediateStep.study);

    events.addAll([passed('Salvia rosmarinus', 1), passed('Salvia rosmarinus', 2)]);
    expect(step(), IntermediateStep.drawSun);
    events.add(drawn('Salvia rosmarinus', traits: ['sun'], hours: 0));
    expect(step(), IntermediateStep.drawSun, reason: 'il Sole di prima dell\'Intermedio non conta');
    events.add(drawn('Salvia rosmarinus', traits: ['waxingMoon', 'rain']));
    expect(step(), IntermediateStep.drawSun, reason: 'senza Sole il passo non si completa');
    events.add(drawn('Salvia rosmarinus', traits: ['waxingMoon', 'sun'], vis: 20));
    expect(step(), IntermediateStep.companion);

    events.add(drawn('Salvia officinalis', vis: 5));
    expect(step(), IntermediateStep.companion, reason: 'la Non comune delle aromatiche chiede 10 Vis del compagno');
    events.add(drawn('Salvia officinalis', vis: 5));
    expect(step(), IntermediateStep.brew);

    final recipe = recipeBookOf(catalog).pageOf('Salvia rosmarinus')!.recipes[1];
    events.add(PotionBrewed(recipeId: recipe.id, essences: const {}, potency: 4, xp: 30, occurredAt: day));
    expect(step(), IntermediateStep.finished);
    events.add(mark(OnboardingMark.intermediateFinished, hours: 3));
    expect(intermediateStatus(play(events)), IntermediateStatus.finished);
    expect(step(), isNull);
  });

  test('l\'aromatica dell\'Intermedio: meglio quella già studiata al Livello 2; l\'alloro no (è della Zona)', () {
    final state = play([
      met('Laurus nobilis'),
      met('Ocimum basilicum'),
      met('Salvia officinalis'),
      passed('Salvia officinalis', 1),
      passed('Salvia officinalis', 2),
    ]);
    expect(intermediateHerb(catalog, state), 'Salvia officinalis');
    expect(intermediateHerb(catalog, play([met('Laurus nobilis')])), isNull);
  });

  test('la Non comune delle aromatiche chiede 10 Vis per ingrediente: un Attingere a testa', () {
    final recipe = recipeBookOf(catalog).pageOf('Ocimum basilicum')!.recipes[1];
    expect(recipe.ingredients.map((i) => i.quantity), [1, 1, 1]);
    expect(
      recipeBookOf(catalog).pageOf('Malva sylvestris')!.recipes[1].ingredients.first.quantity,
      2,
      reason: 'le Non comuni della Zona restano a 20 Vis',
    );
  });

  group('le regole del tutorial intermedio sull\'Attingere', () {
    final atSun = [
      ...baseDone,
      mark(OnboardingMark.intermediateStarted),
      met('Salvia rosmarinus'),
      passed('Salvia rosmarinus', 1),
      passed('Salvia rosmarinus', 2),
    ];

    test('le regole della cucina valgono nel Base e nell\'Intermedio, solo per le aromatiche', () {
      expect(kitchenRuleApplies(play(atSun), 'Salvia rosmarinus'), isTrue);
      expect(kitchenRuleApplies(play(atSun), 'Malva sylvestris'), isFalse);
      expect(kitchenRuleApplies(play(baseDone), 'Salvia rosmarinus'), isFalse, reason: 'fuori dai tutorial no');
      expect(kitchenRuleApplies(play([mark(OnboardingMark.tutorialStarted)]), 'Ocimum basilicum'), isTrue);
    });

    test('la Stazione del passo si sblocca: l\'aromatica al Sole, il compagno al suo passo', () {
      expect(intermediateUnlocks(catalog, play(atSun), 'Salvia rosmarinus'), isTrue);
      expect(intermediateUnlocks(catalog, play(atSun), 'Salvia officinalis'), isFalse);
      final atCompanion = play([
        ...atSun,
        drawn('Salvia rosmarinus', traits: ['sun']),
      ]);
      expect(intermediateUnlocks(catalog, atCompanion, 'Salvia rosmarinus'), isFalse);
      expect(intermediateUnlocks(catalog, atCompanion, 'Salvia officinalis'), isTrue);
    });

    test('il Sole prestato: solo al suo passo, solo all\'aromatica, solo se il cielo non lo dà', () {
      final state = play(atSun);
      expect(withLentSun(catalog, state, 'Salvia rosmarinus', ['waningMoon', 'rain']), ['waningMoon', 'rain', 'sun']);
      expect(withLentSun(catalog, state, 'Salvia rosmarinus', ['waningMoon', 'sun']), isNull);
      expect(withLentSun(catalog, state, 'Salvia officinalis', ['waningMoon']), isNull);
      expect(withLentSun(catalog, play(baseDone), 'Salvia rosmarinus', ['waningMoon']), isNull);
    });
  });
}
