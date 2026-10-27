import 'dart:convert';
import 'dart:io';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/rules/recipes/recipe_book.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test d'oro: le regole in Dart danno sulle 50 specie di Bologna le stesse pagine dell'anteprima Python del core
/// (`tools/recipe-preview/preview.py`, che scrive `out/pagine.json`). Se si cambia una regola, la si cambia in tutti e
/// due e si ricopia la fixture.
void main() {
  final catalog = Catalog.fromJson(
    jsonDecode(File('assets/content/bologna/catalog.json').readAsStringSync()) as Map<String, dynamic>,
  );
  final expected = (jsonDecode(File('test/fixtures/recipe_pages_bologna.json').readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();
  final book = RecipeBook.of(catalog);

  test('una pagina per ogni specie, nello stesso ordine', () {
    expect(book.pages.map((p) => p.plant.sci), expected.map((p) => p['sci']));
    expect(book.pages.expand((p) => p.recipes), hasLength(185));
  });

  for (final want in expected) {
    test('pagina di ${want['sci']}', () {
      final page = book.pageOf(want['sci'] as String)!;
      expect(page.plant.grade.name, want['grade']);
      expect(page.favouredTraits.map((t) => t.name), want['favouredTraits']);
      expect(page.vocation.map((e) => e.name), want['vocation']);
      final cards = (want['cards'] as List).cast<Map<String, dynamic>>();
      expect(page.recipes, hasLength(cards.length));
      for (final (recipe, card) in [for (var i = 0; i < cards.length; i++) (page.recipes[i], cards[i])]) {
        expect(recipe.id, card['id']);
        expect(recipe.grade.name, card['grade']);
        expect(recipe.traits.map((t) => t.name), card['traits']);
        expect(recipe.effect.name, card['effect']);
        expect(recipe.name('it'), card['name']);
        expect(recipe.base.italian, card['base']);
        expect([
          for (final i in recipe.ingredients)
            {'species': i.speciesSci, 'qty': i.quantity, 'traits': i.traits.map((t) => t.name).toList()},
        ], card['ingredients']);
        expect(recipe.months, card['months'], reason: recipe.id);
      }
    });
  }
}
