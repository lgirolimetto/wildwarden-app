import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/models/catalog.dart';

/// Sorgente del catalogo di una zona. Oggi è un asset dell'app; con il server sarà scaricabile
/// e aggiornabile senza pubblicare una nuova versione.
abstract interface class ICatalogRepository {
  Future<Validation<Catalog>> loadCatalog();
}
