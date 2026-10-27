import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/economy.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/affixes.dart';
import 'package:druid_app/business_logic/rules/recipes/brewing.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/recipe_identity.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Prepara [brewable]: se ha lo slot libero chiede prima la pianta (che dà il Tocco), poi apre la pozione appena fatta.
Future<void> startBrew(BuildContext context, Catalog catalog, GameState state, Brewable brewable) async {
  final progress = Get.find<ProgressController>();
  String? freeSpecies;
  if (brewable.freeSlot != null) {
    freeSpecies = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _FreeSlotSheet(catalog: catalog, state: state, brewable: brewable),
    );
    if (freeSpecies == null) return;
  }
  final event = await progress.brew(brewable.id, freeSpecies: freeSpecies);
  if (event == null) return;
  await Get.to<void>(() => PotionResultPage(event: event, firstBrew: !state.bestPotency.containsKey(brewable.id)));
}

/// La scelta della pianta per lo slot libero: quelle con abbastanza Vis. Le tossiche non si segnalano: è così che si
/// impara (la pozione guastata).
class _FreeSlotSheet extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final Brewable brewable;

  const _FreeSlotSheet({required this.catalog, required this.state, required this.brewable});

  @override
  Widget build(BuildContext context) {
    final vis = state.vis;
    return SafeArea(
      child: ListView(
        key: const ValueKey('free-slot-sheet'),
        shrinkWrap: true,
        padding: const EdgeInsets.all(Gaps.l),
        children: [
          Text(context.l10n.brewChooseFree, style: context.texts.titleMedium),
          Text(context.l10n.brewChooseFreeHint, style: context.texts.bodySmall?.copyWith(color: context.druid.hint)),
          const SizedBox(height: Gaps.s),
          for (final sci in freeSlotCandidates(brewable, state.essences))
            ListTile(
              key: ValueKey('free-slot-$sci'),
              contentPadding: EdgeInsets.zero,
              title: Text(catalog.speciesBySci(sci) == null ? sci : context.game.name(catalog.speciesBySci(sci)!)),
              trailing: Text(context.l10n.brewFreeOption(vis[sci] ?? 0)),
              onTap: () => Navigator.of(context).pop(sci),
            ),
        ],
      ),
    );
  }
}

/// La pozione appena preparata: recipiente pieno, nome, potenza, Tocco e PE; oppure la pozione guastata.
class PotionResultPage extends StatelessWidget {
  final PotionBrewed event;

  /// La prima pozione di questa ricetta: i PE comprendono il bonus.
  final bool firstBrew;

  const PotionResultPage({super.key, required this.event, required this.firstBrew});

  @override
  Widget build(BuildContext context) => DenseArea(
    child: Scaffold(
      appBar: clayAppBar(context, title: context.l10n.potionTitle),
      extendBodyBehindAppBar: true,
      body: DruidBackground(
        belowAppBar: true,
        child: GameDataBuilder(
          builder: (context, catalog, state, _) {
            final brewable = brewableOf(catalog, event.recipeId)!;
            final hint = context.texts.bodyMedium?.copyWith(color: context.druid.hint);
            final touch = event.touch;
            final free = event.freeSpecies == null ? null : catalog.speciesBySci(event.freeSpecies!);
            return ListView(
              key: const ValueKey('potion-result'),
              padding: const EdgeInsets.all(Gaps.l),
              children: [
                GradeCard(
                  grade: brewable.grade,
                  child: Column(
                    children: [
                      RecipeIdVessel(catalog: catalog, recipeId: event.recipeId, size: 120, spoiled: event.spoiled),
                      const SizedBox(height: Gaps.m),
                      Text(
                        recipeNameOf(context, catalog, state, event.recipeId),
                        style: context.texts.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Gaps.s),
                      if (event.spoiled) ...[
                        Text(context.l10n.potionSpoiledTitle, style: context.texts.titleMedium),
                        const SizedBox(height: Gaps.xs),
                        Text(
                          context.l10n.potionSpoiledText(free == null ? '' : context.game.name(free)),
                          style: hint,
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        Text(context.l10n.potionPotency(event.potency), style: context.texts.headlineSmall),
                        if (touch != null)
                          Text(
                            context.l10n.potionTouch(
                              touchAdjective(touch, context.contentLanguage, feminine: brewable.base?.feminine ?? true),
                            ),
                            style: hint,
                          ),
                      ],
                      if (event.xp > 0) ...[
                        const SizedBox(height: Gaps.m),
                        Text(context.l10n.xpGained(event.xp), style: context.texts.titleMedium),
                        if (firstBrew && !event.spoiled)
                          Text(context.l10n.potionFirstBonus(EconomyRules.firstBrewBonus), style: hint),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Gaps.l),
                Center(
                  child: ClayButton(
                    key: const ValueKey('potion-done'),
                    label: context.l10n.troveDone,
                    onPressed: () => Get.back<void>(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
