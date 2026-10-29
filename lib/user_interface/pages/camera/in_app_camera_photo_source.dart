import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/user_interface/pages/camera/camera_page.dart';
import 'package:get/get.dart';

/// La fotocamera dell'app (capitolo 07): apre il mirino e restituisce la foto scattata.
class InAppCameraPhotoSource implements IPhotoSource {
  const InAppCameraPhotoSource();

  @override
  Future<Validation<TakenPhoto>> takePhoto({bool single = false}) async =>
      Valid(await Get.to<TakenPhoto>(() => CameraPage(single: single)) ?? TakenPhoto.cancelled);
}
