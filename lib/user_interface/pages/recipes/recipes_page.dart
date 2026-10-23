import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/recipe.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:flutter/material.dart';

/// Ricette: nome, grado, ingredienti (sempre con il nome della pianta) ed effetto. Pagina densa (`DenseArea`).
class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) => DenseArea(
    paintBackground: true,
    child: GameDataBuilder(
      builder: (context, catalog, state, _) => ListView(
        padding: EdgeInsets.fromLTRB(Gaps.l, MediaQuery.paddingOf(context).top + Gaps.l, Gaps.l, homeBottomInset),
        children: [
          ClayPageHeader(
            title: context.l10n.recipesTitle,
            icon: Icons.science_rounded,
            iconColor: context.druid.levelColor(4),
          ),
          const SizedBox(height: Gaps.l),
          for (final recipe in catalog.recipes) ...[
            _RecipeCard(recipe: recipe, catalog: catalog, state: state),
            const SizedBox(height: Gaps.m),
          ],
        ],
      ),
    ),
  );
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final Catalog catalog;
  final GameState state;

  const _RecipeCard({required this.recipe, required this.catalog, required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = context.contentLanguage;
    final unlocked = isRecipeUnlocked(recipe, state);
    final known = recipe.ingredients.where((i) => isIngredientKnown(i, state)).length;
    final unlockSpecies = recipe.unlock == null ? null : catalog.speciesBySci(recipe.unlock!.speciesSci);
    return GradeCard(
      key: ValueKey('recipe-${recipe.name.resolve('it')}'),
      grade: recipe.grade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Pill(context.game.grade(recipe.grade)),
              const SizedBox(width: Gaps.s),
              // Lo stato va a destra e, se lo spazio non basta (cornice del grado), si accorcia invece di sbordare.
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(unlocked ? Icons.lock_open : Icons.lock_outline, size: 18),
                    const SizedBox(width: Gaps.xs),
                    Flexible(
                      child: Text(
                        unlocked ? context.l10n.recipeUnlocked : context.l10n.recipeLocked,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Gaps.s),
          Text(recipe.name.resolve(lang), style: context.texts.titleLarge),
          if (recipe.grade == Grade.common && !unlocked)
            Text(
              context.l10n.recipeLearnByStudying(
                teachingSpecies(recipe).map(catalog.speciesBySci).nonNulls.map(context.game.name).join(', '),
              ),
              style: context.texts.bodySmall?.copyWith(color: context.druid.hint),
            )
          else if (recipe.grade != Grade.common && recipe.unlock != null && unlockSpecies != null)
            Text(
              '${context.l10n.studyLevelTitle(context.game.name(unlockSpecies), recipe.unlock!.level)} · '
              '${context.l10n.recipeCurrentLevel(state.levelOf(unlockSpecies.sci))}',
              style: context.texts.bodySmall?.copyWith(color: context.druid.hint),
            ),
          const SizedBox(height: Gaps.s),
          Text(context.l10n.recipeKnownIngredients(known, recipe.ingredients.length), style: context.texts.labelMedium),
          const SizedBox(height: Gaps.xs),
          for (final ingredient in recipe.ingredients)
            _IngredientRow(ingredient: ingredient, catalog: catalog, state: state),
          const SizedBox(height: Gaps.s),
          Text(recipe.effect.resolve(lang)),
        ],
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
    // Le piante hanno sempre nome e foto: gli ingredienti non si nascondono più (decisione del 2026-10-23).
    final species = ingredient.speciesSci == null ? null : catalog.speciesBySci(ingredient.speciesSci!);
    final name = species == null ? context.l10n.recipeAnySpecies : context.game.name(species);
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
              if (ingredient.trait != null) Pill(context.game.trait(ingredient.trait!)),
            ],
          ),
          Text(
            ingredient.note.resolve(context.contentLanguage),
            style: context.texts.bodySmall?.copyWith(color: context.druid.hint),
          ),
        ],
      ),
    );
  }
}
