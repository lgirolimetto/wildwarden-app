import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';

/// Scatto di una foto con la fotocamera.
abstract interface class IPhotoSource {
  Future<Validation<TakenPhoto>> takePhoto();
}

/// Le foto di una pianta (intera, foglia, fiore se c'è), o nessuna se chi gioca è tornato indietro senza scattare.
class TakenPhoto {
  final List<PlantPhoto> photos;

  /// I tratti del momento dello scatto (cielo e meteo): quelli dell'Essenza. Vuoti dalla fotocamera di sistema.
  final List<Trait> traits;

  /// Solo dalla fotocamera dell'app: come è andata l'analisi dei fotogrammi e la riduzione della foto.
  final CameraDiagnostics? diagnostics;

  /// Solo dalla fotocamera dell'app: la verifica provvisoria è passata (il telefono si è mosso durante la sessione); se
  /// no lo scatto è sospetto.
  final bool? verified;

  /// Solo dalla fotocamera dell'app: la Vis raccolta (0–1), l'anello alla fine della sessione.
  final double? visGathered;

  const TakenPhoto({this.photos = const [], this.traits = const [], this.diagnostics, this.verified, this.visGathered});

  /// Una foto sola della pianta intera.
  TakenPhoto.single(String path, {this.diagnostics, this.verified, this.visGathered})
    : photos = [PlantPhoto(path, PlantOrgan.whole)],
      traits = const [];

  static const cancelled = TakenPhoto();

  /// La prima foto (la pianta intera): quella che resta come figurina.
  String? get path => photos.isEmpty ? null : photos.first.path;
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
