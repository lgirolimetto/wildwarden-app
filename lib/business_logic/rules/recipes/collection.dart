import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/mythic.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/recipe_book.dart';

/// Il Ricettario: una pagina per pianta con le sue Tavole, più le Mitiche numerate (capitolo 02, "Ricette ad affissi e
/// pagine per pianta"). Mostra solo le pagine di cui conosci almeno una ricetta; nella pagina le Tavole che mancano
/// sono slot vuoti con il solo cerchietto del grado.

/// Livello di studio che insegna la Comune della pianta (decisione 🔵: le prime ricette arrivano alla prima sessione).
const recipeLearningLevel = 1;

final _books = Expando<RecipeBook>('recipe-book');

/// Il libro delle ricette della Zona, calcolato una volta per catalogo.
RecipeBook recipeBookOf(Catalog catalog) => _books[catalog] ??= RecipeBook.of(catalog);

/// Il livello di studio che insegna la Non comune delle aromatiche del tutorial (capitolo 03, 2026-10-29): le Non
/// comuni della Zona restano del Bottino.
const kitchenUncommonLevel = 2;

/// Le Tavole che si imparano studiando [speciesSci] fino a [level]: la Comune dal livello [recipeLearningLevel] e,
/// per le aromatiche del tutorial, la Non comune dal livello [kitchenUncommonLevel].
List<PlantRecipe> studyRecipes(String speciesSci, int level, Catalog catalog) {
  final book = recipeBookOf(catalog);
  final page = book.pageOf(speciesSci);
  if (page == null) return const [];
  final kitchen = book.kitchenPages.contains(page);
  return [
    if (level >= recipeLearningLevel) page.recipes.first,
    if (kitchen && level >= kitchenUncommonLevel && page.recipes.length > 1) page.recipes[1],
  ];
}

/// La Tavola che si impara superando proprio il livello [level] di [speciesSci], se non la conosci già.
PlantRecipe? recipeToLearn(String speciesSci, int level, Catalog catalog, GameState state) {
  final now = studyRecipes(speciesSci, level, catalog);
  final before = studyRecipes(speciesSci, level - 1, catalog);
  final learned = now.where((r) => !before.contains(r)).firstOrNull;
  return learned == null || state.learnedRecipes.containsKey(learned.id) ? null : learned;
}

/// Id delle ricette ad affissi che conosci: quelle imparate e quelle che lo studio insegna ([studyRecipes]: la Comune
/// di ogni pianta studiata almeno al livello [recipeLearningLevel], anche quelle studiate prima della tappa C, quando la
/// ricetta imparata era un'altra; la Non comune delle aromatiche).
Set<String> knownRecipeIds(Catalog catalog, GameState state) {
  final book = recipeBookOf(catalog);
  return {
    for (final id in state.learnedRecipes.keys)
      if (book.recipeById(id) != null) id,
    for (final MapEntry(key: sci, value: level) in state.passedLevels.entries)
      for (final r in studyRecipes(sci, level, catalog)) r.id,
  };
}

/// Una pagina del Ricettario: la pagina della pianta e le Tavole che hai, complete o trovate incomplete nel Bottino.
class CollectedPage {
  final PlantPage page;

  /// Le Tavole che hai, anche incomplete.
  final Set<String> knownIds;

  /// Pezzi del nome che mancano alle Tavole incomplete, per id.
  final Map<String, int> missing;

  /// Quando hai imparato l'ultima Tavola della pagina (`null` per le Comuni studiate prima della tappa C).
  final DateTime? lastLearned;

  const CollectedPage({required this.page, required this.knownIds, this.missing = const {}, required this.lastLearned});

  /// Hai la Tavola (anche incompleta): nella pagina c'è, non è uno slot vuoto.
  bool knows(PlantRecipe recipe) => knownIds.contains(recipe.id);

  /// Pezzi del nome che mancano alla Tavola (0 = completa).
  int missingOf(PlantRecipe recipe) => missing[recipe.id] ?? 0;

  int get knownCount => page.recipes.where(knows).length;

  /// Tutte le Tavole, tutte complete.
  bool get complete => knownCount == page.recipes.length && missing.isEmpty;
}

/// Le pagine con almeno una Tavola, dalla più recente; a pari data in ordine di catalogo.
List<CollectedPage> collectedPages(Catalog catalog, GameState state) {
  final known = knownRecipeIds(catalog, state);
  bool has(PlantRecipe r) => known.contains(r.id) || state.missingPieces.containsKey(r.id);
  final pages = [
    for (final page in [...recipeBookOf(catalog).pages, ...recipeBookOf(catalog).kitchenPages])
      if (page.recipes.any(has))
        CollectedPage(
          page: page,
          knownIds: {
            for (final r in page.recipes)
              if (has(r)) r.id,
          },
          missing: {
            for (final r in page.recipes)
              if (state.missingPieces[r.id] case final int m) r.id: m,
          },
          lastLearned: page.recipes
              .map((r) => state.learnedRecipes[r.id])
              .nonNulls
              .fold<DateTime?>(null, (latest, at) => latest == null || at.isAfter(latest) ? at : latest),
        ),
  ];
  final order = {for (final (i, p) in pages.indexed) p.page.plant.sci: i};
  return pages..sort((a, b) {
    final (x, y) = (a.lastLearned, b.lastLearned);
    if (x != null && y != null && x != y) return y.compareTo(x);
    if ((x == null) != (y == null)) return x == null ? 1 : -1;
    return order[a.page.plant.sci]!.compareTo(order[b.page.plant.sci]!);
  });
}

/// Le Mitiche che hai, per id: complete o trovate incomplete (con [Mythic] a pezzi, vedi `GameState.missingPieces`).
Set<String> knownMythicIds(Catalog catalog, GameState state) => {
  for (final Mythic m in catalog.mythics)
    if (state.learnedRecipes.containsKey(m.id) || state.missingPieces.containsKey(m.id)) m.id,
};
