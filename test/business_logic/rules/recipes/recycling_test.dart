import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/business_logic/rules/recipes/recycling.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  final catalog = smallCatalog();
  final malva = recipeBookOf(catalog).pageOf('Malva sylvestris')!;
  final uncommon = malva.recipes[1];
  final rare = malva.recipes.last;
  final feb = DateTime(2027, 2, 1);

  TroveOpened trove(List<TroveFind> finds) => TroveOpened(grade: Grade.rare, price: 0, finds: finds, occurredAt: feb);
  TroveFind duplicate(Grade grade) => TroveFind(recipeId: 'x', grade: grade, kind: TroveFindKind.recycled);
  EssenceDrawn essence(String sci, int vis) =>
      EssenceDrawn(speciesSci: sci, simulated: true, vis: vis, occurredAt: feb);

  test('3 riciclati del grado della Tavola o 9 del grado sotto', () {
    final state = GameState.replay([
      trove([
        TroveFind(recipeId: uncommon.id, grade: Grade.uncommon, kind: TroveFindKind.recipe, missing: 1),
        TroveFind(recipeId: rare.id, grade: Grade.rare, kind: TroveFindKind.recipe, missing: 2),
        for (var i = 0; i < 9; i++) duplicate(Grade.common),
        for (var i = 0; i < 3; i++) duplicate(Grade.uncommon),
      ]),
    ]);
    final options = recycleOptions(catalog, state);
    expect(
      options.map((o) => (o.recipeId, o.fromGrade, o.used, o.visCost)),
      unorderedEquals([(uncommon.id, Grade.uncommon, 3, 10), (uncommon.id, Grade.common, 9, 10)]),
      reason: 'per la Rara servono 9 Non comuni (ne hai 3) o 3 Rare (nessuna): niente',
    );
  });

  test('il riciclo spende riciclati e Vis e aggiunge un componente; all\'ultimo la Tavola è completa', () {
    final before = GameState.replay([
      essence('Malva sylvestris', 8),
      essence('Fagus sylvatica', 5),
      trove([
        TroveFind(recipeId: uncommon.id, grade: Grade.uncommon, kind: TroveFindKind.recipe, missing: 1),
        for (var i = 0; i < 4; i++) duplicate(Grade.uncommon),
      ]),
    ]);
    final vis = visToSpend(before, 10)!;
    expect(vis, {
      'Malva sylvestris': 8,
      'Fagus sylvatica': 2,
    }, reason: 'prima le Essenze meno preziose: a pari tratti e purezza, le più vecchie');
    final after = before.apply(
      RecipeRecycled(recipeId: uncommon.id, fromGrade: Grade.uncommon, used: 3, vis: vis, occurredAt: feb),
    );
    expect(after.recycled[Grade.uncommon], 1);
    expect(after.vis, {'Malva sylvestris': 0, 'Fagus sylvatica': 3});
    expect(after.missingPieces, isEmpty);
    expect(after.learnedRecipes.keys, [uncommon.id]);
    expect(visToSpend(after, 10), isNull, reason: 'restano 3 Vis');
  });

  test('l\'evento si rilegge uguale dal database', () {
    final event = RecipeRecycled(
      recipeId: rare.id,
      fromGrade: Grade.uncommon,
      used: 9,
      vis: const {'Malva sylvestris': 20},
      occurredAt: feb,
    );
    final back = GameEvent.decode(type: event.type, payload: event.encodePayload(), occurredAt: feb);
    expect(back.payload(), event.payload());
  });
}
