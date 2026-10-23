import 'package:druid_app/business_logic/models/recipe.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/mystery_cover.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/recipes/recipe_page.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Album delle ricette: una figurina per ricetta. Le imparate mostrano grado e nome; le mancanti un "?" su un pastello
/// sempre uguale per quella ricetta, con il grado, così si sa che cosa manca. Un tocco apre la figurina.
class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  /// Proporzioni di una figurina (larghezza / altezza).
  static const figurineAspect = 0.78;

  @override
  Widget build(BuildContext context) => DenseArea(
    paintBackground: true,
    child: GameDataBuilder(
      builder: (context, catalog, state, _) {
        final learned = catalog.recipes.where((r) => isRecipeUnlocked(r, state)).length;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(Gaps.l, MediaQuery.paddingOf(context).top + Gaps.l, Gaps.l, Gaps.l),
              sliver: SliverToBoxAdapter(
                child: ClayPageHeader(
                  title: context.l10n.recipesTitle,
                  icon: Icons.science_rounded,
                  iconColor: context.druid.levelColor(4),
                  trailing: Pill(
                    context.l10n.recipesCount(learned, catalog.recipes.length),
                    key: const ValueKey('recipes-count'),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(Gaps.l, Gaps.s, Gaps.l, homeBottomInset),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                childAspectRatio: figurineAspect,
                // Spazio perché il rilievo delle figurine non si sovrapponga.
                crossAxisSpacing: Gaps.l,
                mainAxisSpacing: Gaps.xl,
                children: [
                  for (final recipe in catalog.recipes)
                    _Figurine(recipe: recipe, learned: isRecipeUnlocked(recipe, state)),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _Figurine extends StatelessWidget {
  final Recipe recipe;
  final bool learned;

  const _Figurine({required this.recipe, required this.learned});

  @override
  Widget build(BuildContext context) {
    final dot = GradeDot(grade: recipe.grade, label: context.game.grade(recipe.grade));
    return GestureDetector(
      key: ValueKey('figurine-${recipe.id}'),
      onTap: () => Get.to<void>(() => RecipePage(recipeId: recipe.id)),
      child: GradeCard(
        grade: recipe.grade,
        padding: const EdgeInsets.all(Gaps.s),
        child: learned
            ? Padding(
                padding: const EdgeInsets.all(Gaps.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dot,
                    const Spacer(),
                    Text(
                      recipe.name.resolve(context.contentLanguage),
                      style: context.texts.titleMedium,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Gaps.xs),
                    Text(
                      context.l10n.recipeIngredientCount(recipe.ingredients.length),
                      style: context.texts.bodySmall?.copyWith(color: context.druid.hint),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  Positioned.fill(
                    child: MysteryCover(
                      seed: recipe.id,
                      borderRadius: BorderRadius.circular(context.druid.cardRadius - Gaps.s),
                    ),
                  ),
                  Positioned(left: Gaps.s, top: Gaps.s, child: dot),
                ],
              ),
      ),
    );
  }
}
