import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/business_logic/rules/tutorial.dart';
import 'package:druid_app/controllers/home/home_controller.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/pages/field/capture_page.dart';
import 'package:druid_app/user_interface/pages/study/study_home_page.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// La card del tutorial in Home (al posto dell'Apprendistato): prima di cominciare "Inizia" o "Salta il tutorial",
/// durante il passo del momento con il perché e il pulsante che porta al posto giusto. Sparisce a tutorial finito o
/// saltato.
class TutorialCard extends StatelessWidget {
  final Catalog catalog;
  final GameState state;

  const TutorialCard({super.key, required this.catalog, required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = Get.find<ProgressController>();
    final step = currentTutorialStep(state);
    final (title, body) = step == null
        ? (context.l10n.tutorialIntroTitle, context.l10n.tutorialIntroBody)
        : _texts(context, step);
    final (actionLabel, onAction) = step == null
        ? (context.l10n.tutorialStart, () => progress.markOnboarding(OnboardingMark.tutorialStarted))
        : _action(context, step, progress);
    return ClayCard(
      key: ValueKey('tutorial-${step?.name ?? 'intro'}'),
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
                        context.l10n.tutorialLabel(step.index + 1, TutorialStep.values.length),
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
              FilledButton(key: const ValueKey('tutorial-action'), onPressed: onAction, child: Text(actionLabel)),
              if (step != TutorialStep.apprentice)
                TextButton(
                  key: const ValueKey('tutorial-skip'),
                  onPressed: () => progress.markOnboarding(OnboardingMark.tutorialSkipped),
                  child: Text(context.l10n.tutorialSkip),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _icon(TutorialStep? step) => switch (step) {
    null => Icons.school_outlined,
    TutorialStep.photograph || TutorialStep.secondPhotograph => Icons.photo_camera_outlined,
    TutorialStep.study => Icons.menu_book_rounded,
    TutorialStep.brew => Icons.science_outlined,
    TutorialStep.trove => Icons.redeem_rounded,
    TutorialStep.apprentice => Icons.eco_rounded,
  };

  (String, String) _texts(BuildContext context, TutorialStep step) {
    final l10n = context.l10n;
    return switch (step) {
      TutorialStep.photograph => (l10n.tutorialPhotographTitle, l10n.tutorialPhotographBody),
      TutorialStep.study => (l10n.tutorialStudyTitle, l10n.tutorialStudyBody),
      TutorialStep.secondPhotograph => (l10n.tutorialSecondPhotographTitle, l10n.tutorialSecondPhotographBody),
      TutorialStep.brew => (l10n.tutorialBrewTitle, l10n.tutorialBrewBody),
      TutorialStep.trove => (l10n.tutorialTroveTitle, l10n.tutorialTroveBody),
      TutorialStep.apprentice => (l10n.tutorialApprenticeTitle, l10n.tutorialApprenticeBody),
    };
  }

  (String, VoidCallback) _action(BuildContext context, TutorialStep step, ProgressController progress) {
    final l10n = context.l10n;
    final home = Get.find<HomeController>();
    void capture() => Get.to<void>(() => const CapturePage());
    return switch (step) {
      TutorialStep.photograph || TutorialStep.secondPhotograph => (l10n.tutorialActionCapture, capture),
      TutorialStep.study => (
        l10n.tutorialActionStudy,
        () {
          final sci = tutorialSpeciesToStudy(state);
          final species = sci == null ? null : catalog.speciesBySci(sci);
          final level = species == null ? null : nextStudyLevel(species, catalog, state);
          if (species != null && level != null) startLevelStudy(catalog, species.sci, level);
        },
      ),
      TutorialStep.brew => (l10n.tutorialActionLaboratory, () => home.select(HomeController.laboratoryTab)),
      TutorialStep.trove => (l10n.tutorialActionTrove, () => home.select(HomeController.troveTab)),
      TutorialStep.apprentice => (
        l10n.tutorialActionFinish,
        () => progress.markOnboarding(OnboardingMark.tutorialFinished),
      ),
    };
  }
}
