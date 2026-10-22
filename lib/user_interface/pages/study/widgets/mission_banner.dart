import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/onboarding.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/glossary/glossary.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Termini del glossario collegati a ogni missione.
const _missionTerms = {
  Mission.visitErbario: [GlossaryTerm.erbario],
  Mission.markDesiderata: [GlossaryTerm.desiderata, GlossaryTerm.missione],
  Mission.firstEncounter: [GlossaryTerm.erborizzare, GlossaryTerm.stazione],
  Mission.firstLevel: [GlossaryTerm.maestria],
  Mission.firstRecipe: [GlossaryTerm.tratto, GlossaryTerm.attingere],
};

/// Missione corrente dell'apprendistato, sempre visibile finché non è completo o saltato.
class MissionBanner extends StatelessWidget {
  final Mission mission;

  const MissionBanner({super.key, required this.mission});

  @override
  Widget build(BuildContext context) => ClayCard(
    key: ValueKey('mission-${mission.name}'),
    color: context.colors.secondaryContainer,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ClayCircle(color: Color(0xFFF2B9A0), icon: Icons.flag_rounded, size: 44),
            const SizedBox(width: Gaps.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.missionLabel(mission.index + 1, Mission.values.length),
                    style: context.texts.labelMedium?.copyWith(color: context.colors.onSecondaryContainer),
                  ),
                  Text(context.game.missionTitle(mission), style: context.texts.titleLarge),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Gaps.s),
        Text(context.game.missionBody(mission)),
        const SizedBox(height: Gaps.s),
        Wrap(
          spacing: Gaps.chip,
          runSpacing: Gaps.chipRun,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final term in _missionTerms[mission]!) GlossaryChip(term),
            TextButton(
              key: const ValueKey('skip-apprenticeship'),
              onPressed: () => Get.find<ProgressController>().markOnboarding(OnboardingMark.skipped),
              child: Text(context.l10n.missionSkip),
            ),
          ],
        ),
      ],
    ),
  );
}
