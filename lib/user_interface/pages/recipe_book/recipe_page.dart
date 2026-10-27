import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/business_logic/rules/recipes/recipe_book.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/common_widgets/potion_vessel.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/laboratory/ready_view.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/recipe_vessel.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Una Tavola del Ricettario aperta: nome, ingredienti (sempre con il nome della pianta, il tratto quando lo chiede),
/// i mesi in cui si può fare e l'effetto.
class PlantRecipePage extends StatelessWidget {
  final String recipeId;

  const PlantRecipePage({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) => _RecipeScaffold(
    recipeId: recipeId,
    builder: (context, catalog, state) {
      final recipe = recipeBookOf(catalog).recipeById(recipeId)!;
      final missing = state.missingPieces[recipeId] ?? 0;
      final hidden = recipe.hiddenPieces(missing);
      final hiddenTraits = hidden.contains(NamePiece.secondTrait) ? {recipe.traits[1]} : const <Trait>{};
      return _RecipeCard(
        key: ValueKey('recipe-$recipeId'),
        grade: recipe.grade,
        vessel: RecipeVessel(recipe: recipe, size: 80, missing: missing),
        title: recipe.name(context.contentLanguage, missing: missing),
        subtitle: missing > 0 ? context.l10n.recipeMissingPieces(missing) : null,
        ingredients: [
          for (final i in recipe.ingredients)
            (speciesSci: i.speciesSci, quantity: i.quantity, traits: i.traits, hidden: hiddenTraits),
        ],
        months: recipe.months,
        effect: hidden.contains(NamePiece.effect)
            ? context.l10n.recipeEffectUnknown
            : context.game.effectText(recipe.effect),
        catalog: catalog,
      );
    },
  );
}

/// Una Mitica aperta: come una Tavola, con la sua storia e la finestra di date.
class MythicRecipePage extends StatelessWidget {
  final String mythicId;

  const MythicRecipePage({super.key, required this.mythicId});

  @override
  Widget build(BuildContext context) => _RecipeScaffold(
    recipeId: mythicId,
    builder: (context, catalog, state) {
      final lang = context.contentLanguage;
      final mythic = catalog.mythics.firstWhere((m) => m.id == mythicId);
      final missing = state.missingPieces[mythicId] ?? 0;
      String day(int month, int day) => DateFormat.MMMMd(lang).format(DateTime(2000, month, day));
      final window = mythic.window;
      return _RecipeCard(
        key: ValueKey('mythic-recipe-$mythicId'),
        grade: Grade.mythic,
        vessel: PotionVessel(
          shape: VesselShape.starred,
          liquids: [context.druid.gradeColor(Grade.mythic.index)],
          size: 80,
        ),
        title: mythic.name(lang, missing: missing),
        subtitle:
            '${context.l10n.mythicNumber(mythic.number.toString())} · '
            '${window == null ? context.l10n.mythicAllYear : context.l10n.mythicWindow(day(window.fromMonth, window.fromDay), day(window.toMonth, window.toDay))}'
            '${missing > 0 ? ' · ${context.l10n.recipeMissingPieces(missing)}' : ''}',
        story: mythic.story.resolve(lang),
        ingredients: [
          for (final i in mythic.ingredients)
            (speciesSci: i.speciesSci, quantity: i.quantity, traits: [?i.trait], hidden: const <Trait>{}),
        ],
        months: null,
        effect: mythic.effectText.resolve(lang),
        catalog: catalog,
      );
    },
  );
}

class _RecipeScaffold extends StatelessWidget {
  final String recipeId;
  final Widget Function(BuildContext context, Catalog catalog, GameState state) builder;

  const _RecipeScaffold({required this.recipeId, required this.builder});

  @override
  Widget build(BuildContext context) => DenseArea(
    child: Scaffold(
      appBar: clayAppBar(context, title: context.l10n.recipeBookTitle),
      extendBodyBehindAppBar: true,
      body: DruidBackground(
        belowAppBar: true,
        child: GameDataBuilder(
          builder: (context, catalog, state, progress) => ListView(
            padding: const EdgeInsets.all(Gaps.l),
            children: [
              builder(context, catalog, state),
              // Se la conosci completa: potenza migliore, cosa manca e Prepara.
              if (BrewSection.of(catalog, state, recipeId, progress.now) case final Widget brew) ...[
                const SizedBox(height: Gaps.m),
                ClayCard(child: brew),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

/// [hidden]: i tratti che non sai ancora (il secondo tratto di una Rara incompleta), mostrati come "?".
typedef _IngredientView = ({String? speciesSci, int quantity, List<Trait> traits, Set<Trait> hidden});

class _RecipeCard extends StatelessWidget {
  final Grade grade;
  final Widget vessel;
  final String title;
  final String? subtitle;
  final String? story;
  final List<_IngredientView> ingredients;

  /// Mesi (1-12) in cui si può fare; `null` per le Mitiche, che hanno la loro finestra di date.
  final List<int>? months;
  final String effect;
  final Catalog catalog;

  const _RecipeCard({
    super.key,
    required this.grade,
    required this.vessel,
    required this.title,
    this.subtitle,
    this.story,
    required this.ingredients,
    required this.months,
    required this.effect,
    required this.catalog,
  });

  @override
  Widget build(BuildContext context) {
    final hint = context.texts.bodySmall?.copyWith(color: context.druid.hint);
    return GradeCard(
      grade: grade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradeDot(grade: grade, label: context.game.grade(grade)),
              const Spacer(),
              vessel,
            ],
          ),
          const SizedBox(height: Gaps.s),
          Text(title, style: context.texts.titleLarge),
          if (subtitle != null) Text(subtitle!, style: hint),
          if (story != null) ...[const SizedBox(height: Gaps.s), Text(story!)],
          const SizedBox(height: Gaps.m),
          for (final ingredient in ingredients) _IngredientRow(ingredient: ingredient, catalog: catalog),
          if (months != null) ...[
            const SizedBox(height: Gaps.s),
            Text(context.l10n.recipeMonths, style: context.texts.labelMedium),
            const SizedBox(height: Gaps.xs),
            if (months!.isEmpty) Text(context.l10n.recipeNever, style: hint) else _MonthStrip(months: months!),
          ],
          const SizedBox(height: Gaps.m),
          Text(context.l10n.recipeEffect, style: context.texts.labelMedium),
          const SizedBox(height: Gaps.xs),
          Text(effect),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final _IngredientView ingredient;
  final Catalog catalog;

  const _IngredientRow({required this.ingredient, required this.catalog});

  @override
  Widget build(BuildContext context) {
    // Le piante hanno sempre nome e foto: gli ingredienti non si nascondono (decisione del 2026-10-23).
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
              for (final t in ingredient.traits) Pill(ingredient.hidden.contains(t) ? '?' : context.game.trait(t)),
            ],
          ),
          // Chi legge la ricetta scopre quando vale il tratto che chiede.
          for (final t in ingredient.traits)
            if (!ingredient.hidden.contains(t)) Text(context.game.traitWhen(t), style: context.texts.bodySmall),
        ],
      ),
    );
  }
}

/// I dodici mesi in fila: in evidenza quelli in cui la ricetta si può fare.
class _MonthStrip extends StatelessWidget {
  final List<int> months;

  const _MonthStrip({required this.months});

  @override
  Widget build(BuildContext context) {
    final lang = context.contentLanguage;
    return Wrap(
      key: const ValueKey('recipe-months'),
      spacing: Gaps.xs,
      runSpacing: Gaps.xs,
      children: [
        for (var m = 1; m <= 12; m++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.s, vertical: Gaps.xs),
            decoration: BoxDecoration(
              color: months.contains(m) ? context.druid.levelColor(4).withValues(alpha: 0.25) : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormat.MMM(lang).format(DateTime(2000, m)),
              style: context.texts.labelSmall?.copyWith(
                color: months.contains(m) ? context.colors.onSurface : context.druid.hint,
                fontWeight: months.contains(m) ? FontWeight.w600 : null,
              ),
            ),
          ),
      ],
    );
  }
}
