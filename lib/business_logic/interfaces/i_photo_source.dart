import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';

/// Scatto di una foto con la fotocamera.
abstract interface class IPhotoSource {
  Future<Validation<TakenPhoto>> takePhoto();
}

/// La foto scattata, o nessuna se chi gioca è tornato indietro senza scattare.
class TakenPhoto {
  final String? path;

  /// Solo dalla fotocamera dell'app: come è andata l'analisi dei fotogrammi e la riduzione della foto.
  final CameraDiagnostics? diagnostics;

  /// Solo dalla fotocamera dell'app: la Vis era piena (verifica passata) o debole ("Raccogli comunque").
  final bool? visFull;

  const TakenPhoto(this.path, {this.diagnostics, this.visFull});

  static const cancelled = TakenPhoto(null);
}

/// Misure della fotocamera dell'app (prova di fattibilità dello step 1b del Campo).
class CameraDiagnostics {
  /// Fotogrammi al secondo consegnati dallo streaming e quelli analizzati davvero.
  final double receivedPerSecond;
  final double analyzedPerSecond;

  /// Tempo medio di analisi di un fotogramma.
  final double analysisMs;

  /// Dallo scatto alla foto ridotta e salvata.
  final int captureMs;
  final int resizeMs;

  /// Zoom e flash dello scatto ("off", "auto", "always").
  final double zoom;
  final String flash;

  const CameraDiagnostics({
    required this.receivedPerSecond,
    required this.analyzedPerSecond,
    required this.analysisMs,
    required this.captureMs,
    required this.resizeMs,
    this.zoom = 1,
    this.flash = 'off',
  });
}
