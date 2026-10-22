import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/controllers/catalog/catalog_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  test('carica il catalogo all\'inizializzazione', () async {
    final repository = FakeCatalogRepository(Valid(smallCatalog()));
    final controller = CatalogController(repository)..onInit();

    await Future<void>.delayed(Duration.zero);

    expect(repository.calls, 1);
    expect(controller.loading, isFalse);
    expect(controller.uiData.isValid, isTrue);
  });

  test('un errore del repository arriva alla UI come Validation non valida', () async {
    final repository = FakeCatalogRepository(StateError('rotto').toInvalid());
    final controller = CatalogController(repository);

    await controller.load();

    expect(controller.uiData.isValid, isFalse);
  });
}
