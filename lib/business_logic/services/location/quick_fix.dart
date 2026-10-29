import 'dart:async';

import 'package:druid_app/business_logic/interfaces/i_location_sampler.dart';
import 'package:druid_app/business_logic/models/location_fix.dart';

/// Precisione che basta per dire "sei alla tua Stazione" (le Stazioni stanno entro 20 m).
const quickFixAccuracy = 30.0;

/// Una posizione in pochi secondi, prima del mirino: la prima abbastanza precisa, o la migliore arrivata entro
/// [timeout]. Null senza GPS (spento, negato, nessuna posizione).
Future<LocationFix?> quickFix(ILocationSampler sampler, {Duration timeout = const Duration(seconds: 6)}) async {
  final recording = (await sampler.start()).fold((_) => null, (r) => r);
  if (recording == null) return null;
  LocationFix? best() => recording.fixes.isEmpty
      ? null
      : (recording.fixes.toList()..sort((a, b) => a.accuracy.compareTo(b.accuracy))).first;
  try {
    if (best() case final fix? when fix.accuracy <= quickFixAccuracy) return fix;
    return await recording.updates.firstWhere((f) => f.accuracy <= quickFixAccuracy).timeout(timeout);
  } on TimeoutException {
    return best();
  } on StateError {
    return best();
  } finally {
    await recording.stop();
  }
}
