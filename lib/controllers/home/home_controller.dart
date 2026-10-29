import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:get/get.dart';

/// Scheda scelta nella barra di navigazione: la cambiano sia la barra sia i pulsanti del tutorial.
class HomeController extends GetxController {
  static const studyTab = 0, erbarioTab = 1, laboratoryTab = 2, troveTab = 3;

  final ProgressController _progress;

  HomeController(this._progress);

  int tab = studyTab;

  Future<void> select(int index) async {
    tab = index;
    update();
    if (index == troveTab) {
      // Il regalo "bentornato" si offre quando apri il Bottino: è lì che lo trovi. Aprirlo è anche un passo del tutorial.
      await _progress.offerWelcomeGiftIfDue();
      await _progress.markOnboarding(OnboardingMark.troveVisited);
    }
  }
}
