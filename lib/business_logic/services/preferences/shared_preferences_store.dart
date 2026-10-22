import 'package:druid_app/business_logic/interfaces/i_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesStore implements IPreferences {
  final SharedPreferences _preferences;

  SharedPreferencesStore(this._preferences);

  static Future<SharedPreferencesStore> create() async => SharedPreferencesStore(await SharedPreferences.getInstance());

  @override
  String? getString(String key) => _preferences.getString(key);

  @override
  Future<void> setString(String key, String value) => _preferences.setString(key, value);
}
