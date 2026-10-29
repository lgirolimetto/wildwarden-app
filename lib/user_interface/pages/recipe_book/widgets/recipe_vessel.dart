import 'package:druid_app/business_logic/rules/recipes/recipe_book.dart';
import 'package:druid_app/user_interface/common_widgets/potion_vessel.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Il recipiente di una Tavola: la forma della base, uno strato di liquido per tratto (le Comuni, senza tratti, un
/// verde d'erba). [empty]: solo il contorno. Con [missing] componenti da trovare il liquido è grigio: la Tavola non si
/// prepara ancora.
class RecipeVessel extends StatelessWidget {
  final PlantRecipe recipe;
  final double size;
  final bool empty;
  final int missing;

  const RecipeVessel({super.key, required this.recipe, this.size = 64, this.empty = false, this.missing = 0});

  @override
  Widget build(BuildContext context) {
    final secondHidden = recipe.hiddenPieces(missing).contains(NamePiece.secondTrait);
    return PotionVessel(
      key: ValueKey('vessel-${recipe.id}'),
      shape: VesselShape.of(recipe.base),
      liquids: empty
          ? const []
          : recipe.traits.isEmpty
          ? [missing > 0 ? context.druid.hint.withValues(alpha: 0.35) : context.druid.plainPotion ?? context.druid.hint]
          : [
              // Incompleta: tutto il liquido grigio, perché non si prepara (2026-10-29).
              for (final t in recipe.traits)
                missing > 0 ? context.druid.hint.withValues(alpha: 0.35) : context.druid.traitColor(t.index),
            ],
      size: size,
      semanticLabel: empty
          ? null
          : [
              recipe.base.word(context.contentLanguage),
              for (final (i, t) in recipe.traits.indexed) i == 1 && secondHidden ? '?' : context.game.trait(t),
            ].join(' · '),
    );
  }
}
