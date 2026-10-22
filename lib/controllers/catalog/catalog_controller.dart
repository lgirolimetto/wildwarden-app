import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_catalog_repository.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/controllers/base/loadable_controller.dart';

/// Tiene il catalogo della zona corrente, caricato una volta all'avvio.
class CatalogController extends LoadableController<Catalog> {
  final ICatalogRepository _repository;

  CatalogController(this._repository);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  Future<Validation<Catalog>> fetch() => _repository.loadCatalog();
}
