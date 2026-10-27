import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/pages/laboratory/pantry_view.dart';
import 'package:druid_app/user_interface/pages/laboratory/ready_view.dart';
import 'package:druid_app/user_interface/pages/laboratory/shelf_view.dart';
import 'package:druid_app/user_interface/pages/recipe_book/recipe_book_page.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Il Laboratorio, una scheda della barra in basso (capitolo 02, decisione del 2026-10-27): il capanno dove si
/// lavora, con le linguette **Ricettario** (la collezione delle Tavole), **Dispensa** (le Essenze attinte), **Ricette
/// pronte** (cosa puoi preparare adesso) e **Scaffale** (le pozioni).
class LaboratoryPage extends StatefulWidget {
  const LaboratoryPage({super.key});

  @override
  State<LaboratoryPage> createState() => _LaboratoryPageState();
}

class _LaboratoryPageState extends State<LaboratoryPage> {
  /// 0 = Ricettario, 1 = Dispensa, 2 = Ricette pronte, 3 = Scaffale.
  var _tab = 0;

  @override
  Widget build(BuildContext context) => DenseArea(
    paintBackground: true,
    child: GameDataBuilder(
      builder: (context, catalog, state, _) {
        final essences = state.essences.where((e) => e.vis > 0).length;
        final now = Get.find<ProgressController>().now;
        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClayPageHeader(
              title: context.l10n.labTitle,
              icon: Icons.science_rounded,
              iconColor: context.druid.levelColor(4),
              trailing: switch (_tab) {
                0 => Pill(
                  context.l10n.recipeBookPlates(RecipeBookView.platesOf(catalog, state)),
                  key: const ValueKey('recipe-book-count'),
                ),
                1 => Pill(context.l10n.pantryEssences(essences), key: const ValueKey('pantry-count')),
                2 => Pill(
                  context.l10n.readyCount(readyRecipes(catalog, state, now).where((r) => r.ready).length),
                  key: const ValueKey('ready-count'),
                ),
                _ => Pill(
                  context.l10n.shelfCount(state.potions.where((p) => p.onShelf).length),
                  key: const ValueKey('shelf-count'),
                ),
              },
            ),
            ClayTabs(
              tabs: [
                ClayTab(key: const ValueKey('lab-tab-recipe-book'), label: context.l10n.recipeBookTitle),
                ClayTab(key: const ValueKey('lab-tab-pantry'), label: context.l10n.pantryTitle),
                ClayTab(key: const ValueKey('lab-tab-ready'), label: context.l10n.labTabReady),
                ClayTab(key: const ValueKey('lab-tab-shelf'), label: context.l10n.labTabShelf),
              ],
              scrollable: true,
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
          ],
        );
        return switch (_tab) {
          0 => RecipeBookView(catalog: catalog, state: state, header: header),
          1 => PantryView(catalog: catalog, state: state, header: header),
          2 => ReadyView(catalog: catalog, state: state, header: header),
          _ => ShelfView(catalog: catalog, state: state, header: header),
        };
      },
    ),
  );
}
