import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/localized_text.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  group('Catalog.fromJson', () {
    late Catalog catalog;

    setUp(() => catalog = smallCatalog());

    test('legge specie, ricette e contenuti', () {
      expect(catalog.regionId, 'bologna');
      expect(catalog.species, hasLength(4));
      expect(catalog.recipes, hasLength(4));
      expect(catalog.safety.keys, contains('Helleborus viridis'));
    });

    test('converte stagioni, fasce e mesi', () {
      final elleboro = catalog.speciesBySci('Helleborus viridis')!;
      expect(elleboro.name.resolve('it'), 'Elleboro verde');
      expect(elleboro.peakSeason, Season.winter);
      expect(elleboro.monthsRelative, hasLength(12));
      expect(elleboro.bandShare.keys, containsAll(AltitudeBand.values));
      expect(elleboro.bestMonths, everyElement(inInclusiveRange(1, 12)));
      expect(elleboro.images, isNotEmpty);
    });

    test('tinta delle specie da trovare: letta se c\'è, assente altrimenti', () {
      expect(catalog.speciesBySci('Helleborus viridis')!.mysteryColor, 0xC9EBAD);
      expect(catalog.speciesBySci('Fagus sylvatica')!.mysteryColor, isNull);
    });

    test('ricetta con sblocco e ingrediente "qualsiasi specie"', () {
      final quota = catalog.recipes.firstWhere((r) => r.name.resolve('it').contains('Quota'));
      expect(quota.unlock!.speciesSci, 'Fagus sylvatica');
      expect(quota.unlock!.level, 3);
      expect(quota.ingredients.any((i) => i.speciesSci == null && i.trait != null), isTrue);
    });

    test('ricette: grado e tratti come id (formato 2)', () {
      final quota = catalog.recipes.firstWhere((r) => r.name.resolve('it').contains('Quota'));
      expect(quota.grade, Grade.rare);
      expect(quota.ingredients.map((i) => i.trait), containsAll([Trait.fog, Trait.moon]));
    });

    test('rarità della pianta nella Zona e correzioni a mano (formato 3)', () {
      expect(catalog.speciesBySci('Helleborus viridis')!.grade, Grade.common);
      expect(catalog.speciesBySci('Eranthis hyemalis')!.grade, Grade.uncommon);
      final faggio = catalog.speciesBySci('Fagus sylvatica')!;
      expect(faggio.grade, Grade.mythic);
      expect(faggio.favouredTraits, [Trait.fog, Trait.moon]);
      expect(faggio.vocation, [PotionEffect.regrowth]);
      // Senza correzioni la regola delle ricette calcola tratti d'elezione e vocazione.
      expect(catalog.speciesBySci('Malva sylvestris')!.favouredTraits, isNull);
      expect(catalog.speciesBySci('Malva sylvestris')!.vocation, isNull);
    });

    test('Mitiche: numero, nome in 3 pezzi, ingredienti con il tratto, finestra di date', () {
      final lanterna = catalog.mythics.single;
      expect(lanterna.number, 1);
      expect(lanterna.nameParts, hasLength(3));
      expect(lanterna.name('it'), 'La Lanterna di Santa Lucia');
      expect(lanterna.ingredients.map((i) => i.trait), [Trait.dusk, Trait.frost]);
      expect(lanterna.ingredients.first.note, isNull);
      expect(lanterna.effect, PotionEffect.regrowth);
      expect(lanterna.window!.contains(DateTime(2026, 12, 13)), isTrue);
      expect(lanterna.window!.contains(DateTime(2026, 12, 21)), isFalse);
    });

    test('parenti: stessa famiglia, esclusa la specie stessa', () {
      final elleboro = catalog.speciesBySci('Helleborus viridis')!;
      expect(catalog.relativesOf(elleboro).map((s) => s.sci), ['Eranthis hyemalis']);
    });

    test('rifiuta un formato di catalogo sconosciuto', () {
      expect(() => Catalog.fromJson({'formatVersion': 99}), throwsFormatException);
    });
  });

  group('LocalizedText', () {
    const text = LocalizedText({'it': 'Faggio', 'en': 'Beech'});

    test('usa la lingua richiesta', () => expect(text.resolve('en'), 'Beech'));

    test('ripiega sull\'italiano se la lingua manca', () => expect(text.resolve('de'), 'Faggio'));
  });
}
