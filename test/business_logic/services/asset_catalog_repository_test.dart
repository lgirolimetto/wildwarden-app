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

  test('un JSON non valido diventa un Fail, non un\'eccezione', () async {
    final result = await AssetCatalogRepository(bundle: _StringBundle('{rotto')).loadCatalog();
    expect(result.isValid, isFalse);
  });

  test('un asset mancante diventa un Fail', () async {
    final result = await AssetCatalogRepository(assetPath: 'assets/non/esiste.json').loadCatalog();
    expect(result.isValid, isFalse);
  });
}
