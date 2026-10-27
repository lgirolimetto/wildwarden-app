import 'package:druid_app/business_logic/rules/recipes/recipe_book.dart';
import 'package:druid_app/user_interface/common_widgets/potion_vessel.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Il recipiente di una Tavola: la forma della base, uno strato di liquido per tratto (le Comuni, senza tratti, un
/// verde d'erba). [empty]: solo il contorno.
class RecipeVessel extends StatelessWidget {
  final PlantRecipe recipe;
  final double size;
  final bool empty;

  const RecipeVessel({super.key, required this.recipe, this.size = 64, this.empty = false});

  @override
  Widget build(BuildContext context) => PotionVessel(
    key: ValueKey('vessel-${recipe.id}'),
    shape: VesselShape.of(recipe.base),
    liquids: empty
        ? const []
        : recipe.traits.isEmpty
        ? [context.druid.plainPotion ?? context.druid.hint]
        : [for (final t in recipe.traits) context.druid.traitColor(t.index)],
    size: size,
    semanticLabel: empty
        ? null
        : [recipe.base.word(context.contentLanguage), ...recipe.traits.map(context.game.trait)].join(' · '),
  );
}
