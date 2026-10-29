import 'package:druid_app/business_logic/interfaces/i_permissions.dart';
import 'package:druid_app/business_logic/interfaces/i_preferences.dart';
import 'package:druid_app/business_logic/rules/first_run.dart';
import 'package:get/get.dart';

/// Le pagine dell'onboarding di primo avvio, in ordine.
enum FirstRunStep { terms, camera, location, ready }

/// L'onboarding di primo avvio: regole, fotocamera, posizione, "Sei pronto a giocare". Un permesso negato non ferma
/// niente: la pagina spiega che cosa non funzionerà e dove riattivarlo.
class FirstRunController extends GetxController {
  final IPreferences _preferences;
  final IPermissions _permissions;

  FirstRunController(this._preferences, this._permissions);

  FirstRunStep step = FirstRunStep.terms;
  bool busy = false;

  /// Esito della richiesta della pagina corrente (null prima del tocco).
  PermissionOutcome? camera;
  PermissionOutcome? location;

  void _go(FirstRunStep next) {
    step = next;
    update();
  }

  Future<void> acceptTerms() async {
    await _preferences.setString(termsAcceptedKey, '$termsVersion');
    _go(FirstRunStep.camera);
  }

  Future<void> requestCamera() async {
    busy = true;
    update();
    camera = (await _permissions.requestCamera()).fold((_) => PermissionOutcome.denied, (o) => o);
    busy = false;
    camera == PermissionOutcome.granted ? _go(FirstRunStep.location) : update();
  }

  Future<void> requestLocation() async {
    busy = true;
    update();
    location = (await _permissions.requestLocation()).fold((_) => PermissionOutcome.denied, (o) => o);
    busy = false;
    location == PermissionOutcome.granted ? _go(FirstRunStep.ready) : update();
  }

  /// Avanti senza il permesso (negato o approssimativo).
  void skip() => _go(FirstRunStep.values[step.index + 1]);

  Future<void> openSettings() => _permissions.openAppSettings();

  /// Fine dell'onboarding (con il tutorial o "Più tardi").
  Future<void> finish() => _preferences.setString(firstRunDoneKey, '1');
}
