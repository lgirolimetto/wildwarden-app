import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/essence.dart';
import 'package:druid_app/business_logic/models/mythic.dart';
import 'package:druid_app/business_logic/rules/economy.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/affixes.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';

/// Preparare una pozione (capitolo 02): le ricette chiedono Vis di una specie, spesso con un tratto; si prendono dalle
/// Essenze della Dispensa. La potenza (1–10) viene soprattutto dalla purezza, poi dai tratti rari e dalla rarità
/// delle piante.

/// Un ingrediente come lo chiede la preparazione: Vis di una specie (o di una pianta a scelta) con dei tratti.
class BrewIngredient {
  /// `null` = lo slot libero, "qualsiasi specie": la pianta la scegli tu.
  final String? speciesSci;
  final List<Trait> traits;
  final int vis;

  const BrewIngredient({required this.speciesSci, required this.traits, required this.vis});
}

/// Una ricetta che si può preparare: una Tavola o una Mitica.
class Brewable {
  final String id;
  final Grade grade;
  final List<BrewIngredient> ingredients;

  /// Da bere: una pianta tossica nello slot libero guasta la pozione. Unguenti e Balsami sono da uso esterno.
  final bool drinkable;

  /// Solo per le Mitiche con una finestra di date.
  final DateWindow? window;

  /// La base, per l'accordo del Tocco ("Infuso Limpido", "Tintura Limpida"); `null` per le Mitiche.
  final RecipeBase? base;

  const Brewable({
    required this.id,
    required this.grade,
    required this.ingredients,
    required this.drinkable,
    this.window,
    this.base,
  });

  BrewIngredient? get freeSlot => ingredients.where((i) => i.speciesSci == null).firstOrNull;
}

/// La ricetta [id] pronta da preparare: una Tavola o una Mitica; `null` se l'id non esiste.
Brewable? brewableOf(Catalog catalog, String id) {
  for (final m in catalog.mythics) {
    if (m.id != id) continue;
    return Brewable(
      id: id,
      grade: Grade.mythic,
      ingredients: [
        for (final i in m.ingredients)
          BrewIngredient(speciesSci: i.speciesSci, traits: [?i.trait], vis: i.quantity * EconomyRules.visPerQuantity),
      ],
      drinkable: true,
      window: m.window,
    );
  }
  final recipe = recipeBookOf(catalog).recipeById(id);
  if (recipe == null) return null;
  return Brewable(
    id: id,
    grade: recipe.grade,
    ingredients: [
      for (final i in recipe.ingredients)
        BrewIngredient(speciesSci: i.speciesSci, traits: i.traits, vis: i.quantity * EconomyRules.visPerQuantity),
    ],
    drinkable: recipe.base != RecipeBase.ointment && recipe.base != RecipeBase.balm,
    base: recipe.base,
  );
}

/// Ciò che manca a un ingrediente: [vis] Vis che non hai.
class BrewShortfall {
  final BrewIngredient ingredient;
  final int vis;

  const BrewShortfall(this.ingredient, this.vis);
}

/// Come si prepara: quante Vis prendere da ogni Essenza (per [Essence.index]) e cosa manca.
class BrewPlan {
  final Map<int, int> taken;
  final List<BrewShortfall> missing;

  /// La pianta dello slot libero, se c'è e l'hai scelta.
  final String? freeSpecies;

  const BrewPlan({required this.taken, required this.missing, this.freeSpecies});

  bool get ready => missing.isEmpty;
}

/// Prende le Vis per [brewable] dalle Essenze: per ogni ingrediente quelle della sua specie con tutti i tratti
/// chiesti, prima le più pure (la potenza viene dalla purezza); gli ingredienti con più tratti scelgono per primi. Lo
/// slot libero usa [freeSpecies] (con qualsiasi tratto); senza, resta tra le cose che mancano.
BrewPlan planBrew(Brewable brewable, List<Essence> essences, {String? freeSpecies}) {
  final left = {for (final e in essences) e.index: e.vis};
  final taken = <int, int>{};
  final missing = <BrewShortfall>[];
  final order = [...brewable.ingredients]
    ..sort((a, b) {
      if ((a.speciesSci == null) != (b.speciesSci == null)) return a.speciesSci == null ? 1 : -1;
      return b.traits.length.compareTo(a.traits.length);
    });
  for (final ingredient in order) {
    final sci = ingredient.speciesSci ?? freeSpecies;
    if (sci == null) {
      missing.add(BrewShortfall(ingredient, ingredient.vis));
      continue;
    }
    final candidates = [
      for (final e in essences)
        if (e.speciesSci == sci && left[e.index]! > 0 && ingredient.traits.every((t) => e.traits.contains(t.name))) e,
    ]..sort((a, b) => a.purity != b.purity ? b.purity.compareTo(a.purity) : a.index.compareTo(b.index));
    var need = ingredient.vis;
    for (final e in candidates) {
      if (need <= 0) break;
      final take = left[e.index]! < need ? left[e.index]! : need;
      left[e.index] = left[e.index]! - take;
      taken[e.index] = (taken[e.index] ?? 0) + take;
      need -= take;
    }
    if (need > 0) missing.add(BrewShortfall(ingredient, need));
  }
  return BrewPlan(taken: taken, missing: missing, freeSpecies: freeSpecies);
}

/// Le piante che possono andare nello slot libero: quelle con abbastanza Vis dopo gli altri ingredienti, dalla più
/// fornita (a pari Vis in ordine di nome). Vuota se la ricetta non ha slot libero.
List<String> freeSlotCandidates(Brewable brewable, List<Essence> essences) {
  final free = brewable.freeSlot;
  if (free == null) return const [];
  final fixed = planBrew(brewable, essences, freeSpecies: '');
  final left = <String, int>{};
  for (final e in essences) {
    final rest = e.vis - (fixed.taken[e.index] ?? 0);
    if (rest > 0) left[e.speciesSci] = (left[e.speciesSci] ?? 0) + rest;
  }
  return [
    for (final MapEntry(key: sci, value: vis)
        in left.entries.toList()
          ..sort((a, b) => a.value != b.value ? b.value.compareTo(a.value) : a.key.compareTo(b.key)))
      if (vis >= free.vis) sci,
  ];
}

/// I tratti che valgono di più nella potenza (`rare_traits` del simulatore).
const rareTraits = {Trait.moon, Trait.newMoon, Trait.frost, Trait.fog, Trait.dew, Trait.dawn, Trait.dusk};

/// Pesi della potenza: la purezza pesa più che nel simulatore (decisione del 2026-10-27, "la purezza deve pesare di
/// più"), tratti rari e rarità delle piante il resto.
const potencyWeights = (purity: 0.6, rareTraits: 0.2, rarity: 0.2);

/// Potenza da 1 a 10 delle Vis prese da [plan]: media pesata sulle Vis di purezza (0,4 → 0, 1,0 → 1), quota di Vis con
/// un tratto raro e rarità delle piante (comune 0 … mitica 1). Con Essenze al 40 % non si supera 5; con la maestria e
/// piante comuni senza tratti rari si arriva a 6; il 10 vuole maestria, tratti rari e piante rare.
int potencyOf(BrewPlan plan, List<Essence> essences, Catalog catalog) {
  final byIndex = {for (final e in essences) e.index: e};
  var total = 0, purity = 0.0, rare = 0.0, rarity = 0.0;
  for (final MapEntry(key: index, value: vis) in plan.taken.entries) {
    final e = byIndex[index]!;
    total += vis;
    purity += vis * ((e.purity - 0.4) / 0.6).clamp(0.0, 1.0);
    if (e.traits.any((t) => rareTraits.any((r) => r.name == t))) rare += vis;
    rarity += vis * ((catalog.speciesBySci(e.speciesSci)?.grade.index ?? 0) / Grade.mythic.index);
  }
  if (total == 0) return 1;
  final score =
      potencyWeights.purity * purity / total +
      potencyWeights.rareTraits * rare / total +
      potencyWeights.rarity * rarity / total;
  return (1 + 9 * score).round().clamp(1, 10);
}

/// PE di una pozione: quelli del grado a potenza 5, in proporzione alla potenza.
int potionXpOf(Grade grade, int potency) => (EconomyRules.potionXp(grade) * potency / 5).round();

/// Il Tocco: l'aggettivo che la pianta dello slot libero dà alla pozione, dall'effetto principale della sua
/// vocazione.
PotionEffect? touchOf(Catalog catalog, String? freeSpecies) {
  if (freeSpecies == null) return null;
  return recipeBookOf(catalog).pageOf(freeSpecies)?.vocation.first;
}

/// La pozione si guasta: una pianta tossica nello slot libero di una ricetta da bere.
bool spoils(Brewable brewable, Catalog catalog, String? freeSpecies) =>
    brewable.drinkable && freeSpecies != null && catalog.safety.containsKey(freeSpecies);

/// Pozioni preparate oggi (anche guastate).
int brewsToday(GameState state, DateTime now) => state.brewTimes.where((t) => _sameDay(t, now)).length;

/// Perché non si può preparare adesso; `null` se si può (le Vis le dice [BrewPlan]).
enum BrewBlock { dailyLimit, outOfWindow }

BrewBlock? brewBlock(GameState state, Brewable brewable, DateTime now) {
  if (brewable.window case final DateWindow window when !window.contains(now)) return BrewBlock.outOfWindow;
  return brewsToday(state, now) >= EconomyRules.brewsPerDay ? BrewBlock.dailyLimit : null;
}

/// Le ricette che conosci (complete), da preparare: Tavole e Mitiche.
List<Brewable> knownBrewables(Catalog catalog, GameState state) => [
  for (final id in {...knownRecipeIds(catalog, state), ...state.learnedRecipes.keys})
    if (!state.missingPieces.containsKey(id)) ?brewableOf(catalog, id),
];

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
