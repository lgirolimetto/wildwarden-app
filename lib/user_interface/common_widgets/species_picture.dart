import 'package:druid_app/business_logic/interfaces/i_photo_store.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Una tua foto salvata sul telefono: [photo] è il percorso degli eventi, relativo alla cartella dei documenti.
class OwnPhoto extends StatelessWidget {
  final String photo;
  final BoxFit fit;

  const OwnPhoto(this.photo, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) =>
      Get.find<RemoteImageFactory>().buildFile(context, Get.find<IPhotoStore>().absolute(photo), fit: fit);
}

/// La foto di una specie: la tua se l'hai fotografata ([photo], quella della prima Stazione: `firstPhotoOf`), se no la
/// prima del catalogo (capitolo 02, "L'incontro è una figurina con il timbro").
class SpeciesPicture extends StatelessWidget {
  final Species species;
  final String? photo;
  final BoxFit fit;

  const SpeciesPicture(this.species, {super.key, this.photo, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) => photo != null
      ? OwnPhoto(photo!, fit: fit)
      : species.images.isEmpty
      ? const SizedBox.shrink()
      : RemoteImage(species.images.first.url, fit: fit);
}
