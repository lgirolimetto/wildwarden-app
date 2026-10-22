import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Crea i widget delle immagini remote. È un servizio iniettato perché nei test le immagini
/// non devono andare in rete: si registra una factory finta.
abstract interface class RemoteImageFactory {
  Widget build(BuildContext context, String url, {BoxFit fit});
}

/// Immagini con cache su disco: nel campo la rete può mancare.
class CachedRemoteImageFactory implements RemoteImageFactory {
  const CachedRemoteImageFactory();

  @override
  Widget build(BuildContext context, String url, {BoxFit fit = BoxFit.cover}) => CachedNetworkImage(
    imageUrl: url,
    fit: fit,
    placeholder: (context, _) => const ColoredBox(color: Colors.transparent),
    errorWidget: (context, _, _) => const Center(child: Icon(Icons.local_florist_outlined)),
  );
}

class RemoteImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const RemoteImage(this.url, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) => Get.find<RemoteImageFactory>().build(context, url, fit: fit);
}
