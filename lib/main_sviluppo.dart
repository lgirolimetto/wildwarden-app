import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/main_common.dart';
import 'package:druid_app/user_interface/perf_extensions.dart';

/// `flutter run -t lib/main_sviluppo.dart --dart-define-from-file=env/sviluppo.json`
Future<void> main() {
  registerPerfExtensions();
  return runDruidApp(AppConfig.fromEnvironment(flavor: 'sviluppo'));
}
