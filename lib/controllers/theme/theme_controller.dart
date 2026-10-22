import 'package:druid_app/business_logic/interfaces/i_preferences.dart';
import 'package:druid_app/user_interface/theme/app_theme.dart';
import 'package:druid_app/user_interface/theme/livery.dart';
import 'package:druid_app/user_interface/theme/livery_registry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Livrea e modalità chiaro/scuro scelte dall'utente, salvate nelle preferenze.
class ThemeController extends GetxController {
  static const liveryKey = 'theme.livery';
  static const modeKey = 'theme.mode';

  final IPreferences _preferences;

  ThemeController(this._preferences);

  late Livery livery;
  late ThemeMode mode;
  late ThemeData lightTheme;
  late ThemeData darkTheme;

  @override
  void onInit() {
    super.onInit();
    livery = LiveryRegistry.byId(_preferences.getString(liveryKey));
    mode = ThemeMode.values.asNameMap()[_preferences.getString(modeKey)] ?? ThemeMode.system;
    _rebuild();
  }

  Future<void> selectLivery(Livery value) async {
    livery = value;
    _rebuild();
    update();
    await _preferences.setString(liveryKey, value.id);
  }

  Future<void> selectMode(ThemeMode value) async {
    mode = value;
    update();
    await _preferences.setString(modeKey, value.name);
  }

  void _rebuild() {
    lightTheme = buildTheme(livery, Brightness.light);
    darkTheme = buildTheme(livery, Brightness.dark);
  }
}
