import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/brewing.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/species_name.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/laboratory/brew_flow.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

/// Sotto una ricetta che conosci, nella Tavola aperta: la potenza migliore, cosa manca e il pulsante Prepara (o perché
/// oggi no).
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
