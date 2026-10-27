import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/essences.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/recycling.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final feb = DateTime(2027, 2, 1);
  const malva = 'Malva sylvestris';
  EssenceDrawn drawn({List<String> traits = const [], double? purity, int vis = 10}) =>
      EssenceDrawn(speciesSci: malva, traits: traits, simulated: true, vis: vis, purity: purity, occurredAt: feb);

  test('ogni Essenza resta nella Dispensa con tratti, purezza e Vis', () {
    final state = GameState.replay([
      drawn(traits: ['dew'], purity: 0.75),
      drawn(),
    ]);
    expect(state.essences, hasLength(2));
    expect(state.essences.first.traits, ['dew']);
    expect(state.essences.first.purity, 0.75);
    expect(state.vis, {malva: 20});
  });

  test('le Essenze di prima della Dispensa prendono la purezza del livello di studio di allora', () {
    final state = GameState.replay([
      drawn(),
      LevelPassed(speciesSci: malva, level: 2, xp: 0, occurredAt: feb),
      drawn(),
    ]);
    expect(state.essences.map((e) => e.purity), [purityOfLevel(0), purityOfLevel(2)]);
    expect(purityByLevel, [0.4, 0.6, 0.75, 0.9, 1.0]);
  });

  test('il riciclo spende prima le Essenze senza tratti e meno pure: quelle con i tratti restano', () {
    final state = GameState.replay([
      drawn(traits: ['moon'], purity: 0.4),
      drawn(purity: 0.9),
      drawn(purity: 0.6),
      TroveOpened(
        grade: Grade.uncommon,
        price: 0,
        finds: [
          const TroveFind(recipeId: 'r', grade: Grade.uncommon, kind: TroveFindKind.recipe, missing: 1),
          for (var i = 0; i < 3; i++)
            const TroveFind(recipeId: 'x', grade: Grade.uncommon, kind: TroveFindKind.recycled),
        ],
        occurredAt: feb,
      ),
    ]);
    final vis = visToSpend(state, 15)!;
    final after = state.apply(
      RecipeRecycled(recipeId: 'r', fromGrade: Grade.uncommon, used: 3, vis: vis, occurredAt: feb),
    );
    expect(after.essences.map((e) => e.vis), [10, 5, 0], reason: 'prima la 0,6, poi la 0,9; la Lunare intatta');
  });
}
