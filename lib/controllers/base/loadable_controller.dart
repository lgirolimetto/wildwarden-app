import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Base per i controller che caricano un dato che può fallire (stesso schema del `BaseController` di
/// campus-app): il risultato sta sempre in una `Validation`, la UI lo legge con `ValidationView`.
abstract class LoadableController<T> extends GetxController {
  Validation<T> uiData = StateError('Dato ancora non richiesto').toInvalid();
  bool loading = false;

  Future<void> load() async {
    loading = true;
    update();
    uiData = await fetch();
    loading = false;
    update();
  }

  @protected
  Future<Validation<T>> fetch();
}
