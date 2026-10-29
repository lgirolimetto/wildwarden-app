import 'dart:convert';

import 'package:druid_app/business_logic/services/catalog/asset_catalog_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _StringBundle extends CachingAssetBundle {
  final String content;

  _StringBundle(this.content);

  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('il catalogo di Bologna incluso nell\'app è valido e completo', () async {
    final result = await AssetCatalogRepository().loadCatalog();

    result.fold((failures) => fail('Catalogo non valido: ${failures.join(', ')}'), (catalog) {
      expect(catalog.species, hasLength(50));
      expect(catalog.species.every((s) => s.images.isNotEmpty), isTrue, reason: 'ogni specie ha almeno una foto');
      expect(
        catalog.species.map((s) => s.gbifKey).whereType<int>().toSet(),
        hasLength(50),
        reason: 'ogni specie ha la sua chiave GBIF (per legare le risposte di Pl@ntNet)',
      );
      expect(catalog.mythics, hasLength(3));
      for (final mythic in catalog.mythics) {
        for (final ingredient in mythic.ingredients.where((i) => i.speciesSci != null)) {
          expect(
            catalog.speciesBySci(ingredient.speciesSci!),
            isNotNull,
            reason: 'ingrediente ${ingredient.speciesSci}',
          );
        }
      }
    });
  });

  test('le aromatiche del tutorial: a parte dalla Zona, con foto e chiave GBIF; il basilico è un\'Ospite', () async {
    final result = await AssetCatalogRepository().loadCatalog();

    result.fold((failures) => fail('Catalogo non valido: ${failures.join(', ')}'), (catalog) {
      expect(catalog.kitchen.map((s) => s.sci), ['Salvia rosmarinus', 'Salvia officinalis', 'Ocimum basilicum']);
      expect(catalog.kitchen.every((s) => s.images.isNotEmpty && s.gbifKey != null), isTrue);
      expect(catalog.species.where((s) => catalog.isKitchen(s.sci)), isEmpty, reason: 'non entrano nella Zona');
      expect(catalog.speciesBySci('Ocimum basilicum')?.name.resolve('it'), 'Basilico');
      expect(catalog.speciesByGbifKey(catalog.kitchen.last.gbifKey!)?.sci, 'Ocimum basilicum');
      expect(catalog.kitchenGuests, {'Ocimum basilicum'});
      expect(catalog.origins['Ocimum basilicum']?.resolve('it'), contains('Asia'));
      expect(catalog.speciesBySci('Laurus nobilis'), isNotNull, reason: "l'alloro è della Zona");
    });
  });

  test('un JSON non valido diventa un Fail, non un\'eccezione', () async {
    final result = await AssetCatalogRepository(bundle: _StringBundle('{rotto')).loadCatalog();
    expect(result.isValid, isFalse);
  });

  test('un asset mancante diventa un Fail', () async {
    final result = await AssetCatalogRepository(assetPath: 'assets/non/esiste.json').loadCatalog();
    expect(result.isValid, isFalse);
  });
}
