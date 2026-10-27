import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/user_interface/common_widgets/potion_vessel.dart';
import 'package:druid_app/user_interface/common_widgets/species_name.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/recipe_vessel.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/business_logic/rules/recipes/affixes.dart';
import 'package:flutter/material.dart';

/// Il nome di una Tavola o di una Mitica com'è adesso (parziale se mancano componenti), dal suo id.
String recipeNameOf(BuildContext context, Catalog catalog, GameState state, String id) {
  final lang = context.contentLanguage;
  final missing = state.missingPieces[id] ?? 0;
  for (final m in catalog.mythics) {
    if (m.id == id) return m.name(lang, missing: missing);
  }
  return recipeBookOf(catalog).recipeById(id)?.name(lang, missing: missing) ?? id;
}

/// Il nome della pianta di una Tavola, come compare nel suo nome; `null` per le Mitiche.
String? recipePlantNameOf(BuildContext context, Catalog catalog, String id) =>
    switch (recipeBookOf(catalog).recipeById(id)) {
      final recipe? => plantWord(recipe.plant.name.resolve(context.contentLanguage)),
      null => null,
    };

/// Il nome di una Tavola o di una Mitica, con il nome della pianta nello stile delle specie.
class RecipeNameText extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final String recipeId;
  final TextStyle? style;
  final TextAlign? textAlign;

  const RecipeNameText({
    super.key,
    required this.catalog,
    required this.state,
    required this.recipeId,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) => TextWithSpecies(
    recipeNameOf(context, catalog, state, recipeId),
    plant: recipePlantNameOf(context, catalog, recipeId),
    style: style,
    textAlign: textAlign,
  );
}

/// Il recipiente di una Tavola o di una Mitica, dal suo id; con [spoiled] il liquido è grigio (pozione guastata).
class RecipeIdVessel extends StatelessWidget {
  final Catalog catalog;
  final String recipeId;
  final double size;
  final bool spoiled;

  const RecipeIdVessel({
    super.key,
    required this.catalog,
    required this.recipeId,
    this.size = 56,
    this.spoiled = false,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = recipeBookOf(catalog).recipeById(recipeId);
    final spoiledLiquid = [context.druid.hint.withValues(alpha: 0.45)];
    if (recipe == null) {
      return PotionVessel(
        shape: VesselShape.starred,
        liquids: spoiled ? spoiledLiquid : [context.druid.gradeColor(Grade.mythic.index)],
        size: size,
      );
    }
    if (spoiled) return PotionVessel(shape: VesselShape.of(recipe.base), liquids: spoiledLiquid, size: size);
    return RecipeVessel(recipe: recipe, size: size);
  }
}
