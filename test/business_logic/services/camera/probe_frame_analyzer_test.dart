import 'dart:typed_data';

import 'package:druid_app/business_logic/interfaces/i_frame_analyzer.dart';
import 'package:druid_app/business_logic/services/camera/probe_frame_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Fotogramma 640×480 con una riga in più di padding, come quelli delle fotocamere.
  CameraFrame frame(int Function(int x, int y) luma) {
    const width = 640, height = 480, bytesPerRow = 704;
    final bytes = Uint8List(bytesPerRow * height);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        bytes[y * bytesPerRow + x] = luma(x, y);
      }
    }
    return CameraFrame(width: width, height: height, bytesPerRow: bytesPerRow, luma: bytes);
  }

  test('indizio provvisorio dal movimento: fermo no, mosso piano sì, mosso troppo no', () {
    expect(ProbeFrameAnalyzer.evidenceOf(2), 0);
    expect(ProbeFrameAnalyzer.evidenceOf(8), 0, reason: 'il tremito della mano non conta');
    expect(ProbeFrameAnalyzer.evidenceOf(14.5), closeTo(0.5, 0.01));
    expect(ProbeFrameAnalyzer.evidenceOf(30), 1);
    expect(ProbeFrameAnalyzer.evidenceOf(60), 0);
    expect(ProbeFrameAnalyzer().analyze(frame((x, y) => 128)).evidence, 0);
  });

  test('nitidezza: zero su un grigio uniforme, alta su una scacchiera', () {
    final analyzer = ProbeFrameAnalyzer();
    expect(analyzer.analyze(frame((x, y) => 128)).sharpness, 0);
    expect(analyzer.analyze(frame((x, y) => (x ~/ 2 + y ~/ 2).isEven ? 0 : 255)).sharpness, greaterThan(100));
  });

  test('movimento: zero sul primo fotogramma e con l\'immagine ferma, più alto se cambia', () {
    final analyzer = ProbeFrameAnalyzer();
    final still = frame((x, y) => x % 256);
    expect(analyzer.analyze(still).motion, 0);
    expect(analyzer.analyze(still).motion, 0);
    expect(analyzer.analyze(frame((x, y) => (x + 40) % 256)).motion, greaterThan(10));
    analyzer.reset();
    expect(analyzer.analyze(still).motion, 0);
  });
}
