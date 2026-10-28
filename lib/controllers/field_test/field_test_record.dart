import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/models/location_fix.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';

/// Una prova sul campo (step 0 del blocco 2): foto, Pl@ntNet e GPS, in una riga del CSV.
///
/// I tempi partono dal tocco su "Scatta e misura", quando comincia anche la raccolta delle posizioni. Durante lo
/// scatto l'app è dietro la fotocamera di sistema: le posizioni di quel tratto dicono se Android le consegna lo stesso.
class FieldTestRecord {
  static const header =
      'quando,pianta_attesa,luogo,foto_s,foto_kb,plantnet_ms,esito,'
      'top1,punteggio1,top2,punteggio2,top3,punteggio3,giusta_top1,giusta_top3,rimaste,'
      'gps_esito,gps_primo_s,precisione_5s_m,precisione_10s_m,precisione_20s_m,'
      'posizioni_durante_foto,gps_dopo_foto_primo_s,precisione_dopo_foto_10s_m,posizioni,'
      'fotocamera,fotogrammi_s,analizzati_s,analisi_ms,scatto_ms,riduzione_ms,zoom,flash,vis';

  /// Dopo la foto le posizioni si raccolgono ancora per questo tempo (mentre risponde Pl@ntNet).
  static const afterPhoto = Duration(seconds: 10);

  /// Dal tocco le posizioni si raccolgono almeno per questo tempo.
  static const minimumWindow = Duration(seconds: 20);

  final DateTime at;
  final String expected;
  final String place;

  /// Dal tocco alla foto pronta.
  final Duration? photoTime;
  final int? photoKb;
  final Duration? identifyTime;

  /// "ok", "nessuna" (Pl@ntNet non riconosce niente), "annullata" o il messaggio d'errore.
  final String outcome;
  final List<PlantCandidate> candidates;
  final int? remainingRequests;

  /// "ok" o il messaggio d'errore della posizione (permesso negato, posizione spenta).
  final String locationOutcome;
  final List<LocationFix> fixes;

  /// Fotocamera dell'app o di sistema; le misure dello streaming solo con quella dell'app.
  final bool systemCamera;
  final CameraDiagnostics? diagnostics;

  /// Vis piena o debole allo scatto (solo fotocamera dell'app).
  final bool? visFull;

  const FieldTestRecord({
    required this.at,
    required this.expected,
    required this.place,
    required this.photoTime,
    required this.photoKb,
    required this.identifyTime,
    required this.outcome,
    required this.candidates,
    required this.remainingRequests,
    required this.locationOutcome,
    required this.fixes,
    this.systemCamera = false,
    this.diagnostics,
    this.visFull,
  });

  Duration? get firstFix => fixes.isEmpty ? null : fixes.first.elapsed;
  double? accuracyWithin(Duration time) => bestAccuracyWithin(fixes, time);

  List<LocationFix> get _afterPhoto => photoTime == null
      ? const []
      : [
          for (final fix in fixes)
            if (fix.elapsed > photoTime!) fix,
        ];

  int get fixesDuringPhoto => photoTime == null ? 0 : fixes.where((fix) => fix.elapsed <= photoTime!).length;

  /// Quanto dopo il ritorno dalla fotocamera arriva la prima posizione.
  Duration? get firstFixAfterPhoto => _afterPhoto.isEmpty ? null : _afterPhoto.first.elapsed - photoTime!;

  /// La precisione migliore nei 10 secondi dopo la foto.
  double? get accuracyAfterPhoto => photoTime == null ? null : bestAccuracyWithin(_afterPhoto, photoTime! + afterPhoto);

  /// Uno dei primi [count] candidati è la pianta attesa? Basta un pezzo del nome scientifico o di un nome comune
  /// ("elleboro", "Helleborus", "helleborus viridis"); null se la pianta attesa non è scritta.
  bool? matchesWithin(int count) {
    final wanted = expected.trim().toLowerCase();
    if (wanted.isEmpty) return null;
    return candidates
        .take(count)
        .any(
          (c) => [c.scientificName, ...c.commonNames].any((name) {
            final have = name.toLowerCase();
            return have.contains(wanted) || wanted.contains(have);
          }),
        );
  }

  String toCsvRow() {
    String cell(Object? value) {
      if (value == null) return '';
      final text = value.toString();
      return text.contains(RegExp('[",\n]')) ? '"${text.replaceAll('"', '""')}"' : text;
    }

    String seconds(Duration? d) => d == null ? '' : (d.inMilliseconds / 1000).toStringAsFixed(1);
    String metres(double? m) => m == null ? '' : m.toStringAsFixed(0);
    String candidate(int i) => i < candidates.length ? cell(candidates[i].scientificName) : '';
    String score(int i) => i < candidates.length ? candidates[i].score.toStringAsFixed(3) : '';

    return [
      at.toIso8601String(),
      cell(expected),
      cell(place),
      seconds(photoTime),
      cell(photoKb),
      cell(identifyTime?.inMilliseconds),
      cell(outcome),
      candidate(0),
      score(0),
      candidate(1),
      score(1),
      candidate(2),
      score(2),
      cell(matchesWithin(1)),
      cell(matchesWithin(3)),
      cell(remainingRequests),
      cell(locationOutcome),
      seconds(firstFix),
      metres(accuracyWithin(const Duration(seconds: 5))),
      metres(accuracyWithin(const Duration(seconds: 10))),
      metres(accuracyWithin(const Duration(seconds: 20))),
      fixesDuringPhoto,
      seconds(firstFixAfterPhoto),
      metres(accuracyAfterPhoto),
      fixes.length,
      systemCamera ? 'sistema' : 'app',
      diagnostics?.receivedPerSecond.toStringAsFixed(1) ?? '',
      diagnostics?.analyzedPerSecond.toStringAsFixed(1) ?? '',
      diagnostics?.analysisMs.toStringAsFixed(1) ?? '',
      cell(diagnostics?.captureMs),
      cell(diagnostics?.resizeMs),
      diagnostics?.zoom.toStringAsFixed(1) ?? '',
      cell(diagnostics?.flash),
      switch (visFull) {
        true => 'piena',
        false => 'debole',
        null => '',
      },
    ].join(',');
  }
}
