import 'package:druid_app/controllers/home/home_controller.dart';
import 'package:druid_app/controllers/theme/theme_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/status_bar_scrim.dart';
import 'package:druid_app/user_interface/pages/erbario/erbario_page.dart';
import 'package:druid_app/user_interface/pages/field/capture_page.dart';
import 'package:druid_app/user_interface/pages/laboratory/laboratory_page.dart';
import 'package:druid_app/user_interface/pages/study/study_home_page.dart';
import 'package:druid_app/user_interface/pages/trove/trove_page.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:get/get.dart';

/// Contenitore con la barra di navigazione in basso. La scheda scelta sta in [HomeController].
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _pages = [StudyHomePage(), ErbarioPage(), LaboratoryPage(), TrovePage()];

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
          // Sotto la barra di stato il contenuto che scorre sfuma nello sfondo, invece di finire sotto l'orologio. Nella
          // Home lo fa la pagina stessa, solo quando il cielo del diorama è uscito dallo schermo.
          if (index != HomeController.studyTab) StatusBarScrim(color: _fadeColor(context, index)),
        ],
      ),
    ),
    bottomNavigationBar: ClayNavBar(
      selectedIndex: index,
      onSelected: select,
      action: (
        icon: Icons.photo_camera_rounded,
        label: context.l10n.captureAction,
        onPressed: () => Get.to<void>(() => const CapturePage()),
      ),
      items: [
        (Icons.home_rounded, context.l10n.navStudy),
        (Icons.menu_book_rounded, context.l10n.navErbario),
        (Icons.science_rounded, context.l10n.navLaboratory),
        (Symbols.garden_cart_rounded, context.l10n.navTrove),
      ],
    ),
  );

  /// Colore in cui sfuma il contenuto sotto la barra di stato: quello dello sfondo della scheda, che nelle pagine dense
  /// (`DenseArea`) può essere diverso.
  static Color _fadeColor(BuildContext context, int tab) {
    final dense = tab == HomeController.laboratoryTab || tab == HomeController.troveTab;
    final denseTheme = dense ? Get.find<ThemeController>().denseTheme(Theme.of(context).brightness) : null;
    return denseTheme?.colorScheme.surface ?? context.druid.backgroundGradient.first;
  }
}
