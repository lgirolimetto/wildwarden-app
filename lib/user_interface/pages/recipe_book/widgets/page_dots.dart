import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Le Tavole di una pagina in cerchietti, nell'ordine della pagina: pieni quelli che hai, vuoti quelli che mancano.
/// A colpo d'occhio si vede cosa manca ("mi manca la Rara del Bagolaro").
class PageDots extends StatelessWidget {
  final CollectedPage collected;

  const PageDots({super.key, required this.collected});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Gaps.xs,
    runSpacing: Gaps.xs,
    children: [
      for (final recipe in collected.page.recipes)
        GradeDot(
          grade: recipe.grade,
          label: collected.knows(recipe) ? context.game.grade(recipe.grade) : context.l10n.recipeBookMissingPlate,
          filled: collected.knows(recipe),
        ),
    ],
  );
}
