import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/services/dependencies.dart';
import 'package:druid_app/business_logic/services/preferences/shared_preferences_store.dart';
import 'package:druid_app/user_interface/druid_app.dart';
import 'package:flutter/material.dart';

Future<void> runDruidApp(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  registerDependencies(config: config, preferences: await SharedPreferencesStore.create());
  runApp(const DruidApp());
}
