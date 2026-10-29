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
  Widget build(BuildContext context) => RecipeTitle(
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

/// Il nome di una ricetta con il nome della pianta nello stile delle specie e, al posto di ogni pezzo che manca
/// ([missingPiece]), una pillola "?" (capitolo 02, 2026-10-29: come la Qualia mancante nell'ingrediente).
class RecipeTitle extends StatelessWidget {
  final String text;
  final String? plant;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;

  const RecipeTitle(this.text, {super.key, required this.plant, this.style, this.maxLines, this.textAlign});

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final pieces = text.split(missingPiece);
    var plantDone = false;
    List<InlineSpan> segment(String part) {
      final at = plantDone || plant == null || plant!.isEmpty ? -1 : part.indexOf(plant!);
      if (at < 0) return [TextSpan(text: part)];
      plantDone = true;
      return [
        TextSpan(text: part.substring(0, at)),
        TextSpan(text: plant, style: speciesNameStyle(context, base)),
        TextSpan(text: part.substring(at + plant!.length)),
      ];
    }

    return Text.rich(
      TextSpan(
        children: [
          for (final (i, part) in pieces.indexed) ...[
            if (i > 0)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: _MissingMark(size: base.fontSize ?? 14),
              ),
            ...segment(part),
          ],
        ],
      ),
      style: base,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}

/// Il "?" di un pezzo che manca, in una pillola del colore degli indizi.
class _MissingMark extends StatelessWidget {
  final double size;

  const _MissingMark({required this.size});

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('missing-piece'),
    margin: const EdgeInsets.symmetric(horizontal: 2),
    padding: EdgeInsets.symmetric(horizontal: size * 0.45),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: context.druid.hint),
    ),
    child: Text(
      '?',
      style: TextStyle(fontSize: size * 0.8, fontWeight: FontWeight.w700, color: context.druid.hint, height: 1.3),
    ),
  );
}
