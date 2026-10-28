import 'dart:typed_data';

import 'package:druid_app/business_logic/interfaces/i_frame_analyzer.dart';

/// Analisi di prova (step 1b del Campo): riduce il fotogramma a una griglia di 320×240 punti e ne misura nitidezza e
/// movimento, un lavoro simile al primo passo della verifica del blocco 5 (seguire i punti tra i fotogrammi). Come
/// indizio provvisorio conta il movimento del telefono: fermo non riempie l'anello della Vis, mosso piano sì, mosso
/// troppo (immagine mossa o un'altra scena) no. Non distingue una foto da una pianta: lo farà il blocco 5.
class ProbeFrameAnalyzer implements IFrameAnalyzer {
  static const gridWidth = 320;
  static const gridHeight = 240;

  /// Movimento medio per punto (0–255): sotto [stillMotion] è il rumore del sensore a telefono fermo (2–3 sul Poco al
  /// chiuso), da [steadyMotion] l'indizio è pieno, sopra [blurMotion] l'immagine è mossa.
  static const stillMotion = 5.0;
  static const steadyMotion = 12.0;
  static const blurMotion = 45.0;

  Uint8List? _previous;

  @override
  FrameVerdict analyze(CameraFrame frame) {
    final grid = Uint8List(gridWidth * gridHeight);
    for (var y = 0; y < gridHeight; y++) {
      final row = (y * frame.height ~/ gridHeight) * frame.bytesPerRow;
      for (var x = 0; x < gridWidth; x++) {
        grid[y * gridWidth + x] = frame.luma[row + x * frame.width ~/ gridWidth];
      }
    }

    var edges = 0, changes = 0;
    final previous = _previous;
    for (var y = 1; y < gridHeight; y++) {
      for (var x = 1; x < gridWidth; x++) {
        final i = y * gridWidth + x;
        edges += (grid[i] - grid[i - 1]).abs() + (grid[i] - grid[i - gridWidth]).abs();
        if (previous != null) changes += (grid[i] - previous[i]).abs();
      }
    }
    _previous = grid;
    const points = (gridWidth - 1) * (gridHeight - 1);
    final motion = previous == null ? 0.0 : changes / points;
    return FrameVerdict(evidence: evidenceOf(motion), sharpness: edges / points / 2, motion: motion);
  }

  @override
  void reset() => _previous = null;

  static double evidenceOf(double motion) =>
      motion > blurMotion ? 0 : ((motion - stillMotion) / (steadyMotion - stillMotion)).clamp(0, 1);
}
