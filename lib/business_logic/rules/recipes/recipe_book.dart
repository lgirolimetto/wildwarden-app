import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/models/species_traits.dart';
import 'package:druid_app/business_logic/rules/recipes/affixes.dart';

/// Le ricette ad affissi della Zona, una pagina per pianta (capitolo 02, "Ricette ad affissi e pagine per pianta").
///
/// Tutto è deterministico: dagli stessi dati del catalogo escono le stesse pagine per tutti, e l'id di una ricetta è
/// la combinazione stessa. Le regole sono la copia di `tools/recipe-preview/preview.py` nel core, che le prova sulle
/// specie vere; il test d'oro controlla che diano le stesse pagine. I conti si fanno nello stesso ordine di Python e i
/// pareggi si rompono allo stesso modo (l'ordine del catalogo), altrimenti i numeri a virgola mobile divergono.

/// Una specie c'è nel mese se le sue osservazioni arrivano almeno al 30 % del mese migliore (come nel simulatore).
const presenceRatio = 0.3;

/// Tavole per pagina secondo la rarità della pianta: (non comuni, rare), più la Comune. Da 3 a 5.
const _pageShape = {Grade.common: (1, 1), Grade.uncommon: (2, 1), Grade.rare: (2, 2), Grade.mythic: (2, 2)};

/// Unità di Vis per ingrediente, secondo il grado della ricetta (1 unità = 10 Vis).
const recipeQuantity = {Grade.common: 1, Grade.uncommon: 2, Grade.rare: 3};

/// Piante ammesse come compagni, in linea con il grado della ricetta.
const _companionGrades = {
  Grade.uncommon: {Grade.common, Grade.uncommon},
  Grade.rare: {Grade.common, Grade.uncommon, Grade.rare},
};

/// Quanti compagni vicini si guardano per variare da una ricetta all'altra della pagina.
const _nearestCompanions = 8;

const _aromaticFamilies = {'Lamiaceae', 'Lauraceae', 'Apiaceae', 'Rutaceae'};
const _soothingFamilies = {'Malvaceae', 'Boraginaceae'};

/// Un ingrediente di una ricetta generata: una pianta (`null` = qualsiasi specie) attinta con quei tratti.
class RecipeIngredient {
  final String? speciesSci;
  final int quantity;

  /// Di solito uno o nessuno; due quando la Rara non trova un compagno per il secondo tratto.
  final List<Trait> traits;

  const RecipeIngredient({required this.speciesSci, required this.quantity, this.traits = const []});
}

/// Una ricetta ad affissi della pagina di una pianta.
class PlantRecipe {
  /// `paese/pianta·tratti·effetto` (es. `it/celtis-australis·dawn+sun·abundance`): lo salvano gli eventi.
  final String id;
  final Species plant;
  final Grade grade;

  /// In ordine fisso (quello di [Trait]): è l'ordine dei prefissi nel nome.
  final List<Trait> traits;
  final PotionEffect effect;
  final RecipeBase base;
  final List<RecipeIngredient> ingredients;

  /// Mesi (1-12) in cui tutti gli ingredienti si possono attingere con il loro tratto.
  final List<int> months;

  const PlantRecipe({
    required this.id,
    required this.plant,
    required this.grade,
    required this.traits,
    required this.effect,
    required this.base,
    required this.ingredients,
    required this.months,
  });

  /// I pezzi del nome che una ricetta trovata incompleta non ha ancora, nell'ordine in cui si scoprono: la Non
  /// comune non sa l'effetto; la Rara non sa il secondo tratto (quello del compagno: sai che pianta serve, non in
  /// che condizioni) e poi l'effetto.
  List<NamePiece> get missingPieces => switch (grade) {
    Grade.common || Grade.mythic => const [],
    Grade.uncommon => const [NamePiece.effect],
    Grade.rare => const [NamePiece.secondTrait, NamePiece.effect],
  };

  /// Gli ultimi [missing] pezzi di [missingPieces]: quelli ancora da trovare.
  List<NamePiece> hiddenPieces(int missing) =>
      missingPieces.sublist(missingPieces.length - missing.clamp(0, missingPieces.length));

  /// Il nome, intero o con gli ultimi [missing] pezzi di [missingPieces] ancora da trovare.
  String name(String languageCode, {int missing = 0}) {
    final hidden = hiddenPieces(missing);
    return affixName(
      base: base,
      plantName: plant.name.resolve(languageCode),
      traits: traits,
      effect: effect,
      languageCode: languageCode,
      hiddenTraits: hidden.contains(NamePiece.secondTrait) ? {traits[1]} : const {},
      effectHidden: hidden.contains(NamePiece.effect),
    );
  }
}

/// Un pezzo del nome che può mancare.
enum NamePiece { secondTrait, effect }

/// La pagina di una pianta nel Ricettario.
class PlantPage {
  final Species plant;

  /// I 3 tratti d'elezione, dal preferito.
  final List<Trait> favouredTraits;

  /// Gli effetti della pianta (1 o 2), dal principale.
  final List<PotionEffect> vocation;
  final List<PlantRecipe> recipes;

  const PlantPage({required this.plant, required this.favouredTraits, required this.vocation, required this.recipes});
}

/// Tutte le pagine della Zona, nell'ordine del catalogo.
class RecipeBook {
  final List<PlantPage> pages;
  final Map<String, PlantPage> _bySci;
  final Map<String, PlantRecipe> _byId;

  RecipeBook._(this.pages)
    : _bySci = {for (final p in pages) p.plant.sci: p},
      _byId = {
        for (final p in pages)
          for (final r in p.recipes) r.id: r,
      };

  factory RecipeBook.of(Catalog catalog) => _Builder(catalog).build();

  PlantPage? pageOf(String speciesSci) => _bySci[speciesSci];

  PlantRecipe? recipeById(String id) => _byId[id];
}

class _Builder {
  final Catalog catalog;
  final Map<Trait, List<double>> climate;
  final Set<String> toxic;
  final Map<String, Map<Trait, double>> ranks;

  _Builder(this.catalog) : climate = catalog.climate, toxic = catalog.safety.keys.toSet(), ranks = _traitRanks(catalog);

  RecipeBook build() => RecipeBook._([for (final s in catalog.species) _page(s)]);

  PlantPage _page(Species plant) {
    final favoured = plant.favouredTraits ?? _favouredTraits(plant);
    final vocation = plant.vocation ?? _vocation(plant, toxic.contains(plant.sci));
    final (uncommon, rare) = _pageShape[plant.grade]!;
    final cards = <(Grade, List<Trait>, PotionEffect)>[
      (Grade.common, const [], vocation[0]),
      for (var i = 0; i < min(uncommon, favoured.length); i++)
        (Grade.uncommon, [favoured[i]], vocation[i % vocation.length]),
    ];
    // Le Rare prendono le coppie con il terzo tratto, così la pagina li mostra tutti.
    final pairs = [
      for (final (i, j) in const [(1, 2), (0, 2), (0, 1)])
        if (j < favoured.length) [favoured[i], favoured[j]],
    ];
    for (var j = 0; j < min(rare, pairs.length); j++) {
      cards.add((Grade.rare, pairs[j], vocation[(j + 1) % vocation.length]));
    }
    final used = <String>{};
    return PlantPage(
      plant: plant,
      favouredTraits: favoured,
      vocation: vocation,
      recipes: [for (final (grade, traits, effect) in cards) _recipe(plant, grade, traits, effect, used)],
    );
  }

  PlantRecipe _recipe(Species plant, Grade grade, List<Trait> traits, PotionEffect effect, Set<String> used) {
    final sorted = [...traits]..sort((a, b) => a.index.compareTo(b.index));
    final rows = _ingredients(plant, grade, sorted, used);
    final withToxic = rows.any((r) => r.plant != null && toxic.contains(r.plant!.sci));
    return PlantRecipe(
      id: recipeId(catalog.countryId, plant.sci, sorted, effect),
      plant: plant,
      grade: grade,
      traits: sorted,
      effect: effect,
      base: _base(plant, grade, effect, withToxic),
      ingredients: [
        for (final r in rows)
          RecipeIngredient(speciesSci: r.plant?.sci, quantity: recipeQuantity[grade]!, traits: r.traits),
      ],
      months: [for (final m in _window(rows)) m + 1],
    );
  }

  /// Comune: la pianta + 1 qualsiasi specie. Non comune: la pianta con il tratto + 1 compagno + 1 qualsiasi specie.
  /// Rara: la pianta con il primo tratto + 1 compagno con il secondo (se nessuno può averlo, il tratto torna alla
  /// pianta quando è di un altro gruppo, altrimenti a una qualsiasi specie) + 1 compagno senza tratto. I compagni
  /// variano nella pagina ([used]); senza compagni possibili resta una qualsiasi specie.
  List<_Row> _ingredients(Species plant, Grade grade, List<Trait> traits, Set<String> used) {
    final mainTrait = traits.isEmpty ? null : traits.first;
    final rows = [
      _Row(plant, [?mainTrait]),
    ];
    if (grade == Grade.common) return [...rows, const _Row(null, [])];
    final mainMonths = _plausibleMonths(plant, mainTrait).toSet();
    final friends = _companions(plant, grade, mainMonths);

    Species? pick(Set<int> months, [Trait? trait]) {
      final inRecipe = {for (final r in rows) ?r.plant?.sci};
      final fits = [
        for (final f in friends)
          if (!inRecipe.contains(f.sci) && months.intersection(_plausibleMonths(f, trait).toSet()).isNotEmpty) f,
      ];
      final chosen = fits.where((f) => !used.contains(f.sci)).firstOrNull ?? fits.firstOrNull;
      if (chosen != null) used.add(chosen.sci);
      return chosen;
    }

    if (grade == Grade.uncommon) return [...rows, _Row(pick(mainMonths), const []), const _Row(null, [])];
    final second = traits[1];
    final holder = pick(mainMonths, second);
    if (holder == null && second.group != mainTrait!.group) {
      return [
        _Row(plant, [mainTrait, second]),
        _Row(pick(mainMonths), const []),
        _Row(pick(mainMonths), const []),
      ];
    }
    // Nessun compagno può avere il secondo tratto: lo porta una qualsiasi specie.
    if (holder == null) {
      return [
        ...rows,
        _Row(null, [second]),
        _Row(pick(mainMonths), const []),
      ];
    }
    final both = mainMonths.intersection(_plausibleMonths(holder, second).toSet());
    return [
      ...rows,
      _Row(holder, [second]),
      _Row(pick(both), const []),
    ];
  }

  /// Compagni dallo stesso habitat (luce, umidità, fascia di quota, stagione), presenti in almeno uno dei [months],
  /// di una rarità in linea con il grado; le tossiche fanno da compagne solo alle tossiche.
  List<Species> _companions(Species plant, Grade grade, Set<int> months) {
    final allowed = _companionGrades[grade]!;
    final plantToxic = toxic.contains(plant.sci);
    double distance(Species o) {
      var bands = 0.0;
      for (final band in AltitudeBand.values) {
        bands += ((plant.bandShare[band] ?? 0) - (o.bandShare[band] ?? 0)).abs();
      }
      var season = 0.0;
      for (final s in plant.seasonShare.keys) {
        season += (plant.seasonShare[s]! - o.seasonShare[s]!).abs();
      }
      return (_light(plant) - _light(o)).abs() / 2 + (_moisture(plant) - _moisture(o)).abs() + 2 * bands + 2 * season;
    }

    final candidates = [
      for (final (index, o) in catalog.species.indexed)
        if (o.sci != plant.sci &&
            allowed.contains(o.grade) &&
            (plantToxic || !toxic.contains(o.sci)) &&
            months.intersection(_plausibleMonths(o, null).toSet()).isNotEmpty)
          (index, o, distance(o)),
    ]..sort((a, b) => a.$3 != b.$3 ? a.$3.compareTo(b.$3) : a.$1.compareTo(b.$1));
    return [for (final c in candidates.take(_nearestCompanions)) c.$2];
  }

  List<int> _plausibleMonths(Species s, Trait? trait) => plausibleMonths(s, trait, climate);

  List<int> _window(List<_Row> rows) {
    var months = {for (var m = 0; m < 12; m++) m};
    for (final r in rows) {
      if (r.plant == null) continue;
      for (final t in r.traits.isEmpty ? const <Trait?>[null] : r.traits) {
        months = months.intersection(_plausibleMonths(r.plant!, t).toSet());
      }
    }
    return months.toList()..sort();
  }

  /// I 3 tratti d'elezione, dal preferito: i percentili più alti della pianta, al massimo 2 dello stesso gruppo.
  List<Trait> _favouredTraits(Species plant) {
    final ranked = ranks[plant.sci]!.entries.toList()
      ..sort((a, b) => a.value != b.value ? b.value.compareTo(a.value) : a.key.index.compareTo(b.key.index));
    final chosen = <Trait>[];
    for (final MapEntry(key: t) in ranked) {
      if (chosen.where((c) => c.group == t.group).length < 2) chosen.add(t);
      if (chosen.length == 3) break;
    }
    return chosen;
  }

  /// Base secondo il grado: Comune Sciroppo (frutti), Decotto (legnose), Infuso (erbe); Non comune Tintura; Rara
  /// Filtro (Presagio), Distillato (legnose), Elisir. Con una tossica tra gli ingredienti solo da uso esterno.
  static RecipeBase _base(Species plant, Grade grade, PotionEffect effect, bool withToxic) {
    final woody = _isWoody(plant.traits);
    final fruits = plant.traits.dispersal.contains(SeedDispersal.eatenByAnimals);
    if (withToxic) return grade == Grade.common ? RecipeBase.ointment : RecipeBase.balm;
    return switch (grade) {
      Grade.common => fruits ? RecipeBase.syrup : (woody ? RecipeBase.decoction : RecipeBase.infusion),
      Grade.uncommon => RecipeBase.tincture,
      _ => effect == PotionEffect.omen ? RecipeBase.philtre : (woody ? RecipeBase.distillate : RecipeBase.elixir),
    };
  }
}

class _Row {
  final Species? plant;
  final List<Trait> traits;

  const _Row(this.plant, this.traits);
}

/// Id deterministico di una ricetta ad affissi: il paese del Ricettario (nazionale) e la combinazione
/// (`it/celtis-australis·dawn+sun·abundance`).
String recipeId(String countryId, String speciesSci, List<Trait> traits, PotionEffect effect) => [
  '$countryId/${speciesSci.toLowerCase().replaceAll(' ', '-')}',
  if (traits.isNotEmpty) traits.map((t) => t.name).join('+'),
  effect.name,
].join('·');

/// La stagionalità della specie in tutto il paese (il Ricettario è nazionale); quella della Zona se manca.
List<double> _monthsOf(Species s) => s.national?.monthsRelative ?? s.monthsRelative;

/// Il clima dei posti dove la specie è osservata; quello della Zona ([zone]) se manca.
Map<Trait, List<double>> _climateOf(Species s, Map<Trait, List<double>> zone) => s.national?.climate ?? zone;

/// Peso di presenza della specie per mese: 0 sotto la soglia [presenceRatio].
List<double> presence(Species s) {
  final months = _monthsOf(s);
  final top = months.reduce(max);
  final divisor = top == 0 ? 1 : top;
  return [
    for (final m in months)
      if (m / divisor >= presenceRatio) m / divisor else 0.0,
  ];
}

/// Mesi (0-11) in cui la specie c'è e il tratto può capitare nella Zona. Luce del giorno e luna capitano ogni mese.
List<int> plausibleMonths(Species s, Trait? trait, Map<Trait, List<double>> climate) {
  final weights = presence(s);
  final days = trait == null ? null : _climateOf(s, climate)[trait];
  return [
    for (var i = 0; i < 12; i++)
      if (weights[i] != 0 && (days == null || days[i] > 0)) i,
  ];
}

double _light(Species s) => s.traits.light ?? 5.5;

double _moisture(Species s) => s.traits.moisture ?? 4.0;

bool _isWoody(SpeciesTraits t) =>
    t.growthForm == GrowthForm.tree || t.growthForm == GrowthForm.shrub || t.growthForm == GrowthForm.climber;

/// Punteggio di ogni tratto plausibile per la pianta: quanto è facile attingerla con quel tratto e quanto le somiglia.
Map<Trait, double> _affinityScores(Species s, Map<Trait, List<double>> zoneClimate, bool toxic) {
  final weights = presence(s);
  final climate = _climateOf(s, zoneClimate);
  final total = weights.fold(0.0, (a, b) => a + b);
  final divisor = total == 0 ? 1 : total;
  final lt = _light(s), mo = _moisture(s);
  final plain = s.bandShare[AltitudeBand.plain] ?? 0;

  double overlap(Trait t) {
    var sum = 0.0;
    for (var i = 0; i < 12; i++) {
      sum += weights[i] * climate[t]![i] / 30;
    }
    return sum / divisor;
  }

  final scores = {
    Trait.sun: overlap(Trait.sun) * lt / 7,
    Trait.rain: overlap(Trait.rain) * mo / 4,
    Trait.fog: overlap(Trait.fog) * (plain + 0.5) * mo / 4,
    Trait.dew: overlap(Trait.dew) * mo / 4,
    Trait.frost: overlap(Trait.frost) * (s.peakSeason == Season.winter ? 1.3 : 1),
    Trait.dawn: 0.22 * lt / 7,
    Trait.dusk: 0.22 * (10 - lt) / 5,
    Trait.moon: 0.18 * (10 - lt) / 5,
    Trait.newMoon: 0.12 * (10 - lt) / 5 + (toxic ? 0.15 : 0),
    Trait.waxingMoon: s.peakSeason == Season.spring ? 0.25 : 0.08,
    Trait.waningMoon: s.peakSeason == Season.autumn || s.peakSeason == Season.winter ? 0.25 : 0.08,
  };
  return {
    for (final MapEntry(:key, :value) in scores.entries)
      if (plausibleMonths(s, key, zoneClimate).isNotEmpty) key: value,
  };
}

/// Percentile di ogni pianta per ogni tratto nella Zona (1 = la pianta che gli somiglia di più, pari merito alla
/// media): così ogni tratto ha le sue piante, anche i rari come Nebbia e Gelo.
Map<String, Map<Trait, double>> _traitRanks(Catalog catalog) {
  final toxic = catalog.safety.keys.toSet();
  final scores = {for (final s in catalog.species) s.sci: _affinityScores(s, catalog.climate, toxic.contains(s.sci))};
  final ranks = {for (final sci in scores.keys) sci: <Trait, double>{}};
  for (final t in Trait.values) {
    final values = [
      for (final v in scores.values)
        if (v.containsKey(t)) v[t]!,
    ];
    for (final MapEntry(key: sci, value: v) in scores.entries) {
      final score = v[t];
      if (score == null) continue;
      final below = values.where((x) => x < score).length;
      final equal = values.where((x) => x == score).length;
      ranks[sci]![t] = (below + (equal - 1) / 2) / max(values.length - 1, 1);
    }
  }
  return ranks;
}

/// Gli effetti della pianta (1 o 2) dal suo carattere: Ricrescita alle legnose e perenni, Abbondanza a chi fa frutti
/// o è annuale, Limpidezza alle aromatiche e alle emollienti, Presagio alle tossiche, alle orchidee e alle piante
/// d'ombra. A pari punteggio vale l'ordine di [PotionEffect].
List<PotionEffect> _vocation(Species s, bool toxic) {
  final t = s.traits;
  final regrowth = switch (t.growthForm) {
    GrowthForm.tree => 1.0,
    GrowthForm.shrub => 0.7,
    GrowthForm.climber => 0.6,
    _ => t.lifeCycle == LifeCycle.perennial ? 0.5 : 0.2,
  };
  final scores = {
    PotionEffect.regrowth: regrowth,
    PotionEffect.abundance: [
      t.dispersal.contains(SeedDispersal.eatenByAnimals) || t.dispersal.contains(SeedDispersal.hoardedByAnimals)
          ? 0.8
          : 0.0,
      t.lifeCycle == LifeCycle.annual || t.lifeCycle == LifeCycle.biennial ? 0.7 : 0.0,
      (t.nutrients ?? 5) >= 6 ? 0.6 : 0.0,
      0.3,
    ].reduce(max),
    PotionEffect.clarity: [
      _aromaticFamilies.contains(s.family) ? 0.9 : 0.0,
      _soothingFamilies.contains(s.family) ? 0.65 : 0.0,
      _light(s) >= 7.5 ? 0.45 : 0.0,
      0.2,
    ].reduce(max),
    PotionEffect.omen: [
      toxic ? 0.85 : 0.0,
      s.family == 'Orchidaceae' ? 0.75 : 0.0,
      _light(s) <= 4 ? 0.5 : 0.0,
      0.2,
    ].reduce(max),
  };
  final ranked = [...PotionEffect.values]
    ..sort((a, b) => scores[a] != scores[b] ? scores[b]!.compareTo(scores[a]!) : a.index.compareTo(b.index));
  return scores[ranked[1]]! >= 0.6 ? ranked.take(2).toList() : ranked.take(1).toList();
}
