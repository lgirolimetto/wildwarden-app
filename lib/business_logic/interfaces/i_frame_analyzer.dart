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

/// Che cosa dice l'analisi dell'inquadratura.
class FrameVerdict {
  /// Si può scattare (nel blocco 5: è una pianta vera, non una foto o uno schermo).
  final bool ready;

  /// Nitidezza (energia dei contorni) e movimento rispetto al fotogramma precedente, 0–255: misure di prova.
  final double sharpness;
  final double motion;

  const FrameVerdict({required this.ready, this.sharpness = 0, this.motion = 0});

  static const waiting = FrameVerdict(ready: false);
}

/// Analisi dello streaming mentre si inquadra. Nel blocco 2 una prova che dice sempre "pronto" e misura quanto costa
/// guardare i fotogrammi; nel blocco 5 la verifica della pianta vera (parallasse, profondità, testo nella scena).
abstract interface class IFrameAnalyzer {
  FrameVerdict analyze(CameraFrame frame);

  /// Si ricomincia da capo (fotocamera riaperta).
  void reset();
}
