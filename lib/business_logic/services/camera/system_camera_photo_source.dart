import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/services/camera/photo_resizer.dart';
import 'package:image_picker/image_picker.dart';

/// Fotocamera di sistema (`image_picker`): resta solo per il confronto nella Prova sul campo, il gioco usa la
/// fotocamera dell'app (capitolo 07). La foto esce già ridotta (capitolo 05).
class SystemCameraPhotoSource implements IPhotoSource {
  final ImagePicker _picker;

  SystemCameraPhotoSource({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  @override
  Future<Validation<TakenPhoto>> takePhoto() => _picker
      .pickImage(
        source: ImageSource.camera,
        maxWidth: photoMaxSide.toDouble(),
        maxHeight: photoMaxSide.toDouble(),
        imageQuality: photoJpegQuality,
      )
      .then((file) => TakenPhoto(file?.path))
      .tryCatch();
}
