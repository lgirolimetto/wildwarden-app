import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/onboarding.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/controllers/home/home_controller.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/glossary/glossary.dart';
import 'package:druid_app/user_interface/pages/study/study_home_page.dart';
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

/// Missione corrente dell'apprendistato, sempre visibile finché non è completo o saltato. Il pulsante d'azione porta
/// dove la missione si fa; le chip sotto aprono solo il glossario.
class MissionBanner extends StatelessWidget {
  final Mission mission;
  final Catalog catalog;
  final GameState state;
  final DateTime now;

  const MissionBanner({
    super.key,
    required this.mission,
    required this.catalog,
    required this.state,
    required this.now,
  });

  /// Testo e azione del pulsante della missione.
  (String, VoidCallback) _action(BuildContext context) {
    final home = Get.find<HomeController>();
    void openTab(int tab) => home.select(tab);
    return switch (mission) {
      Mission.visitErbario => (context.l10n.missionActionOpenErbario, () => openTab(HomeController.erbarioTab)),
      Mission.markDesiderata => (context.l10n.missionActionChooseDesiderata, () => openTab(HomeController.erbarioTab)),
      Mission.firstEncounter => (context.l10n.missionActionOpenErbario, () => openTab(HomeController.erbarioTab)),
      Mission.firstLevel => (
        context.l10n.missionActionStudy,
        () => switch (speciesToStudyFirst(state, catalog, now)) {
          final sci? => startLevelStudy(catalog, sci, nextStudyLevel(catalog.speciesBySci(sci)!, catalog, state)!),
          null => openTab(HomeController.erbarioTab),
        },
      ),
      Mission.firstRecipe => (context.l10n.missionActionRecipes, () => openTab(HomeController.recipesTab)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (actionLabel, onAction) = _action(context);
    return ClayCard(
      key: ValueKey('mission-${mission.name}'),
      color: context.colors.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClayCircle(color: context.colors.primaryContainer, icon: Icons.flag_rounded, size: 44),
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
          const SizedBox(height: Gaps.m),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              key: ValueKey('mission-action-${mission.name}'),
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ),
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
}
