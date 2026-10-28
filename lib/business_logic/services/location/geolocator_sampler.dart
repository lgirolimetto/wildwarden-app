import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_location_sampler.dart';
import 'package:druid_app/business_logic/models/location_fix.dart';
import 'package:geolocator/geolocator.dart';

/// Posizioni da `geolocator` (fused provider di Google su Android), una al secondo alla massima precisione.
class GeolocatorSampler implements ILocationSampler {
  const GeolocatorSampler();

  @override
  Future<Validation<LocationRecording>> start() async {
    final problem = await _permissionProblem();
    if (problem != null) return Fail.withError(StateError(problem), message: problem).toInvalid();

    final fixes = <LocationFix>[];
    final watch = Stopwatch()..start();
    final subscription =
        Geolocator.getPositionStream(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
            intervalDuration: const Duration(seconds: 1),
          ),
        ).listen(
          (position) => fixes.add(
            LocationFix(
              elapsed: watch.elapsed,
              latitude: position.latitude,
              longitude: position.longitude,
              accuracy: position.accuracy,
            ),
          ),
          onError: (Object _) {},
        );
    return Valid(LocationRecording(fixes, subscription.cancel));
  }

  Future<String?> _permissionProblem() async {
    if (!await Geolocator.isLocationServiceEnabled()) return 'Posizione spenta';
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    return switch (permission) {
      LocationPermission.denied => 'Permesso della posizione negato',
      LocationPermission.deniedForever => 'Permesso della posizione negato per sempre',
      _ => null,
    };
  }
}
