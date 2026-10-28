import 'dart:async';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_location_sampler.dart';
import 'package:geolocator/geolocator.dart';

/// Posizioni da `geolocator` (fused provider di Google su Android), una al secondo alla massima precisione. Un solo
/// ascolto del GPS per tutte le raccolte aperte: si accende con la prima e si spegne con l'ultima.
class GeolocatorSampler implements ILocationSampler {
  final _open = <LocationRecording>{};
  StreamSubscription<Position>? _subscription;

  GeolocatorSampler();

  @override
  Future<Validation<LocationRecording>> start() async {
    final problem = await _permissionProblem();
    if (problem != null) return Fail.withError(StateError(problem), message: problem).toInvalid();

    late final LocationRecording recording;
    recording = LocationRecording(() => _close(recording));
    _open.add(recording);
    _subscription ??=
        Geolocator.getPositionStream(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
            intervalDuration: const Duration(seconds: 1),
          ),
        ).listen((position) {
          for (final open in _open.toList()) {
            open.add(latitude: position.latitude, longitude: position.longitude, accuracy: position.accuracy);
          }
        }, onError: (Object _) {});
    return Valid(recording);
  }

  Future<void> _close(LocationRecording recording) async {
    _open.remove(recording);
    if (_open.isEmpty) {
      await _subscription?.cancel();
      _subscription = null;
    }
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
