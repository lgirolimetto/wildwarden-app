/// Una posizione del GPS, con il tempo passato dall'inizio della misura e la precisione in metri.
class LocationFix {
  final Duration elapsed;
  final double latitude;
  final double longitude;
  final double accuracy;

  const LocationFix({required this.elapsed, required this.latitude, required this.longitude, required this.accuracy});
}

/// La precisione migliore raggiunta entro [time] dall'inizio della misura, o null se non c'era ancora una posizione.
double? bestAccuracyWithin(List<LocationFix> fixes, Duration time) {
  double? best;
  for (final fix in fixes) {
    if (fix.elapsed > time) continue;
    if (best == null || fix.accuracy < best) best = fix.accuracy;
  }
  return best;
}
