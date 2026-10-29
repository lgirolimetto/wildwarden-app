import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/harvest.dart';
import 'package:druid_app/business_logic/rules/recipes/potion_effects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final feb = DateTime(2027, 2, 1, 8);
  const malva = 'Malva sylvestris';
  PotionBrewed brewed(int potency, {PotionEffect? touch}) =>
      PotionBrewed(recipeId: 'r', essences: const {}, potency: potency, touch: touch, xp: 0, occurredAt: feb);
  PotionUsed used(PotionEffect effect, int strength, {PotionEffect? touch, int potion = 0, DateTime? at}) =>
      PotionUsed(potionIndex: potion, effect: effect, strength: strength, touch: touch, occurredAt: at ?? feb);

  test('usata, la pozione lascia lo Scaffale; l\'effetto vale 7 giorni', () {
    final state = GameState.replay([brewed(6), used(PotionEffect.abundance, 6)]);
    expect(state.potions.single.onShelf, isFalse);
    expect(activeEffects(state, feb.add(const Duration(days: 6))), {PotionEffect.abundance: 6});
    expect(activeEffects(state, feb.add(const Duration(days: 7))), isEmpty);
  });

  test('il Tocco aggiunge un piccolo effetto; se è lo stesso rinforza, fino a 10', () {
    final other = GameState.replay([brewed(6), used(PotionEffect.abundance, 6, touch: PotionEffect.clarity)]);
    expect(activeEffects(other, feb), {PotionEffect.abundance: 6, PotionEffect.clarity: touchStrength});
    final same = GameState.replay([brewed(9), used(PotionEffect.abundance, 9, touch: PotionEffect.abundance)]);
    expect(activeEffects(same, feb), {PotionEffect.abundance: 10});
  });

  test('la forza decide quanto: Abbondanza, Limpidezza, Ricrescita, Presagio', () {
    expect(visWithAbundance(10, 10), 15);
    expect(visWithAbundance(10, 2), 11);
    expect(purityWithClarity(0.4, 5), closeTo(0.5, 1e-9));
    expect(purityWithClarity(0.95, 10), 1.0);
    expect(regrowthWait(10), const Duration(hours: 12));
    expect(omenChance(3), 0.3);
  });

  test('con la Ricrescita una specie si attinge di nuovo lo stesso giorno, passate le ore', () {
    final events = [
      SpeciesEncountered(speciesSci: malva, method: EncounterMethod.simulated, occurredAt: feb),
      EssenceDrawn(speciesSci: malva, simulated: true, vis: 10, occurredAt: feb),
    ];
    final plain = GameState.replay(events);
    expect(canDraw(plain, malva, feb.add(const Duration(hours: 13))), isFalse);
    final regrowth = GameState.replay([...events, brewed(10), used(PotionEffect.regrowth, 10)]);
    expect(canDraw(regrowth, malva, feb.add(const Duration(hours: 11))), isFalse);
    expect(canDraw(regrowth, malva, feb.add(const Duration(hours: 13))), isTrue);
  });

  test('l\'evento si rilegge uguale dal database', () {
    final event = used(PotionEffect.omen, 7, touch: PotionEffect.clarity, potion: 3);
    final back = GameEvent.decode(type: event.type, payload: event.encodePayload(), occurredAt: feb);
    expect(back.payload(), event.payload());
  });

  group('Presagio su un\'Essenza', () {
    const affinities = [Trait.sun, Trait.dawn, Trait.fog];
    ({List<String> traits, double purity}) omen(List<String> traits, {double roll = 0}) =>
        withOmen(traits: traits, affinities: affinities, purity: 0.5, strength: 5, roll: roll);

    test('prende la prima Affinità che manca, in più alle sue Qualia (la luna c\'è sempre)', () {
      expect(omen(['waningMoon', 'rain']).traits, ['waningMoon', 'rain', 'sun']);
      expect(omen(['waxingMoon', 'sun']).traits, ['waxingMoon', 'sun', 'dawn'], reason: 'il Sole c\'è già: l\'Alba');
    });

    test('con tutte le Affinità, purezza in più come con la Limpidezza', () {
      final all = omen(['dawn', 'moon', 'sun', 'fog']);
      expect(all.traits, ['dawn', 'moon', 'sun', 'fog']);
      expect(all.purity, purityWithClarity(0.5, 5));
    });

    test('se non scatta non cambia niente', () {
      final none = omen(['waningMoon'], roll: 0.9);
      expect(none.traits, ['waningMoon']);
      expect(none.purity, 0.5);
    });
  });
}
