import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';

/// Scatto di una foto con la fotocamera.
abstract interface class IPhotoSource {
  Future<Validation<TakenPhoto>> takePhoto();
}

/// La foto scattata, o nessuna se chi gioca è tornato indietro senza scattare.
class TakenPhoto {
  final String? path;

  const TakenPhoto(this.path);

  static const cancelled = TakenPhoto(null);
}
