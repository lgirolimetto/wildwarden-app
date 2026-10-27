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

/// La Comune che si impara superando il livello [recipeLearningLevel] di [speciesSci]: la sua, se non la conosci
/// già.
PlantRecipe? commonToLearn(String speciesSci, Catalog catalog, GameState state) {
  final common = recipeBookOf(catalog).pageOf(speciesSci)?.recipes.first;
  return common == null || state.learnedRecipes.containsKey(common.id) ? null : common;
}

/// Id delle ricette ad affissi che conosci: quelle imparate e la Comune di ogni pianta studiata almeno al livello
/// [recipeLearningLevel] (anche quelle studiate prima della tappa C, quando la ricetta imparata era un'altra).
Set<String> knownRecipeIds(Catalog catalog, GameState state) {
  final book = recipeBookOf(catalog);
  return {
    for (final id in state.learnedRecipes.keys)
      if (book.recipeById(id) != null) id,
    for (final MapEntry(key: sci, value: level) in state.passedLevels.entries)
      if (level >= recipeLearningLevel) ?book.pageOf(sci)?.recipes.first.id,
  };
}

/// Una pagina del Ricettario: la pagina della pianta e le Tavole che hai.
class CollectedPage {
  final PlantPage page;
  final Set<String> knownIds;

  /// Quando hai imparato l'ultima Tavola della pagina (`null` per le Comuni studiate prima della tappa C).
  final DateTime? lastLearned;

  const CollectedPage({required this.page, required this.knownIds, required this.lastLearned});

  bool knows(PlantRecipe recipe) => knownIds.contains(recipe.id);

  int get knownCount => page.recipes.where(knows).length;

  bool get complete => knownCount == page.recipes.length;
}

/// Le pagine con almeno una Tavola, dalla più recente; a pari data in ordine di catalogo.
List<CollectedPage> collectedPages(Catalog catalog, GameState state) {
  final known = knownRecipeIds(catalog, state);
  final pages = [
    for (final page in recipeBookOf(catalog).pages)
      if (page.recipes.any((r) => known.contains(r.id)))
        CollectedPage(
          page: page,
          knownIds: {
            for (final r in page.recipes)
              if (known.contains(r.id)) r.id,
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

/// Le Mitiche che conosci, per id.
Set<String> knownMythicIds(Catalog catalog, GameState state) => {
  for (final Mythic m in catalog.mythics)
    if (state.learnedRecipes.containsKey(m.id)) m.id,
};
