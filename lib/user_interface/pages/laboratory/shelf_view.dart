import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/affixes.dart';
import 'package:druid_app/business_logic/rules/recipes/brewing.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/recipe_identity.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Lo Scaffale, la quarta linguetta del Laboratorio: le pozioni preparate, dalla più recente. Tenere o usare arriva con
/// lo step 9 della tappa C.
class ShelfView extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final Widget header;

  const ShelfView({super.key, required this.catalog, required this.state, required this.header});

  @override
  Widget build(BuildContext context) {
    final hint = context.texts.bodySmall?.copyWith(color: context.druid.hint);
    final potions = state.potions.reversed.toList();
    return ListView(
      key: const ValueKey('shelf'),
      padding: EdgeInsets.fromLTRB(Gaps.l, MediaQuery.paddingOf(context).top + Gaps.l, Gaps.l, homeBottomInset),
      children: [
        header,
        const SizedBox(height: Gaps.l),
        if (potions.isEmpty) Text(context.l10n.shelfEmpty, key: const ValueKey('shelf-empty'), style: hint),
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
                ],
              ),
            ),
          ),
          const SizedBox(height: Gaps.m),
        ],
      ],
    );
  }
}
