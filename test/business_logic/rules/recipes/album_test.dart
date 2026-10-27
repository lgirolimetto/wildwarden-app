import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/album.dart';
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
    expect(albumPages(catalog, state), isEmpty);
  });

  test('le pagine dell\'album: solo quelle con una figurina, dalla più recente', () {
    final eranthis = book.pageOf('Eranthis hyemalis')!;
    final rare = eranthis.recipes.last;
    final state = GameState.replay([
      passed('Malva sylvestris', 1),
      learned(book.pageOf('Fagus sylvatica')!.recipes.first.id, feb),
      learned(rare.id, feb.add(const Duration(days: 2))),
    ]);
    final pages = albumPages(catalog, state);
    expect(pages.map((p) => p.page.plant.sci), ['Eranthis hyemalis', 'Fagus sylvatica', 'Malva sylvestris']);

    final first = pages.first;
    expect(first.knows(rare), isTrue);
    expect(first.knownCount, 1);
    expect(first.complete, isFalse);
  });

  test('una pagina con tutte le figurine è completa', () {
    final malva = book.pageOf('Malva sylvestris')!;
    final state = GameState.replay([for (final r in malva.recipes) learned(r.id, feb)]);
    expect(albumPages(catalog, state).single.complete, isTrue);
  });

  test('le Mitiche si conoscono per id', () {
    final state = GameState.replay([learned('lanterna-santa-lucia', feb)]);
    expect(knownMythicIds(catalog, state), {'lanterna-santa-lucia'});
    expect(knownMythicIds(catalog, GameState.empty), isEmpty);
  });
}
