import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';

/// Riconoscimento di una pianta da una foto. Oggi Pl@ntNet chiamato dall'app; con altri utenti passa dal server.
abstract interface class IPlantIdentifier {
  Future<Validation<PlantIdentification>> identify(String photoPath);
}
