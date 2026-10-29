import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/pages/laboratory/pantry_view.dart';
import 'package:druid_app/user_interface/pages/laboratory/shelf_view.dart';
import 'package:druid_app/user_interface/pages/recipe_book/recipe_book_page.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/business_logic/rules/tutorial.dart';
import 'package:flutter/material.dart';

/// Il Laboratorio, una scheda della barra in basso (capitolo 02, decisione del 2026-10-27): il capanno dove si
/// lavora, con le linguette **Ricettario** (la collezione delle Tavole, con il filtro delle preparabili), **Dispensa** (le
/// Essenze attinte) e **Scaffale** (le pozioni). Le Ricette pronte sono diventate il filtro (2026-10-29).
class LaboratoryPage extends StatefulWidget {
  const LaboratoryPage({super.key});

  @override
  State<LaboratoryPage> createState() => _LaboratoryPageState();
}

class _LaboratoryPageState extends State<LaboratoryPage> {
  /// 0 = Ricettario, 1 = Dispensa, 2 = Scaffale.
  var _tab = 0;

  /// Il filtro "Mostra solo preparabili" del Ricettario.
  var _onlyReady = false;

  @override
  Widget build(BuildContext context) => DenseArea(
    paintBackground: true,
    child: GameDataBuilder(
      builder: (context, catalog, state, _) {
        final essences = state.essences.where((e) => e.vis > 0).length;
        // Al passo della pozione del tutorial il Laboratorio mostra solo il Ricettario con le preparabili (si nasconde
        // il resto).
        final brewing = currentTutorialStep(state) == TutorialStep.brew;
        final tab = brewing ? 0 : _tab;
        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClayPageHeader(
              title: context.l10n.labTitle,
              icon: Icons.science_rounded,
              iconColor: context.druid.levelColor(4),
              trailing: switch (tab) {
                0 => Pill(
                  context.l10n.recipeBookPlates(RecipeBookView.platesOf(catalog, state)),
                  key: const ValueKey('recipe-book-count'),
                ),
                1 => Pill(context.l10n.pantryEssences(essences), key: const ValueKey('pantry-count')),
                _ => Pill(
                  context.l10n.shelfCount(state.potions.where((p) => p.onShelf).length),
                  key: const ValueKey('shelf-count'),
                ),
              },
            ),
            if (!brewing)
              ClayTabs(
                tabs: [
                  ClayTab(key: const ValueKey('lab-tab-recipe-book'), label: context.l10n.recipeBookTitle),
                  ClayTab(key: const ValueKey('lab-tab-pantry'), label: context.l10n.pantryTitle),
                  ClayTab(key: const ValueKey('lab-tab-shelf'), label: context.l10n.labTabShelf),
                ],
                selected: _tab,
                onChanged: (tab) => setState(() => _tab = tab),
              ),
          ],
        );
        return switch (tab) {
          0 => RecipeBookView(
            catalog: catalog,
            state: state,
            header: header,
            onlyReady: brewing || _onlyReady,
            onOnlyReadyChanged: brewing ? null : (value) => setState(() => _onlyReady = value),
          ),
          1 => PantryView(catalog: catalog, state: state, header: header),
          _ => ShelfView(catalog: catalog, state: state, header: header),
        };
      },
    ),
  );
}
