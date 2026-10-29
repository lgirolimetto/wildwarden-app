import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  final catalog = smallCatalog();
  final book = recipeBookOf(catalog);
  final feb = DateTime(2027, 2, 1);
  LevelPassed passed(String sci, int level, [DateTime? at]) =>
      LevelPassed(speciesSci: sci, level: level, xp: 20, occurredAt: at ?? feb);
  RecipeLearned learned(String id, DateTime at) =>
      RecipeLearned(recipeId: id, origin: RecipeOrigin.trove, occurredAt: at);

  test('il libro delle ricette si calcola una volta per catalogo', () {
    expect(recipeBookOf(catalog), same(book));
  });

  test('superato il livello 1 conosci la Comune della pianta, anche senza evento (studi di prima della tappa C)', () {
    final state = GameState.replay([passed('Malva sylvestris', 1)]);
    expect(knownRecipeIds(catalog, state), {book.pageOf('Malva sylvestris')!.recipes.first.id});
    expect(commonToLearn('Malva sylvestris', catalog, state), isNotNull, reason: 'evento ancora da salvare');
  });

  test('la Comune già imparata non si impara di nuovo', () {
    final common = book.pageOf('Malva sylvestris')!.recipes.first;
    final state = GameState.replay([learned(common.id, feb)]);
    expect(commonToLearn('Malva sylvestris', catalog, state), isNull);
  });

  test('gli id delle ricette scritte a mano di prima non contano più', () {
    final state = GameState.replay([learned('pozione-prova-comune', feb)]);
    expect(knownRecipeIds(catalog, state), isEmpty);
    expect(collectedPages(catalog, state), isEmpty);
  });

  test('le pagine del Ricettario: solo quelle con una Tavola, dalla più recente', () {
    final eranthis = book.pageOf('Eranthis hyemalis')!;
    final rare = eranthis.recipes.last;
    final state = GameState.replay([
      passed('Malva sylvestris', 1),
      learned(book.pageOf('Fagus sylvatica')!.recipes.first.id, feb),
      learned(rare.id, feb.add(const Duration(days: 2))),
    ]);
    final pages = collectedPages(catalog, state);
    expect(pages.map((p) => p.page.plant.sci), ['Eranthis hyemalis', 'Fagus sylvatica', 'Malva sylvestris']);

    final first = pages.first;
    expect(first.knows(rare), isTrue);
    expect(first.knownCount, 1);
    expect(first.complete, isFalse);
  });

  test('una pagina con tutte le Tavole è completa', () {
    final malva = book.pageOf('Malva sylvestris')!;
    final state = GameState.replay([for (final r in malva.recipes) learned(r.id, feb)]);
    expect(collectedPages(catalog, state).single.complete, isTrue);
  });

  test('le Mitiche si conoscono per id', () {
    final state = GameState.replay([learned('lanterna-santa-lucia', feb)]);
    expect(knownMythicIds(catalog, state), {'lanterna-santa-lucia'});
    expect(knownMythicIds(catalog, GameState.empty), isEmpty);
  });

  test('le Tavole trovate incomplete stanno nella pagina, con i pezzi che mancano; la pagina non è completa', () {
    final malva = book.pageOf('Malva sylvestris')!;
    final rare = malva.recipes.last;
    final state = GameState.replay([
      for (final r in malva.recipes.take(malva.recipes.length - 1)) learned(r.id, feb),
      TroveOpened(
        grade: Grade.rare,
        price: 0,
        finds: [TroveFind(recipeId: rare.id, grade: Grade.rare, kind: TroveFindKind.recipe, missing: 2)],
        occurredAt: feb,
      ),
      TroveOpened(
        grade: Grade.rare,
        price: 0,
        finds: const [
          TroveFind(recipeId: 'lanterna-santa-lucia', grade: Grade.mythic, kind: TroveFindKind.recipe, missing: 3),
        ],
        occurredAt: feb,
      ),
    ]);
    final page = collectedPages(catalog, state).single;
    expect(page.knows(rare), isTrue);
    expect(page.missingOf(rare), 2);
    expect(page.knownCount, malva.recipes.length);
    expect(page.complete, isFalse);
    expect(knownMythicIds(catalog, state), {'lanterna-santa-lucia'});
  });

  group('aromatiche del tutorial', () {
    final withKitchen = smallCatalog(kitchen: true);
    final book = recipeBookOf(withKitchen);

    test('una pagina con la sola Comune, fuori dalle pagine della Zona e dal Bottino', () {
      final page = book.pageOf('Ocimum basilicum')!;
      expect(page.recipes.map((r) => r.grade), [Grade.common]);
      expect(page.recipes.single.ingredients.map((i) => i.speciesSci), ['Ocimum basilicum', null]);
      expect(book.pages.map((p) => p.plant.sci), isNot(contains('Ocimum basilicum')));
      expect(book.kitchenPages, hasLength(3));
      expect(book.recipeById(page.recipes.single.id), isNotNull);
    });

    test('superato il Livello 1 la Comune è tua e la pagina compare tra quelle che hai', () {
      final state = GameState.replay([
        LevelPassed(speciesSci: 'Salvia rosmarinus', level: 1, xp: 20, occurredAt: DateTime(2026, 10, 29)),
      ]);
      expect(knownRecipeIds(withKitchen, state), {book.pageOf('Salvia rosmarinus')!.recipes.single.id});
      expect(collectedPages(withKitchen, state).map((p) => p.page.plant.sci), ['Salvia rosmarinus']);
    });
  });
}
