import 'dart:typed_data';

/// Un fotogramma dello streaming della fotocamera: solo la luminanza (piano Y del formato YUV), che basta per
/// riconoscere forme e movimento. Resta in memoria e si butta: niente si registra (capitolo 05).
class CameraFrame {
  final int width;
  final int height;
  final int bytesPerRow;
  final Uint8List luma;

  const CameraFrame({required this.width, required this.height, required this.bytesPerRow, required this.luma});
}

/// Che cosa dice l'analisi di un fotogramma.
class FrameVerdict {
  /// Quanto questo fotogramma dice che davanti c'è una pianta vera (0–1): riempie l'anello della raccolta della Vis
  /// (`rules/field/vis_gathering.dart`). Nel blocco 5: parallasse, profondità, niente testo né schermi.
  final double evidence;

  /// Nitidezza (energia dei contorni) e movimento rispetto al fotogramma precedente, 0–255: misure di prova.
  final double sharpness;
  final double motion;

  const FrameVerdict({required this.evidence, this.sharpness = 0, this.motion = 0});

  static const none = FrameVerdict(evidence: 0);
}

/// Analisi dello streaming mentre si inquadra. Nel blocco 2 una prova che conta come indizio il movimento del telefono
/// e misura quanto costa guardare i fotogrammi; nel blocco 5 la verifica della pianta vera (parallasse, profondità,
/// testo nella scena).
abstract interface class IFrameAnalyzer {
  FrameVerdict analyze(CameraFrame frame);

  /// Si ricomincia da capo (fotocamera riaperta).
  void reset();
}
