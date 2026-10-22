import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/recipe.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/user_interface/common_widgets/accent_card.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:flutter/material.dart';

/// Ricette: nome ed effetto si vedono subito; gli ingredienti di specie non ancora incontrate restano "???"
/// con un indizio, così si sa sempre cosa cercare.
class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) => GameDataBuilder(
    builder: (context, catalog, state, _) => ListView(
      padding: EdgeInsets.fromLTRB(Gaps.l, MediaQuery.paddingOf(context).top + Gaps.l, Gaps.l, homeBottomInset),
      children: [
        ClayPageHeader(
          title: context.l10n.recipesTitle,
          icon: Icons.science_rounded,
          iconColor: context.druid.levelColor(4),
        ),
        const SizedBox(height: Gaps.l),
        for (final (i, recipe) in catalog.recipes.indexed) ...[
          _RecipeCard(index: i, recipe: recipe, catalog: catalog, state: state),
          const SizedBox(height: Gaps.m),
        ],
      ],
    ),
  );
}

class _RecipeCard extends StatelessWidget {
  final int index;
  final Recipe recipe;
  final Catalog catalog;
  final GameState state;

  const _RecipeCard({required this.index, required this.recipe, required this.catalog, required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = context.contentLanguage;
    final unlocked = isRecipeUnlocked(recipe, state);
    final known = recipe.ingredients.where((i) => isIngredientKnown(i, state)).length;
    final unlockSpecies = recipe.unlock == null ? null : catalog.speciesBySci(recipe.unlock!.speciesSci);
    return AccentCardBox(
      key: ValueKey('recipe-${recipe.name.resolve('it')}'),
      index: index,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(Gaps.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Pill(recipe.tier),
                const Spacer(),
                Icon(unlocked ? Icons.lock_open : Icons.lock_outline, size: 18),
                const SizedBox(width: Gaps.xs),
                Text(unlocked ? context.l10n.recipeUnlocked : context.l10n.recipeLocked),
              ],
            ),
            const SizedBox(height: Gaps.s),
            Text(recipe.name.resolve(lang), style: context.texts.titleLarge),
            if (recipe.unlock != null && unlockSpecies != null)
              Text(
                '${context.l10n.studyLevelTitle(state.hasEncountered(unlockSpecies.sci) ? context.game.name(unlockSpecies) : context.l10n.unknownSpecies, recipe.unlock!.level)} · '
                '${context.l10n.recipeCurrentLevel(state.levelOf(unlockSpecies.sci))}',
                style: context.texts.bodySmall?.copyWith(color: context.druid.hint),
              ),
            const SizedBox(height: Gaps.s),
            Text(
              context.l10n.recipeKnownIngredients(known, recipe.ingredients.length),
              style: context.texts.labelMedium,
            ),
            const SizedBox(height: Gaps.xs),
            for (final ingredient in recipe.ingredients)
              _IngredientRow(ingredient: ingredient, catalog: catalog, state: state),
            const SizedBox(height: Gaps.s),
            Text(recipe.effect.resolve(lang)),
          ],
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final Ingredient ingredient;
  final Catalog catalog;
  final GameState state;

  const _IngredientRow({required this.ingredient, required this.catalog, required this.state});

  @override
  Widget build(BuildContext context) {
    final species = ingredient.speciesSci == null ? null : catalog.speciesBySci(ingredient.speciesSci!);
    final known = isIngredientKnown(ingredient, state);
    final name = species == null
        ? context.l10n.recipeAnySpecies
        : known
        ? context.game.name(species)
        : context.l10n.recipeUnknownIngredient;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gaps.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Gaps.chip,
            runSpacing: Gaps.chipRun,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${ingredient.quantity} × $name', style: context.texts.bodyLarge),
              if (ingredient.trait != null) Pill(ingredient.trait!),
            ],
          ),
          Text(
            known || species == null
                ? ingredient.note.resolve(context.contentLanguage)
                : context.l10n.recipeHint(context.game.hint(species)),
            style: context.texts.bodySmall?.copyWith(color: context.druid.hint),
          ),
        ],
      ),
    );
  }
}
