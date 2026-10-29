import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/business_logic/rules/tutorial_intermediate.dart';
import 'package:druid_app/controllers/home/home_controller.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/field/capture_page.dart';
import 'package:druid_app/user_interface/pages/study/study_home_page.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// La card del tutorial intermedio in Home (capitolo 03, 2026-10-29): si sblocca finito o saltato il Base; prima di
/// cominciare "Inizia" o "Salta", durante il passo del momento con il perché e il pulsante che porta al posto giusto.
/// Sparisce a Intermedio finito o saltato. A differenza del Base, la Home resta completa.
class IntermediateTutorialCard extends StatelessWidget {
  final Catalog catalog;
  final GameState state;

  const IntermediateTutorialCard({super.key, required this.catalog, required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = Get.find<ProgressController>();
    final step = currentIntermediateStep(catalog, state);
    final (title, body) = step == null
        ? (context.l10n.intermediateIntroTitle, context.l10n.intermediateIntroBody)
        : _texts(context, step);
    final (actionLabel, onAction) = step == null
        ? (context.l10n.tutorialStart, () => progress.markOnboarding(OnboardingMark.intermediateStarted))
        : _action(context, step, progress);
    return ClayCard(
      key: ValueKey('intermediate-${step?.name ?? 'intro'}'),
      color: context.colors.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClayCircle(color: context.colors.primaryContainer, icon: _icon(step), size: 44),
              const SizedBox(width: Gaps.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (step != null)
                      Text(
                        context.l10n.intermediateLabel(step.index + 1, IntermediateStep.values.length),
                        style: context.texts.labelMedium?.copyWith(color: context.colors.onSecondaryContainer),
                      ),
                    Text(title, style: context.texts.titleLarge),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Gaps.s),
          Text(body),
          const SizedBox(height: Gaps.m),
          Wrap(
            spacing: Gaps.chip,
            runSpacing: Gaps.chipRun,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(key: const ValueKey('intermediate-action'), onPressed: onAction, child: Text(actionLabel)),
              if (step != IntermediateStep.finished)
                TextButton(
                  key: const ValueKey('intermediate-skip'),
                  onPressed: () => progress.markOnboarding(OnboardingMark.intermediateSkipped),
                  child: Text(context.l10n.intermediateSkip),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _icon(IntermediateStep? step) => switch (step) {
    null => Icons.school_outlined,
    IntermediateStep.herb || IntermediateStep.drawSun || IntermediateStep.companion => Icons.photo_camera_outlined,
    IntermediateStep.study => Icons.menu_book_rounded,
    IntermediateStep.brew => Icons.science_outlined,
    IntermediateStep.finished => Icons.eco_rounded,
  };

  /// Il nome di una pianta come lo mostra il gioco.
  String _name(BuildContext context, String? sci) {
    final species = sci == null ? null : catalog.speciesBySci(sci);
    return species == null ? '' : context.game.name(species);
  }

  (String, String) _texts(BuildContext context, IntermediateStep step) {
    final l10n = context.l10n;
    final plant = _name(context, intermediateHerb(catalog, state));
    return switch (step) {
      IntermediateStep.herb => (l10n.intermediateHerbTitle, l10n.intermediateHerbBody),
      IntermediateStep.study => (l10n.intermediateStudyTitle, l10n.intermediateStudyBody(plant)),
      IntermediateStep.drawSun => (l10n.intermediateDrawSunTitle, l10n.intermediateDrawSunBody(plant)),
      IntermediateStep.companion => (
        l10n.intermediateCompanionTitle,
        l10n.intermediateCompanionBody(_name(context, intermediateCompanion(catalog, state))),
      ),
      IntermediateStep.brew => (l10n.intermediateBrewTitle, l10n.intermediateBrewBody),
      IntermediateStep.finished => (l10n.intermediateFinishedTitle, l10n.intermediateFinishedBody),
    };
  }

  (String, VoidCallback) _action(BuildContext context, IntermediateStep step, ProgressController progress) {
    final l10n = context.l10n;
    void capture() => Get.to<void>(() => const CapturePage());
    return switch (step) {
      IntermediateStep.herb ||
      IntermediateStep.drawSun ||
      IntermediateStep.companion => (l10n.tutorialActionCapture, capture),
      IntermediateStep.study => (
        l10n.tutorialActionStudy,
        () {
          final sci = intermediateHerb(catalog, state);
          final species = sci == null ? null : catalog.speciesBySci(sci);
          final level = species == null ? null : nextStudyLevel(species, catalog, state);
          if (species != null && level != null) startLevelStudy(catalog, species.sci, level);
        },
      ),
      IntermediateStep.brew => (
        l10n.tutorialActionLaboratory,
        () => Get.find<HomeController>().select(HomeController.laboratoryTab),
      ),
      IntermediateStep.finished => (
        l10n.intermediateActionFinish,
        () => progress.markOnboarding(OnboardingMark.intermediateFinished),
      ),
    };
  }
}
