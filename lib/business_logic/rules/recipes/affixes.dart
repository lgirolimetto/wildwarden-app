import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';

/// Le parole dei nomi ad affissi (capitolo 02, "Ricette ad affissi e pagine per pianta"; glossario, "Affissi"):
/// `[base] di [pianta] [tratti] [effetto]` in italiano, `[tratti] [pianta] [base] of [effetto]` in inglese.

/// Il tipo di preparato. Sale con il grado; le basi da uso esterno ([ointment], [balm]) sono per le ricette con una
/// pianta tossica.
enum RecipeBase {
  infusion('Infuso', 'Infusion'),
  decoction('Decotto', 'Decoction'),
  syrup('Sciroppo', 'Syrup'),
  ointment('Unguento', 'Ointment'),
  tincture('Tintura', 'Tincture', feminine: true),
  balm('Balsamo', 'Balm'),
  elixir('Elisir', 'Elixir'),
  distillate('Distillato', 'Distillate'),
  philtre('Filtro', 'Philtre');

  const RecipeBase(this.italian, this.english, {this.feminine = false});

  final String italian;
  final String english;

  /// In italiano gli aggettivi dei tratti si accordano con la base (Tintura Brinata, Infuso Brinato).
  final bool feminine;

  String word(String languageCode) => languageCode == 'en' ? english : italian;
}

/// L'aggettivo di un tratto nel nome: maschile e femminile in italiano, uno solo in inglese.
String traitAdjective(Trait trait, String languageCode, {required bool feminine}) {
  if (languageCode == 'en') return _englishAdjectives[trait]!;
  final (masculine, feminineForm) = _italianAdjectives[trait]!;
  return feminine ? feminineForm : masculine;
}

/// Il suffisso dell'effetto: "della Ricrescita", "of Regrowth".
String effectSuffix(PotionEffect effect, String languageCode) =>
    languageCode == 'en' ? _englishEffects[effect]! : _italianEffects[effect]!;

const _italianAdjectives = {
  Trait.dawn: ('Aurorale', 'Aurorale'),
  Trait.dusk: ('Crepuscolare', 'Crepuscolare'),
  Trait.waxingMoon: ('Crescente', 'Crescente'),
  Trait.moon: ('Plenilunare', 'Plenilunare'),
  Trait.waningMoon: ('Calante', 'Calante'),
  Trait.newMoon: ('Novilunare', 'Novilunare'),
  Trait.sun: ('Solare', 'Solare'),
  Trait.rain: ('Piovano', 'Piovana'),
  Trait.fog: ('Nebbioso', 'Nebbiosa'),
  Trait.dew: ('Rugiadoso', 'Rugiadosa'),
  Trait.frost: ('Brinato', 'Brinata'),
};

const _englishAdjectives = {
  Trait.dawn: 'Dawnlit',
  Trait.dusk: 'Dusky',
  Trait.waxingMoon: 'Waxing',
  Trait.moon: 'Full-moon',
  Trait.waningMoon: 'Waning',
  Trait.newMoon: 'New-moon',
  Trait.sun: 'Sunlit',
  Trait.rain: 'Rainy',
  Trait.fog: 'Misty',
  Trait.dew: 'Dewy',
  Trait.frost: 'Frosted',
};

const _italianEffects = {
  PotionEffect.regrowth: 'della Ricrescita',
  PotionEffect.clarity: 'della Limpidezza',
  PotionEffect.omen: 'del Presagio',
  PotionEffect.abundance: "dell'Abbondanza",
};

const _englishEffects = {
  PotionEffect.regrowth: 'of Regrowth',
  PotionEffect.clarity: 'of Clarity',
  PotionEffect.omen: 'of Omens',
  PotionEffect.abundance: 'of Abundance',
};

/// Il segno di un pezzo del nome che manca (componente non ancora trovato).
const missingPiece = '…';

/// Il nome della pianta dentro il nome della ricetta: senza "comune" e "vera" ("Bagolaro", "Melissa"), in italiano
/// con "di" o "d'" davanti.
String plantInRecipeName(String plantName, String languageCode) {
  var name = plantName;
  for (final tail in const [' comune', ' vera']) {
    if (name.endsWith(tail)) name = name.substring(0, name.length - tail.length);
  }
  if (languageCode == 'en') return name;
  return 'aeiou'.contains(name[0].toLowerCase()) ? "d'$name" : 'di $name';
}

/// Il nome ad affissi. [traits] in ordine fisso (quello di [Trait]); quelli in [hiddenTraits] e l'effetto se
/// [effectHidden] diventano [missingPiece].
String affixName({
  required RecipeBase base,
  required String plantName,
  required List<Trait> traits,
  required PotionEffect effect,
  required String languageCode,
  Set<Trait> hiddenTraits = const {},
  bool effectHidden = false,
}) {
  final adjectives = [
    for (final t in traits)
      hiddenTraits.contains(t) ? missingPiece : traitAdjective(t, languageCode, feminine: base.feminine),
  ];
  final suffix = effectHidden ? missingPiece : effectSuffix(effect, languageCode);
  final plant = plantInRecipeName(plantName, languageCode);
  return languageCode == 'en'
      ? [...adjectives, plant, base.english, suffix].join(' ')
      : [base.italian, plant, ...adjectives, suffix].join(' ');
}

/// L'aggettivo del Tocco, accordato con la base: Rigoglioso, Limpido, Presago, Copioso (Lush, Clear, Prescient,
/// Bountiful).
String touchAdjective(PotionEffect touch, String languageCode, {bool feminine = false}) {
  if (languageCode == 'en') {
    return switch (touch) {
      PotionEffect.regrowth => 'Lush',
      PotionEffect.clarity => 'Clear',
      PotionEffect.omen => 'Prescient',
      PotionEffect.abundance => 'Bountiful',
    };
  }
  final stem = switch (touch) {
    PotionEffect.regrowth => 'Rigoglios',
    PotionEffect.clarity => 'Limpid',
    PotionEffect.omen => 'Presag',
    PotionEffect.abundance => 'Copios',
  };
  return '$stem${feminine ? 'a' : 'o'}';
}
