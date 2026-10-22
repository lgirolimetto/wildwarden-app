import 'package:druid_app/user_interface/pages/home/home_page.dart';
import 'package:get/get.dart';

abstract final class Routes {
  static const home = '/';
}

final appPages = [GetPage(name: Routes.home, page: () => const HomePage())];
