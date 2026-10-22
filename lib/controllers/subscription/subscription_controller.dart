import 'package:druid_app/business_logic/interfaces/i_preferences.dart';
import 'package:get/get.dart';

/// Abbonamento al Diario dell'Erborista. Nel prototipo è un interruttore simulato negli strumenti di debug;
/// con gli acquisti in-app la stessa interfaccia leggerà lo stato dell'abbonamento verificato dal server.
class SubscriptionController extends GetxController {
  static const simulatedKey = 'debug.diarioActive';

  final IPreferences _preferences;

  SubscriptionController(this._preferences);

  bool get diarioActive => _preferences.getString(simulatedKey) == 'true';

  Future<void> setSimulated(bool active) async {
    await _preferences.setString(simulatedKey, '$active');
    update();
  }
}
