import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/rules/economy.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/brewing.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/laboratory/brew_flow.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/recipe_identity.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Una ricetta che conosci, con ciò che le manca per prepararla adesso.
class ReadyRecipe {
  final Brewable brewable;

  /// Cosa manca (lo slot libero manca solo se nessuna pianta ha abbastanza Vis).
  final List<BrewShortfall> missing;
  final BrewBlock? block;

  const ReadyRecipe(this.brewable, this.missing, this.block);

  bool get ready => missing.isEmpty && block == null;
}

/// Le ricette che conosci, valutate con le Essenze della Dispensa.
List<ReadyRecipe> readyRecipes(Catalog catalog, GameState state, DateTime now) => [
  for (final brewable in knownBrewables(catalog, state))
    () {
      final plan = planBrew(brewable, state.essences);
      final freeOk = freeSlotCandidates(brewable, state.essences).isNotEmpty;
      return ReadyRecipe(brewable, [
        for (final m in plan.missing)
          if (m.ingredient.speciesSci != null || !freeOk) m,
      ], brewBlock(state, brewable, now));
    }(),
];

/// Ricette pronte, la terza linguetta del Laboratorio: quelle che puoi preparare adesso, poi quelle a cui manca un
/// solo ingrediente con che cosa manca ("la spinta a uscire"); le altre si contano soltanto.
class ReadyView extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final Widget header;

  const ReadyView({super.key, required this.catalog, required this.state, required this.header});

  @override
  Widget build(BuildContext context) {
    final now = Get.find<ProgressController>().now;
    final all = readyRecipes(catalog, state, now);
    final ready = all.where((r) => r.missing.isEmpty).toList();
    final almost = all.where((r) => r.missing.length == 1).toList();
    final others = all.length - ready.length - almost.length;
    final hint = context.texts.bodySmall?.copyWith(color: context.druid.hint);
    return ListView(
      key: const ValueKey('ready-recipes'),
      padding: EdgeInsets.fromLTRB(Gaps.l, MediaQuery.paddingOf(context).top + Gaps.l, Gaps.l, homeBottomInset),
      children: [
        header,
        const SizedBox(height: Gaps.l),
        if (all.isEmpty) Text(context.l10n.readyEmpty, key: const ValueKey('ready-empty'), style: hint),
        if (ready.isNotEmpty) ...[
          Text(context.l10n.readySection, style: context.texts.titleMedium),
          const SizedBox(height: Gaps.s),
          for (final r in ready) ...[
            _ReadyCard(catalog: catalog, state: state, recipe: r),
            const SizedBox(height: Gaps.m),
          ],
        ],
        if (almost.isNotEmpty) ...[
          const SizedBox(height: Gaps.s),
          Text(context.l10n.readyAlmost, style: context.texts.titleMedium),
          const SizedBox(height: Gaps.s),
          for (final r in almost) ...[
            _ReadyCard(catalog: catalog, state: state, recipe: r),
            const SizedBox(height: Gaps.m),
          ],
        ],
        if (others > 0) Text(context.l10n.readyOthers(others), style: hint),
      ],
    );
  }
}

class _ReadyCard extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final ReadyRecipe recipe;

  const _ReadyCard({required this.catalog, required this.state, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final brewable = recipe.brewable;
    return RepaintBoundary(
      child: GradeCard(
        key: ValueKey('ready-${brewable.id}'),
        grade: brewable.grade,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RecipeIdVessel(catalog: catalog, recipeId: brewable.id, size: 48),
                const SizedBox(width: Gaps.m),
                Expanded(
                  child: Text(recipeNameOf(context, catalog, state, brewable.id), style: context.texts.titleSmall),
                ),
              ],
            ),
            BrewSection(catalog: catalog, state: state, recipe: recipe),
          ],
        ),
      ),
    );
  }
}

/// Sotto una ricetta che conosci: la potenza migliore, cosa manca e il pulsante Prepara (o perché oggi no). Sta nelle
/// Ricette pronte e nella Tavola aperta.
class BrewSection extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final ReadyRecipe recipe;

  const BrewSection({super.key, required this.catalog, required this.state, required this.recipe});

  /// La sezione per la ricetta [recipeId], se la conosci completa; altrimenti niente.
  static Widget? of(Catalog catalog, GameState state, String recipeId, DateTime now) {
    final recipe = readyRecipes(catalog, state, now).where((r) => r.brewable.id == recipeId).firstOrNull;
    return recipe == null ? null : BrewSection(catalog: catalog, state: state, recipe: recipe);
  }

  @override
  Widget build(BuildContext context) {
    final hint = context.texts.bodySmall?.copyWith(color: context.druid.hint);
    final brewable = recipe.brewable;
    final window = brewable.window;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.bestPotency[brewable.id] case final int best) ...[
          const SizedBox(height: Gaps.xs),
          Text(context.l10n.recipeBestPotency(best), style: context.texts.labelLarge),
        ],
        for (final m in recipe.missing) ...[
          const SizedBox(height: Gaps.xs),
          Text(_missingText(context, m), style: hint),
        ],
        const SizedBox(height: Gaps.s),
        switch (recipe.block) {
          BrewBlock.outOfWindow when window != null => Text(
            context.l10n.mythicWindow(
              _day(context, window.fromMonth, window.fromDay),
              _day(context, window.toMonth, window.toDay),
            ),
            style: hint,
          ),
          BrewBlock.dailyLimit => Text(context.l10n.brewDailyLimit(EconomyRules.brewsPerDay), style: hint),
          _ when recipe.missing.isEmpty => ClayButton(
            key: ValueKey('brew-${brewable.id}'),
            label: context.l10n.brewButton,
            icon: Icons.science_rounded,
            onPressed: () => startBrew(context, catalog, state, brewable),
          ),
          _ => const SizedBox.shrink(),
        },
      ],
    );
  }

  String _missingText(BuildContext context, BrewShortfall m) {
    final sci = m.ingredient.speciesSci;
    final species = sci == null ? null : catalog.speciesBySci(sci);
    final name = sci == null ? context.l10n.readyAnyPlant : (species == null ? sci : context.game.name(species));
    return [context.l10n.readyMissing(m.vis, name), ...m.ingredient.traits.map(context.game.trait)].join(' · ');
  }

  static String _day(BuildContext context, int month, int day) =>
      DateFormat.MMMMd(context.contentLanguage).format(DateTime(2000, month, day));
}
