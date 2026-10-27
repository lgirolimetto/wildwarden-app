import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:get/get.dart';

/// Scheda scelta nella barra di navigazione: la cambiano sia la barra sia i pulsanti delle missioni.
class HomeController extends GetxController {
  static const studyTab = 0, erbarioTab = 1, albumTab = 2, settingsTab = 3;

  final ProgressController _progress;

  HomeController(this._progress);

  int tab = studyTab;

  Future<void> select(int index) async {
    tab = index;
    update();
    // Missioni dell'apprendistato: aprire l'erbario, poi l'album.
    if (index == erbarioTab) await _progress.markOnboarding(OnboardingMark.erbarioVisited);
    if (index == albumTab) await _progress.markOnboarding(OnboardingMark.albumVisited);
  }
}
