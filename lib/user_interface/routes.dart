import 'package:druid_app/user_interface/pages/first_run/first_run_page.dart';
import 'package:druid_app/user_interface/pages/home/home_page.dart';
import 'package:get/get.dart';

abstract final class Routes {
  static const home = '/';

  /// Onboarding di primo avvio: regole, permessi, "Sei pronto a giocare".
  static const firstRun = '/benvenuto';
}

final appPages = [
  GetPage(name: Routes.home, page: () => const HomePage()),
  GetPage(name: Routes.firstRun, page: () => const FirstRunPage()),
];
