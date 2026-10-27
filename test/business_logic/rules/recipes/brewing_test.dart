import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/affixes.dart';
import 'package:druid_app/business_logic/rules/recipes/brewing.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  final catalog = smallCatalog();
  final book = recipeBookOf(catalog);
  final feb = DateTime(2027, 2, 1, 10);
  const malva = 'Malva sylvestris', fagus = 'Fagus sylvatica', elleboro = 'Helleborus viridis';
  final malvaCommon = book.pageOf(malva)!.recipes.first;
  EssenceDrawn drawn(String sci, {List<String> traits = const [], double purity = 0.4, int vis = 10}) =>
      EssenceDrawn(speciesSci: sci, traits: traits, simulated: true, vis: vis, purity: purity, occurredAt: feb);

  test('la Comune della Malva: la Malva e una pianta a scelta nello slot libero', () {
    final brewable = brewableOf(catalog, malvaCommon.id)!;
    expect(brewable.ingredients.map((i) => i.speciesSci), [malva, null]);
    expect(brewable.ingredients.map((i) => i.vis), [10, 10]);
    expect(brewable.drinkable, malvaCommon.base != RecipeBase.ointment);
  });

  test('senza le Vis giuste manca qualcosa; lo slot libero accetta le piante con abbastanza Vis', () {
    final brewable = brewableOf(catalog, malvaCommon.id)!;
    final empty = planBrew(brewable, GameState.empty.essences);
    expect(empty.missing, hasLength(2));
    final state = GameState.replay([drawn(malva), drawn(fagus), drawn(malva)]);
    expect(freeSlotCandidates(brewable, state.essences), [fagus, malva], reason: 'a pari Vis in ordine di nome');
    final plan = planBrew(brewable, state.essences, freeSpecies: fagus);
    expect(plan.ready, isTrue);
    expect(plan.taken, {0: 10, 1: 10});
  });

  test('un ingrediente con un tratto vuole un\'Essenza con quel tratto', () {
    final rare = book.pageOf(malva)!.recipes.last;
    final brewable = brewableOf(catalog, rare.id)!;
    final traited = brewable.ingredients.firstWhere((i) => i.traits.isNotEmpty);
    final plain = GameState.replay([for (var i = 0; i < 5; i++) drawn(traited.speciesSci!)]);
    expect(planBrew(brewable, plain.essences).missing.map((m) => m.ingredient), contains(traited));
  });

  test('la potenza viene soprattutto dalla purezza: al 40 % al massimo 5, con la maestria 6 senza tratti rari', () {
    final brewable = brewableOf(catalog, malvaCommon.id)!;
    int potency(double purity) {
      final state = GameState.replay([drawn(malva, purity: purity), drawn(malva, purity: purity)]);
      return potencyOf(planBrew(brewable, state.essences, freeSpecies: malva), state.essences, catalog);
    }

    expect(potency(0.4), 1);
    expect(potency(1.0), 6);
    expect(potency(0.75), lessThan(potency(1.0)));
    final rare = GameState.replay([
      drawn(malva, purity: 0.4, traits: ['moon']),
      drawn(malva, purity: 0.4),
    ]);
    expect(potencyOf(planBrew(brewable, rare.essences, freeSpecies: malva), rare.essences, catalog), 2);
  });

  test('PE in proporzione alla potenza; Tocco dalla vocazione della pianta dello slot libero', () {
    expect(potionXpOf(Grade.common, 5), 15);
    expect(potionXpOf(Grade.rare, 10), 200);
    expect(touchOf(catalog, fagus), book.pageOf(fagus)!.vocation.first);
    expect(touchAdjective(PotionEffect.clarity, 'it', feminine: true), 'Limpida');
    expect(touchAdjective(PotionEffect.regrowth, 'it'), 'Rigoglioso');
  });

  test('una tossica nello slot libero di una ricetta da bere guasta la pozione', () {
    final brewable = brewableOf(catalog, malvaCommon.id)!;
    expect(spoils(brewable, catalog, elleboro), brewable.drinkable);
    expect(spoils(brewable, catalog, fagus), isFalse);
  });

  test('preparare: spende le Vis, mette la pozione sullo Scaffale e tiene la potenza migliore', () {
    final state = GameState.replay([
      drawn(malva),
      drawn(fagus),
      PotionBrewed(recipeId: malvaCommon.id, essences: const {0: 10, 1: 10}, potency: 4, xp: 42, occurredAt: feb),
      PotionBrewed(recipeId: malvaCommon.id, essences: const {}, potency: 2, xp: 6, occurredAt: feb),
    ]);
    expect(state.vis, {malva: 0, fagus: 0});
    expect(state.potions.map((p) => p.potency), [4, 2]);
    expect(state.bestPotency, {malvaCommon.id: 4});
    expect(state.xp, 48);
    expect(brewsToday(state, feb), 2);
    expect(brewBlock(state, brewableOf(catalog, malvaCommon.id)!, feb), BrewBlock.dailyLimit);
  });

  test('la pozione guastata: Vis perse, niente pozione, la pianta è nota come tossica', () {
    final state = GameState.replay([
      drawn(malva),
      drawn(elleboro),
      PotionBrewed(
        recipeId: malvaCommon.id,
        essences: const {0: 10, 1: 10},
        potency: 1,
        freeSpecies: elleboro,
        spoiled: true,
        xp: 30,
        occurredAt: feb,
      ),
    ]);
    expect(state.potions, isEmpty);
    expect(state.knownToxic, {elleboro});
    expect(state.vis, {malva: 0, elleboro: 0});
  });

  test('l\'evento si rilegge uguale dal database', () {
    final event = PotionBrewed(
      recipeId: malvaCommon.id,
      essences: const {3: 10},
      potency: 6,
      touch: PotionEffect.omen,
      freeSpecies: fagus,
      xp: 48,
      occurredAt: feb,
    );
    final back = GameEvent.decode(type: event.type, payload: event.encodePayload(), occurredAt: feb);
    expect(back.payload(), event.payload());
  });
}
