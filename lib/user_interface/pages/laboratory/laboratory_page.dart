import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/pages/laboratory/pantry_view.dart';
import 'package:druid_app/user_interface/pages/recipe_book/recipe_book_page.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Il Laboratorio, una scheda della barra in basso (capitolo 02, decisione del 2026-10-27): il capanno dove si
/// lavora, con le linguette **Ricettario** (la collezione delle Tavole) e **Dispensa** (le Essenze attinte); Ricette
/// pronte e Scaffale arrivano con gli step 8 e 9 della tappa C.
class LaboratoryPage extends StatefulWidget {
  const LaboratoryPage({super.key});

  @override
  State<LaboratoryPage> createState() => _LaboratoryPageState();
}

class _LaboratoryPageState extends State<LaboratoryPage> {
  /// 0 = Ricettario, 1 = Dispensa.
  var _tab = 0;

  @override
  Widget build(BuildContext context) => DenseArea(
    paintBackground: true,
    child: GameDataBuilder(
      builder: (context, catalog, state, _) {
        final essences = state.essences.where((e) => e.vis > 0).length;
        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClayPageHeader(
              title: context.l10n.labTitle,
              icon: Icons.science_rounded,
              iconColor: context.druid.levelColor(4),
              trailing: _tab == 0
                  ? Pill(
                      context.l10n.recipeBookPlates(RecipeBookView.platesOf(catalog, state)),
                      key: const ValueKey('recipe-book-count'),
                    )
                  : Pill(context.l10n.pantryEssences(essences), key: const ValueKey('pantry-count')),
            ),
            ClayTabs(
              tabs: [
                ClayTab(key: const ValueKey('lab-tab-recipe-book'), label: context.l10n.recipeBookTitle),
                ClayTab(key: const ValueKey('lab-tab-pantry'), label: context.l10n.pantryTitle),
              ],
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
          ],
        );
        return _tab == 0
            ? RecipeBookView(catalog: catalog, state: state, header: header)
            : PantryView(catalog: catalog, state: state, header: header);
      },
    ),
  );
}
