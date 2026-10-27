import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/affixes.dart';
import 'package:druid_app/business_logic/rules/recipes/brewing.dart';
import 'package:druid_app/business_logic/rules/recipes/potion_effects.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/engraved_icon.dart';
import 'package:druid_app/user_interface/common_widgets/potion_vessel.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/recipe_identity.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Lo Scaffale, la quarta linguetta del Laboratorio: gli effetti in corso, poi le pozioni preparate dalla più recente,
/// da tenere per la collezione o usare (l'effetto vale 7 giorni; usata, la pozione lascia lo Scaffale ma la Tavola
/// tiene la potenza migliore).
class ShelfView extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final Widget header;

  const ShelfView({super.key, required this.catalog, required this.state, required this.header});

  @override
  Widget build(BuildContext context) {
    final hint = context.texts.bodySmall?.copyWith(color: context.druid.hint);
    final potions = state.potions.reversed.where((p) => p.onShelf).toList();
    final now = Get.find<ProgressController>().now;
    final active = activeEffects(state, now);
    return ListView(
      key: const ValueKey('shelf'),
      padding: EdgeInsets.fromLTRB(Gaps.l, MediaQuery.paddingOf(context).top + Gaps.l, Gaps.l, homeBottomInset),
      children: [
        header,
        const SizedBox(height: Gaps.l),
        if (active.isNotEmpty) ...[
          ClayCard(
            key: const ValueKey('active-effects'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.shelfActive, style: context.texts.titleSmall),
                for (final MapEntry(key: effect, value: strength) in active.entries) ...[
                  const SizedBox(height: Gaps.xs),
                  Row(
                    children: [
                      EngravedIcon(effectIconOf(effect), size: 16),
                      const SizedBox(width: Gaps.s),
                      Expanded(
                        child: Text(
                          context.l10n.shelfActiveLine(
                            context.game.effect(effect),
                            strength,
                            DateFormat.MMMd(context.contentLanguage).format(effectUntil(state, effect, now)!),
                          ),
                          style: context.texts.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Gaps.m),
        ],
        Text(
          potions.isEmpty ? context.l10n.shelfEmpty : context.l10n.shelfHint,
          key: const ValueKey('shelf-hint'),
          style: hint,
        ),
        const SizedBox(height: Gaps.m),
        for (final potion in potions) ...[
          RepaintBoundary(
            child: GradeCard(
              key: ValueKey('potion-${potion.index}'),
              grade: brewableOf(catalog, potion.recipeId)?.grade ?? Grade.common,
              child: Row(
                children: [
                  RecipeIdVessel(catalog: catalog, recipeId: potion.recipeId, size: 56),
                  const SizedBox(width: Gaps.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RecipeNameText(
                          catalog: catalog,
                          state: state,
                          recipeId: potion.recipeId,
                          style: context.texts.titleSmall,
                        ),
                        Text(
                          [
                            context.l10n.potionPotency(potion.potency),
                            if (potion.touch case final touch?)
                              context.l10n.potionTouch(
                                touchAdjective(
                                  touch,
                                  context.contentLanguage,
                                  feminine: brewableOf(catalog, potion.recipeId)?.base?.feminine ?? true,
                                ),
                              ),
                          ].join(' · '),
                          style: context.texts.labelLarge,
                        ),
                        Text(DateFormat.MMMd(context.contentLanguage).format(potion.brewedAt), style: hint),
                      ],
                    ),
                  ),
                  const SizedBox(width: Gaps.s),
                  OutlinedButton(
                    key: ValueKey('use-potion-${potion.index}'),
                    onPressed: () => _use(context, potion.index, potion.recipeId),
                    child: Text(context.l10n.shelfUse),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gaps.m),
        ],
      ],
    );
  }

  Future<void> _use(BuildContext context, int index, String recipeId) async {
    final messenger = ScaffoldMessenger.of(context);
    final effect = brewableOf(catalog, recipeId)?.effect;
    final text = effect == null ? null : context.l10n.shelfUsed(context.game.effect(effect));
    if (await Get.find<ProgressController>().usePotion(index) && text != null) {
      messenger.showSnackBar(SnackBar(content: Text(text)));
    }
  }
}
