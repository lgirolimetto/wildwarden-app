import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/rules/recipes/affixes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String name(RecipeBase base, String plant, List<Trait> traits, PotionEffect effect, {String lang = 'it'}) =>
      affixName(base: base, plantName: plant, traits: traits, effect: effect, languageCode: lang);

  test('in italiano: base, pianta, tratti accordati con la base, effetto', () {
    expect(
      name(RecipeBase.tincture, 'Piè di gallo', [Trait.frost], PotionEffect.clarity),
      'Tintura di Piè di gallo Brinata della Limpidezza',
    );
    expect(
      name(RecipeBase.infusion, 'Piè di gallo', [Trait.frost], PotionEffect.clarity),
      'Infuso di Piè di gallo Brinato della Limpidezza',
    );
    expect(
      name(RecipeBase.syrup, 'Bagolaro', const [], PotionEffect.regrowth),
      'Sciroppo di Bagolaro della Ricrescita',
    );
  });

  test('la pianta senza "comune" e "vera", con l\'elisione davanti a vocale', () {
    expect(
      name(RecipeBase.decoction, 'Acero oppio', const [], PotionEffect.regrowth),
      "Decotto d'Acero oppio della Ricrescita",
    );
    expect(
      name(RecipeBase.infusion, 'Melissa vera', const [], PotionEffect.clarity),
      'Infuso di Melissa della Limpidezza',
    );
    expect(
      name(RecipeBase.distillate, 'Faggio comune', [Trait.moon, Trait.newMoon], PotionEffect.abundance),
      "Distillato di Faggio Plenilunare Novilunare dell'Abbondanza",
    );
  });

  test('in inglese gli aggettivi vanno prima', () {
    expect(
      name(RecipeBase.tincture, 'Hackberry', [Trait.sun], PotionEffect.regrowth, lang: 'en'),
      'Sunlit Hackberry Tincture of Regrowth',
    );
  });

  test('i pezzi che mancano diventano "…"', () {
    expect(
      affixName(
        base: RecipeBase.elixir,
        plantName: 'Melissa vera',
        traits: [Trait.waxingMoon, Trait.rain],
        effect: PotionEffect.clarity,
        languageCode: 'it',
        hiddenTraits: {Trait.rain},
        effectHidden: true,
      ),
      'Elisir di Melissa Crescente … …',
    );
  });

  test('ogni tratto ed effetto ha le sue parole in italiano e in inglese', () {
    for (final t in Trait.values) {
      expect(traitAdjective(t, 'it', feminine: true), isNotEmpty);
      expect(traitAdjective(t, 'en', feminine: false), isNotEmpty);
    }
    for (final e in PotionEffect.values) {
      expect(effectSuffix(e, 'it'), isNotEmpty);
      expect(effectSuffix(e, 'en'), startsWith('of '));
    }
  });
}
