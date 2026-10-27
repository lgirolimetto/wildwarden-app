import 'package:druid_app/business_logic/rules/recipes/album.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Le figurine di una pagina in cerchietti, nell'ordine della pagina: pieni quelli che hai, vuoti quelli che mancano.
/// A colpo d'occhio si vede cosa manca ("mi manca la Rara del Bagolaro").
class PageDots extends StatelessWidget {
  final AlbumEntry album;

  const PageDots({super.key, required this.album});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Gaps.xs,
    runSpacing: Gaps.xs,
    children: [
      for (final recipe in album.page.recipes)
        GradeDot(
          grade: recipe.grade,
          label: album.knows(recipe) ? context.game.grade(recipe.grade) : context.l10n.albumMissingFigurine,
          filled: album.knows(recipe),
        ),
    ],
  );
}
