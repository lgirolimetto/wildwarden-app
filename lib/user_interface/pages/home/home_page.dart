import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/pages/erbario/erbario_page.dart';
import 'package:druid_app/user_interface/pages/recipes/recipes_page.dart';
import 'package:druid_app/user_interface/pages/settings/settings_page.dart';
import 'package:druid_app/user_interface/pages/study/study_home_page.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Contenitore con la barra di navigazione in basso.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const studyTab = 0, erbarioTab = 1, recipesTab = 2, settingsTab = 3;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = HomePage.studyTab;

  static const _pages = [StudyHomePage(), ErbarioPage(), RecipesPage(), SettingsPage()];

  void _select(int index) {
    setState(() => _index = index);
    // Prima missione dell'apprendistato: aprire l'erbario.
    if (index == HomePage.erbarioTab) Get.find<ProgressController>().markOnboarding(OnboardingMark.erbarioVisited);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    // La barra galleggia sopra il contenuto: le pagine lasciano spazio in fondo (`homeBottomInset`).
    extendBody: true,
    // Niente SafeArea in alto: la pagina Studio fa arrivare il diorama sotto la barra di stato, le altre la
    // gestiscono da sé.
    body: DruidBackground(
      child: Stack(
        children: [
          IndexedStack(index: _index, children: _pages),
          // Sotto la barra di stato il contenuto che scorre sfuma nello sfondo, invece di finire sotto l'orologio.
          // Non sullo Studio: lì in alto c'è il cielo del diorama.
          if (_index != HomePage.studyTab)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: MediaQuery.paddingOf(context).top + Gaps.l,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.druid.backgroundGradient.first,
                        context.druid.backgroundGradient.first.withValues(alpha: 0.85),
                        context.druid.backgroundGradient.first.withValues(alpha: 0),
                      ],
                      stops: const [0, 0.6, 1],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    bottomNavigationBar: ClayNavBar(
      selectedIndex: _index,
      onSelected: _select,
      items: [
        (Icons.school_rounded, context.l10n.navStudy),
        (Icons.menu_book_rounded, context.l10n.navErbario),
        (Icons.science_rounded, context.l10n.navRecipes),
        (Icons.tune_rounded, context.l10n.navSettings),
      ],
    ),
  );
}
