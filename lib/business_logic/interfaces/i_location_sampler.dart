import 'dart:async';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/models/location_fix.dart';

/// Posizione del telefono, solo con l'app aperta (niente permesso in background).
abstract interface class ILocationSampler {
  /// Chiede il permesso se serve e comincia a raccogliere le posizioni. Fail se la posizione è spenta o negata.
  /// Più raccolte possono stare aperte insieme (il mirino e la prova sul campo): il GPS resta uno solo.
  Future<Validation<LocationRecording>> start();
}

/// Una raccolta di posizioni in corso: le posizioni arrivano in [fixes] (e in [updates]) finché non si chiama [stop].
/// Il tempo di ogni posizione parte dall'inizio di questa raccolta.
class LocationRecording {
  final List<LocationFix> fixes = [];
  final _updates = StreamController<LocationFix>.broadcast();
  final Stopwatch _watch = Stopwatch()..start();
  final Future<void> Function() _stop;
  bool _stopped = false;

  LocationRecording(this._stop);

  Stream<LocationFix> get updates => _updates.stream;

  /// Il tempo passato dall'inizio della raccolta.
  Duration get elapsed => _watch.elapsed;

  /// Una posizione nuova dal GPS, con il tempo di questa raccolta.
  void add({required double latitude, required double longitude, required double accuracy}) {
    if (_stopped) return;
    final fix = LocationFix(elapsed: _watch.elapsed, latitude: latitude, longitude: longitude, accuracy: accuracy);
    fixes.add(fix);
    _updates.add(fix);
  }

  Future<List<LocationFix>> stop() async {
    if (!_stopped) {
      _stopped = true;
      await _updates.close();
      await _stop();
    }
    return List.unmodifiable(fixes);
  }
}
