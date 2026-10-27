import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/mythic.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/recipe_book/recipe_page.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Le Mitiche della Zona, numerate dentro la Zona: il numero sempre, il nome solo se la conosci.
class MythicsPage extends StatelessWidget {
  const MythicsPage({super.key});

  @override
  Widget build(BuildContext context) => DenseArea(
    child: Scaffold(
      appBar: clayAppBar(context, title: context.l10n.recipeBookTitle),
      extendBodyBehindAppBar: true,
      body: DruidBackground(
        belowAppBar: true,
        child: GameDataBuilder(
          builder: (context, catalog, state, _) {
            final known = knownMythicIds(catalog, state);
            return ListView(
              padding: const EdgeInsets.all(Gaps.l),
              children: [
                Text(
                  context.l10n.recipeBookMythicsRow(catalog.regionName.resolve(context.contentLanguage)),
                  style: context.texts.headlineSmall,
                ),
                const SizedBox(height: Gaps.xs),
                Text(context.l10n.mythicsIntro, style: context.texts.bodySmall?.copyWith(color: context.druid.hint)),
                const SizedBox(height: Gaps.l),
                for (final m in catalog.mythics) ...[
                  _MythicRow(mythic: m, known: known.contains(m.id)),
                  const SizedBox(height: Gaps.m),
                ],
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _MythicRow extends StatelessWidget {
  final Mythic mythic;
  final bool known;

  const _MythicRow({required this.mythic, required this.known});

  @override
  Widget build(BuildContext context) => GradeCard(
    key: ValueKey('mythic-${mythic.id}'),
    grade: Grade.mythic,
    onTap: known ? () => Get.to<void>(() => MythicRecipePage(mythicId: mythic.id)) : null,
    child: Row(
      children: [
        GradeDot(grade: Grade.mythic, label: context.game.grade(Grade.mythic), filled: known),
        const SizedBox(width: Gaps.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.mythicNumber(mythic.number.toString()), style: context.texts.labelLarge),
              Text(
                known ? mythic.name(context.contentLanguage) : context.l10n.mythicToFind,
                style: known ? context.texts.titleMedium : TextStyle(color: context.druid.hint),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
