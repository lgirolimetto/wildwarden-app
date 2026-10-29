import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';

/// Apre un link nel browser: le fonti delle informazioni (capitolo 04, "sempre con le fonti").
abstract interface class ILinkOpener {
  Future<Validation<bool>> open(String url);
}
