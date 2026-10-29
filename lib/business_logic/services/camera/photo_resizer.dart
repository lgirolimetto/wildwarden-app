import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Lato lungo e qualità delle foto che restano sul telefono e vanno a Pl@ntNet (capitolo 05).
const photoMaxSide = 1600;
const photoJpegQuality = 80;

/// Riduce una foto JPEG: raddrizza secondo l'EXIF, porta il lato lungo a [maxSide] (mai ingrandisce) e la ricodifica.
/// Lenta su foto grandi: si chiama in un isolate (`Isolate.run`).
Uint8List resizeJpeg(Uint8List jpeg, {int maxSide = photoMaxSide, int quality = photoJpegQuality}) {
  img.Image? decoded;
  try {
    decoded = img.decodeJpg(jpeg);
  } on img.ImageException {
    decoded = null;
  }
  if (decoded == null) throw const FormatException('Foto non leggibile');
  final upright = img.bakeOrientation(decoded);
  final longSide = upright.width > upright.height ? upright.width : upright.height;
  final resized = longSide <= maxSide
      ? upright
      : upright.width >= upright.height
      ? img.copyResize(upright, width: maxSide, interpolation: img.Interpolation.average)
      : img.copyResize(upright, height: maxSide, interpolation: img.Interpolation.average);
  return img.encodeJpg(resized, quality: quality);
}

/// [resizeJpeg] in un isolate. Funzione a sé: la chiusura passata all'isolate deve portarsi dietro solo i byte (non
/// una pagina con i suoi timer, che non si possono spedire).
Future<Uint8List> resizeJpegInBackground(Uint8List jpeg) => Isolate.run(() => resizeJpeg(jpeg));
