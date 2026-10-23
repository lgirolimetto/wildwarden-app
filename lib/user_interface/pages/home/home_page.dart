import 'package:druid_app/controllers/home/home_controller.dart';
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

/// Contenitore con la barra di navigazione in basso. La scheda scelta sta in [HomeController].
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _pages = [StudyHomePage(), ErbarioPage(), RecipesPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) =>
      GetBuilder<HomeController>(builder: (home) => _scaffold(context, home.tab, home.select));

  Widget _scaffold(BuildContext context, int index, void Function(int) select) => Scaffold(
    // La barra galleggia sopra il contenuto: le pagine lasciano spazio in fondo (`homeBottomInset`).
    extendBody: true,
    // Niente SafeArea in alto: la pagina Studio fa arrivare il diorama sotto la barra di stato, le altre la
    // gestiscono da sé.
    body: DruidBackground(
      child: Stack(
        children: [
          IndexedStack(index: index, children: _pages),
          // Sotto la barra di stato il contenuto che scorre sfuma nello sfondo, invece di finire sotto l'orologio.
          // Non sullo Studio: lì in alto c'è il cielo del diorama.
          if (index != HomeController.studyTab)
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
      selectedIndex: index,
      onSelected: select,
      items: [
        (Icons.school_rounded, context.l10n.navStudy),
        (Icons.menu_book_rounded, context.l10n.navErbario),
        (Icons.science_rounded, context.l10n.navRecipes),
        (Icons.tune_rounded, context.l10n.navSettings),
      ],
    ),
  );
}
