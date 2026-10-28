import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/models/location_fix.dart';

/// Posizione del telefono, solo con l'app aperta (niente permesso in background).
abstract interface class ILocationSampler {
  /// Chiede il permesso se serve e comincia a raccogliere le posizioni. Fail se la posizione è spenta o negata.
  Future<Validation<LocationRecording>> start();
}

/// Una raccolta di posizioni in corso: le posizioni arrivano in [fixes] finché non si chiama [stop].
class LocationRecording {
  final List<LocationFix> fixes;
  final Future<void> Function() _stop;

  LocationRecording(this.fixes, this._stop);

  Future<List<LocationFix>> stop() async {
    await _stop();
    return List.unmodifiable(fixes);
  }
}
