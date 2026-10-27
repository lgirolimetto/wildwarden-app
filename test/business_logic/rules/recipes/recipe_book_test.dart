import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/rules/recipes/affixes.dart';
import 'package:druid_app/business_logic/rules/recipes/recipe_book.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  final catalog = smallCatalog();
  final book = RecipeBook.of(catalog);

  test('la pagina ha 3, 4 o 5 Tavole secondo la rarità della pianta', () {
    expect(book.pageOf('Malva sylvestris')!.recipes.map((r) => r.grade), [Grade.common, Grade.uncommon, Grade.rare]);
    expect(book.pageOf('Eranthis hyemalis')!.recipes.map((r) => r.grade), [
      Grade.common,
      Grade.uncommon,
      Grade.uncommon,
      Grade.rare,
    ]);
  });

  test('le correzioni a mano del catalogo vincono sulla regola', () {
    final faggio = book.pageOf('Fagus sylvatica')!;
    expect(faggio.favouredTraits, [Trait.fog, Trait.moon]);
    expect(faggio.vocation, [PotionEffect.regrowth]);
    // Con due soli tratti d'elezione la pagina ha una Rara sola.
    expect(faggio.recipes.where((r) => r.grade == Grade.rare).single.traits, [Trait.moon, Trait.fog]);
  });

  test('la Comune: la pianta e una qualsiasi specie, senza tratti', () {
    final comune = book.pageOf('Malva sylvestris')!.recipes.first;
    expect(comune.traits, isEmpty);
    expect(comune.ingredients.map((i) => i.speciesSci), ['Malva sylvestris', null]);
    expect(comune.ingredients.every((i) => i.traits.isEmpty && i.quantity == 1), isTrue);
  });

  test('id deterministico con il paese, tratti in ordine fisso', () {
    final rara = book.pageOf('Fagus sylvatica')!.recipes.firstWhere((r) => r.grade == Grade.rare);
    expect(rara.id, 'it/fagus-sylvatica·moon+fog·regrowth');
    expect(book.recipeById(rara.id), same(rara));
    expect(RecipeBook.of(catalog).recipeById(rara.id)!.name('it'), rara.name('it'));
  });

  test('le tossiche solo in basi da uso esterno', () {
    for (final r in book.pageOf('Helleborus viridis')!.recipes) {
      expect(r.base, r.grade == Grade.common ? RecipeBase.ointment : RecipeBase.balm, reason: r.id);
    }
  });

  test('le tossiche fanno da compagne solo alle tossiche', () {
    final toxic = catalog.safety.keys.toSet();
    for (final page in book.pages.where((p) => !toxic.contains(p.plant.sci))) {
      for (final r in page.recipes) {
        expect(r.ingredients.skip(1).map((i) => i.speciesSci).where(toxic.contains), isEmpty, reason: r.id);
      }
    }
  });

  test('il nome parziale: la Non comune non sa l\'effetto, la Rara prima il secondo tratto e poi l\'effetto', () {
    final eranthis = book.pageOf('Eranthis hyemalis')!;
    final nonComune = eranthis.recipes.firstWhere((r) => r.grade == Grade.uncommon);
    expect(nonComune.missingPieces, [NamePiece.effect]);
    expect(nonComune.name('it', missing: 1), endsWith(' $missingPiece'));
    expect(nonComune.name('it', missing: 1), isNot(contains('della')));

    final rara = eranthis.recipes.firstWhere((r) => r.grade == Grade.rare);
    final full = rara.name('it');
    final second = traitAdjective(rara.traits[1], 'it', feminine: rara.base.feminine);
    expect(full, contains(second));
    expect(rara.name('it', missing: 2), isNot(contains(second)));
    expect(rara.name('it', missing: 1), contains(second));
    expect(rara.name('it', missing: 1), endsWith(missingPiece));
    expect(rara.name('it', missing: 0), full);
  });

  test('in inglese il nome segue l\'ordine inglese', () {
    final rara = book.pageOf('Malva sylvestris')!.recipes.last;
    expect(rara.name('en'), contains(rara.base.english));
    expect(rara.name('en'), contains(' of '));
  });
}
