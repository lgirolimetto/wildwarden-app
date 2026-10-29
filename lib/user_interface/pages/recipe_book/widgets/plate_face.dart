import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/mythic.dart';
import 'package:druid_app/business_logic/rules/recipes/recipe_book.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/potion_vessel.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/incomplete_info.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/ready_mark.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/recipe_identity.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/recipe_vessel.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/business_logic/rules/recipes/affixes.dart';
import 'package:flutter/material.dart';

/// Il contenuto di una Tavola che hai, nella pagina del Ricettario e all'apertura del Bottino: cerchietto, icona
/// dell'effetto, recipiente e nome. Con [missing] componenti da trovare il nome è parziale e l'effetto non si vede.
class PlateFace extends StatelessWidget {
  final PlantRecipe recipe;
  final int missing;

  /// Riga sotto il nome (es. cosa è uscito dal Bottino); `null` = i componenti che mancano, se mancano.
  final String? caption;

  /// Quante pozioni di questa Tavola prepari adesso: la beuta con il numero accanto al cerchietto (0 = niente).
  final int brews;

  const PlateFace({super.key, required this.recipe, this.missing = 0, this.caption, this.brews = 0});

  @override
  Widget build(BuildContext context) {
    final note = caption ?? (missing > 0 ? context.l10n.recipeMissingPieces(missing) : null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GradeDot(grade: recipe.grade, label: context.game.grade(recipe.grade)),
            if (brews > 0) ...[const SizedBox(width: Gaps.s), ReadyCount(count: brews)],
            const Spacer(),
            // L'effetto è nel nome ("…della Ricrescita"): niente icona che lo ripeta (2026-10-29).
            if (missing > 0) const IncompleteInfoButton(size: 18),
          ],
        ),
        Expanded(
          child: VesselSlot(
            builder: (size) => RecipeVessel(recipe: recipe, size: size, missing: missing),
          ),
        ),
        RecipeTitle(
          recipe.name(context.contentLanguage, missing: missing),
          plant: plantWord(recipe.plant.name.resolve(context.contentLanguage)),
          style: context.texts.titleMedium,
          maxLines: 4,
        ),
        if (note != null) ...[
          const SizedBox(height: Gaps.xs),
          Text(note, style: context.texts.bodySmall?.copyWith(color: context.druid.hint)),
        ],
      ],
    );
  }
}

/// Il contenuto di una Mitica che hai: numero, ampolla con le stelle e nome (a pezzi, se incompleta).
class MythicFace extends StatelessWidget {
  final Mythic mythic;
  final int missing;
  final String? caption;

  const MythicFace({super.key, required this.mythic, this.missing = 0, this.caption});

  @override
  Widget build(BuildContext context) {
    final note = caption ?? (missing > 0 ? context.l10n.recipeMissingPieces(missing) : null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GradeDot(grade: Grade.mythic, label: context.game.grade(Grade.mythic)),
            const SizedBox(width: Gaps.s),
            Text(context.l10n.mythicNumber(mythic.number.toString()), style: context.texts.labelLarge),
            const Spacer(),
            if (missing > 0) const IncompleteInfoButton(size: 18),
          ],
        ),
        Expanded(
          child: VesselSlot(
            builder: (size) => PotionVessel(
              shape: VesselShape.starred,
              liquids: [
                missing > 0 ? context.druid.hint.withValues(alpha: 0.35) : context.druid.gradeColor(Grade.mythic.index),
              ],
              size: size,
            ),
          ),
        ),
        RecipeTitle(
          mythic.name(context.contentLanguage, missing: missing),
          plant: null,
          style: context.texts.titleMedium,
          maxLines: 4,
        ),
        if (note != null) ...[
          const SizedBox(height: Gaps.xs),
          Text(note, style: context.texts.bodySmall?.copyWith(color: context.druid.hint)),
        ],
      ],
    );
  }
}

/// Il recipiente nello spazio libero della scheda, tra il cerchietto e il nome: grande quanto ci sta, fino a 88.
class VesselSlot extends StatelessWidget {
  final Widget Function(double size) builder;

  const VesselSlot({super.key, required this.builder});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Center(child: builder((constraints.maxHeight - Gaps.s).clamp(0.0, 88.0))),
  );
}
