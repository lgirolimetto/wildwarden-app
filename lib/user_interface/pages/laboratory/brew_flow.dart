import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/economy.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/affixes.dart';
import 'package:druid_app/business_logic/rules/recipes/brewing.dart';
import 'package:druid_app/business_logic/rules/recipes/potion_effects.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/engraved_icon.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/common_widgets/potion_vessel.dart';
import 'package:druid_app/user_interface/common_widgets/species_name.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/laboratory/brew_section.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/recipe_identity.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Prepara [brewable]: se ha lo slot libero chiede prima la pianta (che dà il Tocco), poi una conferma con quello che
/// spende (sempre: preparare consuma Vis e non si torna indietro), poi apre la pozione appena fatta.
Future<void> startBrew(BuildContext context, Catalog catalog, GameState state, Brewable brewable) async {
  final progress = Get.find<ProgressController>();
  String? freeSpecies;
  if (brewable.freeSlot != null) {
    freeSpecies = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FreeSlotSheet(catalog: catalog, state: state, brewable: brewable),
    );
    if (freeSpecies == null) return;
  }
  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) =>
        _BrewConfirmDialog(catalog: catalog, state: state, brewable: brewable, freeSpecies: freeSpecies),
  );
  if (confirmed != true) return;
  final event = await progress.brew(brewable.id, freeSpecies: freeSpecies);
  if (event == null) return;
  await Get.to<void>(() => PotionResultPage(event: event, firstBrew: !state.bestPotency.containsKey(brewable.id)));
}

/// L'effetto di gioco di [brewable]: quello scritto a mano per le Mitiche, quello dell'effetto per le Tavole.
String _effectTextOf(BuildContext context, Catalog catalog, Brewable brewable) {
  for (final m in catalog.mythics) {
    if (m.id == brewable.id) return m.effectText.resolve(context.contentLanguage);
  }
  return context.game.effectText(brewable.effect);
}

/// Il Tocco di [touch] in [brewable], in una riga: "Limpidezza, forza 2: un piccolo effetto in più" (o "rafforza
/// l'effetto della pozione", se è lo stesso).
String _touchLine(BuildContext context, Brewable brewable, PotionEffect touch) => context.l10n.brewTouchEffect(
  context.game.effect(touch),
  touchStrength,
  touch == brewable.effect ? context.l10n.brewTouchStrengthens : context.l10n.brewTouchAdds,
);

/// L'aggettivo del Tocco di [touch], accordato con la base di [brewable] ("Limpida", "Limpido").
String _touchAdjective(BuildContext context, Brewable brewable, PotionEffect touch) =>
    touchAdjective(touch, context.contentLanguage, feminine: brewable.base?.feminine ?? true);

/// La scelta della pianta per lo slot libero: quelle con abbastanza Vis, ognuna con il Tocco che darebbe e, sotto, il
/// suo effetto di gioco (2026-10-29). Le tossiche non si segnalano: è così che si impara (la pozione guastata).
class _FreeSlotSheet extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final Brewable brewable;

  const _FreeSlotSheet({required this.catalog, required this.state, required this.brewable});

  @override
  Widget build(BuildContext context) {
    // Le Vis che restano dopo gli altri ingredienti: quelle che lo slot libero può usare.
    final vis = freeSlotVis(brewable, state.essences);
    final hint = context.texts.bodySmall?.copyWith(color: context.druid.hint);
    return SafeArea(
      child: ListView(
        key: const ValueKey('free-slot-sheet'),
        shrinkWrap: true,
        padding: const EdgeInsets.all(Gaps.l),
        children: [
          Text(context.l10n.brewChooseFree, style: context.texts.titleMedium),
          Text(context.l10n.brewChooseFreeHint, style: hint),
          const SizedBox(height: Gaps.s),
          for (final sci in freeSlotCandidates(brewable, state.essences))
            ListTile(
              key: ValueKey('free-slot-$sci'),
              contentPadding: EdgeInsets.zero,
              title: Wrap(
                spacing: Gaps.s,
                runSpacing: Gaps.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    catalog.speciesBySci(sci) == null ? sci : context.game.name(catalog.speciesBySci(sci)!),
                    style: speciesNameStyle(context, context.texts.bodyLarge),
                  ),
                  if (touchOf(catalog, sci) case final touch?) Pill(_touchAdjective(context, brewable, touch)),
                ],
              ),
              subtitle: Text(switch (touchOf(catalog, sci)) {
                final touch? => _touchLine(context, brewable, touch),
                null => context.l10n.brewNoTouch,
              }, style: hint),
              trailing: Text(context.l10n.brewFreeOption(vis[sci] ?? 0)),
              onTap: () => Navigator.of(context).pop(sci),
            ),
        ],
      ),
    );
  }
}

/// La conferma prima di preparare: la pozione (con il Tocco), le Vis che spende ingrediente per ingrediente e l'effetto.
/// Annulla non consuma niente. Non avvisa delle tossiche nello slot libero (la pozione guastata insegna).
class _BrewConfirmDialog extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final Brewable brewable;
  final String? freeSpecies;

  const _BrewConfirmDialog({required this.catalog, required this.state, required this.brewable, this.freeSpecies});

  @override
  Widget build(BuildContext context) {
    final touch = touchOf(catalog, freeSpecies);
    final label = context.texts.labelMedium?.copyWith(color: context.druid.hint);
    return AlertDialog(
      key: const ValueKey('brew-confirm'),
      title: Text(context.l10n.brewConfirmTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RecipeIdVessel(catalog: catalog, recipeId: brewable.id, size: 48),
                const SizedBox(width: Gaps.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RecipeNameText(
                        catalog: catalog,
                        state: state,
                        recipeId: brewable.id,
                        style: context.texts.titleSmall,
                      ),
                      if (touch != null)
                        Text(
                          context.l10n.potionTouch(_touchAdjective(context, brewable, touch)),
                          style: context.texts.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gaps.m),
            Text(context.l10n.brewConfirmSpends, style: label),
            for (final ingredient in brewable.ingredients) ...[
              const SizedBox(height: Gaps.xs),
              VisLine(
                vis: ingredient.vis,
                species: [?(ingredient.speciesSci ?? freeSpecies)],
                traits: ingredient.traits,
                catalog: catalog,
              ),
            ],
            const SizedBox(height: Gaps.m),
            Text(context.l10n.recipeEffect, style: label),
            const SizedBox(height: Gaps.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EngravedIcon(effectIconOf(brewable.effect), size: 16),
                const SizedBox(width: Gaps.s),
                Expanded(child: Text(_effectTextOf(context, catalog, brewable), style: context.texts.bodySmall)),
              ],
            ),
            if (touch != null) ...[
              const SizedBox(height: Gaps.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EngravedIcon(effectIconOf(touch), size: 16),
                  const SizedBox(width: Gaps.s),
                  Expanded(
                    child: Text(
                      '${_touchAdjective(context, brewable, touch)} · ${_touchLine(context, brewable, touch)}',
                      style: context.texts.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('brew-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.brewCancel),
        ),
        ClayButton(
          key: const ValueKey('brew-confirm-button'),
          label: context.l10n.brewConfirm,
          icon: Icons.science_rounded,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
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
                      RecipeNameText(
                        catalog: catalog,
                        state: state,
                        recipeId: event.recipeId,
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
