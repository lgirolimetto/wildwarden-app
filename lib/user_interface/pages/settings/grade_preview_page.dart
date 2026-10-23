import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Strumento di prova: una scheda di ricetta per grado (comune, non comune, rara, mitica), per vedere il cerchietto del grado
/// con la livrea e il tema chiaro/scuro correnti.
class GradePreviewPage extends StatelessWidget {
  const GradePreviewPage({super.key});

  @override
  Widget build(BuildContext context) => DenseArea(child: _page(context));

  Widget _page(BuildContext context) => Scaffold(
    appBar: clayAppBar(context, title: context.l10n.debugGradePreview),
    extendBodyBehindAppBar: true,
    body: DruidBackground(
      belowAppBar: true,
      child: ListView(
        padding: const EdgeInsets.all(Gaps.l),
        children: [
          for (final grade in Grade.values) ...[
            Text(context.game.grade(grade), style: context.texts.labelLarge),
            const SizedBox(height: Gaps.s),
            GradeCard(
              key: ValueKey('preview-${grade.name}'),
              grade: grade,
              child: _SampleRecipe(grade: grade),
            ),
            const SizedBox(height: Gaps.xl),
          ],
        ],
      ),
    ),
  );
}

/// Contenuto di esempio di una ricetta: grado, nome, un ingrediente con tratto, effetto.
class _SampleRecipe extends StatelessWidget {
  final Grade grade;

  const _SampleRecipe({required this.grade});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GradeDot(grade: grade, label: context.game.grade(grade)),
      const SizedBox(height: Gaps.s),
      Text(context.l10n.debugGradeSampleName, style: context.texts.titleLarge),
      const SizedBox(height: Gaps.s),
      Wrap(
        spacing: Gaps.chip,
        runSpacing: Gaps.chipRun,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('2 × ${context.l10n.debugGradeSampleIngredient}', style: context.texts.bodyLarge),
          Pill(context.game.trait(Trait.moon)),
        ],
      ),
      const SizedBox(height: Gaps.s),
      Text(context.l10n.debugGradeSampleEffect),
    ],
  );
}
