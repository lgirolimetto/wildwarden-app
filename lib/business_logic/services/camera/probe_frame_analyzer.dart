import 'dart:typed_data';

import 'package:druid_app/business_logic/interfaces/i_frame_analyzer.dart';

/// Analisi di prova (step 1b del Campo): riduce il fotogramma a una griglia di 320×240 punti e ne misura nitidezza e
/// movimento, un lavoro simile al primo passo della verifica del blocco 5 (seguire i punti tra i fotogrammi). Dice
/// sempre "pronto": serve a misurare quanti fotogrammi al secondo si riescono a guardare sul telefono.
class ProbeFrameAnalyzer implements IFrameAnalyzer {
  static const gridWidth = 320;
  static const gridHeight = 240;

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
    return FrameVerdict(ready: true, sharpness: edges / points / 2, motion: previous == null ? 0 : changes / points);
  }

  @override
  void reset() => _previous = null;
}
