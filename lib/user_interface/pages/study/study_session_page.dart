import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/study/questions.dart';
import 'package:druid_app/business_logic/rules/study/review_schedule.dart';
import 'package:druid_app/business_logic/rules/study/study_session.dart';
import 'package:druid_app/controllers/catalog/catalog_controller.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/controllers/study/study_controller.dart';
import 'package:druid_app/controllers/subscription/subscription_controller.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/erbario/level_name.dart';
import 'package:druid_app/user_interface/pages/notebook/notebook_page.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/species_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Sessione di studio o di ripasso: una domanda alla volta, esito, spiegazione, riepilogo finale.
class StudySessionPage extends StatelessWidget {
  const StudySessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = Get.find<CatalogController>().uiData.fold((_) => null, (c) => c);
    // Pagina densa: nelle livree che lo prevedono sfondo e superfici più chiari (vedi `DenseArea`).
    return DenseArea(
      child: GetBuilder<StudyController>(
        builder: (study) => Scaffold(
          appBar: clayAppBar(
            context,
            title: _title(context, study, catalog),
            // Il nome della specie in maiuscoletto; il titolo dei ripassi resta normale.
            titleStyle: study.mode == AnswerMode.review
                ? null
                : speciesNameStyle(context, context.texts.headlineSmall, green: false),
            leadingIcon: Icons.close_rounded,
            leadingTooltip: context.l10n.close,
            onLeading: () {
              study.close();
              Get.back<void>();
            },
            actions: [
              ClayIconButton(
                key: const ValueKey('open-notebook'),
                icon: Icons.bookmarks_rounded,
                tooltip: context.l10n.notebookTitle,
                onPressed: () => openNotebook(context),
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: DruidBackground(
            belowAppBar: true,
            child: SafeArea(
              child: study.summary != null
                  ? _Summary(summary: study.summary!, catalog: catalog)
                  // Dopo l'ultima risposta la sessione è già finita, ma l'esito va mostrato finché non si va avanti.
                  : (study.question == null && study.lastOutcome == null) || catalog == null
                  ? const SizedBox.shrink()
                  : _QuestionView(study: study, catalog: catalog),
            ),
          ),
        ),
      ),
    );
  }

  String _title(BuildContext context, StudyController study, Catalog? catalog) {
    if (study.mode == AnswerMode.review) return context.l10n.reviewTitle;
    final species = study.speciesSci == null ? null : catalog?.speciesBySci(study.speciesSci!);
    return species == null ? '' : context.game.name(species);
  }
}

class _QuestionView extends StatelessWidget {
  final StudyController study;
  final Catalog catalog;

  const _QuestionView({required this.study, required this.catalog});

  @override
  Widget build(BuildContext context) {
    final question = study.lastOutcome?.question ?? study.question!;
    final outcome = study.lastOutcome;
    final game = context.game;
    return ListView(
      padding: const EdgeInsets.all(Gaps.l),
      children: [
        ClayProgressBar(value: study.totalFacts == 0 ? 0 : study.completedFacts / study.totalFacts, height: 4),
        const SizedBox(height: Gaps.xs),
        // Il tema del livello sta qui, non nel titolo: il titolo resta il nome della specie, che non va tagliato.
        Text(
          study.mode == AnswerMode.learning
              ? context.l10n.studyThemeProgress(
                  levelName(context.l10n, study.level ?? 0),
                  study.completedFacts,
                  study.totalFacts,
                )
              : context.l10n.studyProgress(study.completedFacts, study.totalFacts),
          style: context.texts.bodySmall,
        ),
        const SizedBox(height: Gaps.l),
        Text(game.prompt(question), style: context.texts.headlineSmall),
        if (question.imageUrl != null) ...[
          const SizedBox(height: Gaps.m),
          ClipRRect(
            borderRadius: BorderRadius.circular(context.druid.cardRadius),
            child: AspectRatio(aspectRatio: 4 / 3, child: RemoteImage(question.imageUrl!)),
          ),
        ],
        const SizedBox(height: Gaps.l),
        if (question.form == QuestionForm.nameToPhoto)
          _PhotoOptions(question: question, outcome: outcome, onTap: study.answer)
        else
          for (final option in question.options) ...[
            _OptionButton(
              label: game.option(question, option),
              state: _stateOf(option, question, outcome),
              onTap: outcome == null ? () => study.answer(option) : null,
            ),
            const SizedBox(height: Gaps.s),
          ],
        if (outcome != null) ...[
          const SizedBox(height: Gaps.m),
          _OutcomeCard(outcome: outcome, catalog: catalog),
          const SizedBox(height: Gaps.l),
          FilledButton(key: const ValueKey('next-question'), onPressed: study.next, child: Text(context.l10n.next)),
        ],
      ],
    );
  }
}

enum _OptionState { idle, right, wrong, disabled }

_OptionState _stateOf(AnswerOption option, Question question, AnswerOutcome? outcome) {
  if (outcome == null) return _OptionState.idle;
  if (option == question.answer) return _OptionState.right;
  if (option == outcome.chosen) return _OptionState.wrong;
  return _OptionState.disabled;
}

class _OptionButton extends StatelessWidget {
  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  const _OptionButton({required this.label, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, border) = switch (state) {
      _OptionState.right => (colors.primaryContainer, colors.primary),
      _OptionState.wrong => (colors.errorContainer, colors.error),
      _ => (colors.surfaceContainerLow, colors.outlineVariant),
    };
    return ClayCard(
      key: ValueKey('option-$label'),
      color: background,
      radius: context.druid.cardRadius * 0.75,
      padding: EdgeInsets.zero,
      onTap: onTap ?? () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Gaps.l),
        // Senza plastilina resta il bordo colorato della risposta giusta o sbagliata.
        decoration: context.druid.clay
            ? null
            : BoxDecoration(
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(context.druid.cardRadius * 0.75),
              ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: context.texts.bodyLarge)),
            if (state == _OptionState.right) Icon(Icons.check_circle_rounded, color: colors.primary),
            if (state == _OptionState.wrong) Icon(Icons.cancel_rounded, color: colors.error),
          ],
        ),
      ),
    );
  }
}

class _PhotoOptions extends StatelessWidget {
  final Question question;
  final AnswerOutcome? outcome;
  final Future<void> Function(AnswerOption) onTap;

  const _PhotoOptions({required this.question, required this.outcome, required this.onTap});

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    // Le ombre della plastilina devono uscire dalla griglia.
    clipBehavior: Clip.none,
    mainAxisSpacing: Gaps.m,
    crossAxisSpacing: Gaps.m,
    children: [
      for (final option in question.options.cast<SpeciesOption>())
        GestureDetector(
          key: ValueKey('photo-option-${option.species.sci}'),
          onTap: outcome == null ? () => onTap(option) : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.druid.cardRadius / 2),
              boxShadow: context.druid.clay
                  ? [BoxShadow(color: context.druid.clayShadow, blurRadius: 18, offset: const Offset(0, 8))]
                  : null,
            ),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.druid.cardRadius / 2),
                border: Border.all(
                  width: 4,
                  color: switch (_stateOf(option, question, outcome)) {
                    _OptionState.right => context.colors.primary,
                    _OptionState.wrong => context.colors.error,
                    _ => context.druid.clay ? Colors.white.withValues(alpha: 0.35) : Colors.transparent,
                  },
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.druid.cardRadius / 2),
                child: RemoteImage(option.imageUrl!),
              ),
            ),
          ),
        ),
    ],
  );
}

class _OutcomeCard extends StatelessWidget {
  final AnswerOutcome outcome;
  final Catalog catalog;

  const _OutcomeCard({required this.outcome, required this.catalog});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = Get.find<ProgressController>();
    final box = progress.state.progressOf(outcome.question.fact.id).box;
    final followUp = switch (outcome.event.mode) {
      AnswerMode.learning => outcome.willReturn ? l10n.answerWillReturn : null,
      AnswerMode.review => outcome.correct ? l10n.answerRemembered(reviewIntervalsDays[box]) : l10n.answerForgotten,
      AnswerMode.awakening => null,
    };
    return ClayCard(
      padding: EdgeInsets.zero,
      color: outcome.correct ? context.colors.primaryContainer : context.colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(Gaps.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(outcome.correct ? l10n.answerRight : l10n.answerWrong, style: context.texts.titleMedium),
                ),
                if (outcome.xp > 0) Text(l10n.xpGained(outcome.xp), style: context.texts.titleMedium),
              ],
            ),
            const SizedBox(height: Gaps.xs),
            Text(context.game.fact(outcome.question.fact, catalog)),
            if (followUp != null) ...[const SizedBox(height: Gaps.xs), Text(followUp, style: context.texts.bodySmall)],
            const SizedBox(height: Gaps.s),
            _NotebookButton(factId: outcome.question.fact.id),
          ],
        ),
      ),
    );
  }
}

/// "Salva nel taccuino": con il Diario salva in un tocco; senza, spiega cosa offre il Diario.
class _NotebookButton extends StatelessWidget {
  final String factId;

  const _NotebookButton({required this.factId});

  @override
  Widget build(BuildContext context) => GetBuilder<SubscriptionController>(
    builder: (subscription) => GetBuilder<ProgressController>(
      builder: (progress) {
        if (!subscription.diarioActive) {
          return TextButton.icon(
            key: const ValueKey('notebook-locked'),
            onPressed: () => showDiarioUpsell(context),
            icon: const Icon(Icons.lock_outline, size: 18),
            label: Text(context.l10n.notebookLocked),
          );
        }
        final saved = progress.state.notebook.contains(factId);
        return TextButton.icon(
          key: const ValueKey('notebook-save'),
          onPressed: saved ? null : () => progress.saveToNotebook(factId),
          icon: Icon(saved ? Icons.bookmark : Icons.bookmark_add_outlined, size: 18),
          label: Text(saved ? context.l10n.savedToNotebook : context.l10n.saveToNotebook),
        );
      },
    ),
  );
}

class _Summary extends StatelessWidget {
  final SessionSummary summary;
  final Catalog? catalog;

  const _Summary({required this.summary, required this.catalog});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final species = summary.speciesSci == null ? null : catalog?.speciesBySci(summary.speciesSci!);
    return ListView(
      padding: const EdgeInsets.all(Gaps.xl),
      children: [
        Text(l10n.summaryTitle, style: context.texts.headlineMedium),
        const SizedBox(height: Gaps.l),
        if (summary.levelPassed != null && species != null)
          Text(
            l10n.summaryLevelPassed(summary.levelPassed!, context.game.name(species)),
            style: context.texts.titleMedium,
          )
        else
          Text(l10n.summaryReviewDone, style: context.texts.titleMedium),
        const SizedBox(height: Gaps.s),
        Text(l10n.summaryAnswers(summary.correct, summary.answers)),
        Text(l10n.xpGained(summary.xp), style: context.texts.titleLarge),
        if (species != null && !Get.find<ProgressController>().state.hasDrawn(species.sci))
          Text(l10n.summaryXpToCash, key: const ValueKey('summary-xp-to-cash'), style: context.texts.bodySmall),
        if (summary.masteryReached) ...[const SizedBox(height: Gaps.s), Text(l10n.summaryMastery)],
        if (summary.learnedRecipe case final recipe?) ...[
          const SizedBox(height: Gaps.m),
          Text(
            l10n.summaryRecipeLearned(recipe.name(context.contentLanguage)),
            key: const ValueKey('summary-recipe-learned'),
            style: context.texts.titleMedium,
          ),
        ],
        if (summary.levelPassed != null) ...[const SizedBox(height: Gaps.s), Text(l10n.summaryNewFunFacts)],
        const SizedBox(height: Gaps.xl),
        FilledButton(
          key: const ValueKey('close-session'),
          onPressed: () {
            Get.find<StudyController>().close();
            Get.back<void>();
          },
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
