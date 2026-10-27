import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/game_texts.dart';
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
    builder: (context, catalog) {
      final recipe = recipeBookOf(catalog).recipeById(recipeId)!;
      return _RecipeCard(
        key: ValueKey('recipe-$recipeId'),
        grade: recipe.grade,
        title: recipe.name(context.contentLanguage),
        ingredients: [
          for (final i in recipe.ingredients) (speciesSci: i.speciesSci, quantity: i.quantity, traits: i.traits),
        ],
        months: recipe.months,
        effect: context.game.effectText(recipe.effect),
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
    builder: (context, catalog) {
      final lang = context.contentLanguage;
      final mythic = catalog.mythics.firstWhere((m) => m.id == mythicId);
      String day(int month, int day) => DateFormat.MMMMd(lang).format(DateTime(2000, month, day));
      final window = mythic.window;
      return _RecipeCard(
        key: ValueKey('mythic-recipe-$mythicId'),
        grade: Grade.mythic,
        title: mythic.name(lang),
        subtitle:
            '${context.l10n.mythicNumber(mythic.number.toString())} · '
            '${window == null ? context.l10n.mythicAllYear : context.l10n.mythicWindow(day(window.fromMonth, window.fromDay), day(window.toMonth, window.toDay))}',
        story: mythic.story.resolve(lang),
        ingredients: [
          for (final i in mythic.ingredients) (speciesSci: i.speciesSci, quantity: i.quantity, traits: [?i.trait]),
        ],
        months: null,
        effect: mythic.effectText.resolve(lang),
        catalog: catalog,
      );
    },
  );
}

class _RecipeScaffold extends StatelessWidget {
  final Widget Function(BuildContext context, Catalog catalog) builder;

  const _RecipeScaffold({required this.builder});

  @override
  Widget build(BuildContext context) => DenseArea(
    child: Scaffold(
      appBar: clayAppBar(context, title: context.l10n.recipeBookTitle),
      extendBodyBehindAppBar: true,
      body: DruidBackground(
        belowAppBar: true,
        child: GameDataBuilder(
          builder: (context, catalog, state, _) =>
              ListView(padding: const EdgeInsets.all(Gaps.l), children: [builder(context, catalog)]),
        ),
      ),
    ),
  );
}

typedef _IngredientView = ({String? speciesSci, int quantity, List<Trait> traits});

class _RecipeCard extends StatelessWidget {
  final Grade grade;
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
          GradeDot(grade: grade, label: context.game.grade(grade)),
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
              for (final t in ingredient.traits) Pill(context.game.trait(t)),
            ],
          ),
          // Chi legge la ricetta scopre quando vale il tratto che chiede.
          for (final t in ingredient.traits) Text(context.game.traitWhen(t), style: context.texts.bodySmall),
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
