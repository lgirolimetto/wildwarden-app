import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:image_picker/image_picker.dart';

/// Fotocamera di sistema (`image_picker`): niente permesso CAMERA nell'app. La foto esce già ridotta a 1600 px,
/// JPEG 80 % (capitolo 05): è quella che resta sul telefono e che va a Pl@ntNet.
class SystemCameraPhotoSource implements IPhotoSource {
  static const maxSide = 1600.0;
  static const jpegQuality = 80;

  final ImagePicker _picker;

  SystemCameraPhotoSource({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  @override
  Future<Validation<TakenPhoto>> takePhoto() => _picker
      .pickImage(source: ImageSource.camera, maxWidth: maxSide, maxHeight: maxSide, imageQuality: jpegQuality)
      .then((file) => TakenPhoto(file?.path))
      .tryCatch();
}
