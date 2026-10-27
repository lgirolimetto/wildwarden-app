import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/rules/economy.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/brewing.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/engraved_icon.dart';
import 'package:druid_app/user_interface/common_widgets/potion_vessel.dart';
import 'package:druid_app/user_interface/common_widgets/species_name.dart';
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
                  child: RecipeNameText(
                    catalog: catalog,
                    state: state,
                    recipeId: brewable.id,
                    style: context.texts.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gaps.s),
            // L'effetto di gioco: il motivo per cui la prepari.
            Row(
              children: [
                EngravedIcon(effectIconOf(brewable.effect), size: 16),
                const SizedBox(width: Gaps.s),
                Expanded(child: Text(_effectText(context), style: context.texts.bodySmall)),
              ],
            ),
            // Le Vis che consuma (se è pronta; altrimenti BrewSection dice cosa manca).
            if (recipe.missing.isEmpty)
              for (final ingredient in brewable.ingredients) ...[
                const SizedBox(height: Gaps.xs),
                VisLine(
                  vis: ingredient.vis,
                  species: ingredient.speciesSci == null
                      ? freeSlotCandidates(brewable, state.essences)
                      : [ingredient.speciesSci!],
                  traits: ingredient.traits,
                  catalog: catalog,
                ),
              ],
            BrewSection(catalog: catalog, state: state, recipe: recipe),
          ],
        ),
      ),
    );
  }
}

extension on _ReadyCard {
  String _effectText(BuildContext context) {
    final id = recipe.brewable.id;
    for (final m in catalog.mythics) {
      if (m.id == id) return m.effectText.resolve(context.contentLanguage);
    }
    return context.game.effectText(recipe.brewable.effect);
  }
}

/// Una riga di Vis: "10 Vis · BORRAGINE COMUNE · Rugiada"; con più piante possibili (lo slot libero) le prime 3
/// separate da "|", poi "…". [prefix] sostituisce "10 Vis" (es. "Ti mancano 10 Vis di").
class VisLine extends StatelessWidget {
  final int vis;
  final List<String> species;
  final List<Trait> traits;
  final Catalog catalog;
  final String? prefix;

  const VisLine({
    super.key,
    required this.vis,
    required this.species,
    required this.traits,
    required this.catalog,
    this.prefix,
  });

  static const _shown = 3;

  @override
  Widget build(BuildContext context) {
    final base = context.texts.bodySmall;
    final names = [
      for (final sci in species.take(_shown))
        catalog.speciesBySci(sci) == null ? sci : context.game.name(catalog.speciesBySci(sci)!),
    ];
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${prefix ?? context.l10n.pantryVis(vis)} · '),
          if (names.isEmpty) TextSpan(text: context.l10n.readyAnyPlant),
          for (final (i, name) in names.indexed) ...[
            if (i > 0) const TextSpan(text: ' | '),
            TextSpan(text: name, style: speciesNameStyle(context, base)),
          ],
          if (species.length > _shown) const TextSpan(text: ' …'),
          for (final t in traits) TextSpan(text: ' · ${context.game.trait(t)}'),
        ],
      ),
      style: base,
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
          VisLine(
            vis: m.vis,
            species: [?m.ingredient.speciesSci],
            traits: m.ingredient.traits,
            catalog: catalog,
            prefix: context.l10n.readyMissingVis(m.vis),
          ),
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

  static String _day(BuildContext context, int month, int day) =>
      DateFormat.MMMMd(context.contentLanguage).format(DateTime(2000, month, day));
}
