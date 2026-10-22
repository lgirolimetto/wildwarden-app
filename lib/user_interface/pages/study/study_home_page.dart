import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/fun_facts.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/onboarding.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';
import 'package:druid_app/business_logic/rules/study/xp_rules.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/controllers/study/study_controller.dart';
import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:druid_app/user_interface/common_widgets/accent_card.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/diorama.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/erbario/level_name.dart';
import 'package:druid_app/user_interface/pages/glossary/glossary.dart';
import 'package:druid_app/user_interface/pages/notebook/notebook_page.dart';
import 'package:druid_app/user_interface/pages/species/species_page.dart';
import 'package:druid_app/user_interface/pages/study/study_session_page.dart';
import 'package:druid_app/user_interface/pages/study/widgets/mission_banner.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudyHomePage extends StatelessWidget {
  const StudyHomePage({super.key});

  @override
  Widget build(BuildContext context) => GameDataBuilder(
    builder: (context, catalog, state, progress) {
      // La curiosità del giorno si consegna all'apertura (l'operazione non fa nulla se è già stata data).
      WidgetsBinding.instance.addPostFrameCallback((_) => progress.revealTodayFunFact());
      final now = progress.now;
      final mission = currentMission(state, catalog);
      return ListView(
        padding: const EdgeInsets.only(bottom: homeBottomInset),
        children: [
          _DioramaHeader(now: now, xp: state.xp),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (mission != null) ...[const SizedBox(height: Gaps.l), MissionBanner(mission: mission)],
                const SizedBox(height: Gaps.l),
                _FunFactCard(catalog: catalog, state: state, now: now),
                const SizedBox(height: Gaps.l),
                _ReviewsCard(catalog: catalog, state: state, now: now),
                const SizedBox(height: Gaps.xl),
                _DesiderataSection(catalog: catalog, state: state, now: now, progress: progress),
                const SizedBox(height: Gaps.xl),
                _YourSpecies(catalog: catalog, state: state),
              ],
            ),
          ),
        ],
      );
    },
  );
}

/// Testata della pagina Studio: il diorama della stagione e del momento del giorno, con la barra integrata
/// (stagione, glossario, taccuino) e la scheda del titolo appoggiata sul bordo inferiore.
class _DioramaHeader extends StatelessWidget {
  static const dioramaHeight = 300.0;
  final DateTime now;
  final int xp;

  const _DioramaHeader({required this.now, required this.xp});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final season = Season.ofMonth(now.month);
    final time = DayTime.of(now);
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: dioramaHeight + top,
          child: Diorama(key: const ValueKey('diorama'), moment: now, fadeTo: context.druid.backgroundGradient.first),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(Gaps.l, top + Gaps.s, Gaps.l, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: Gaps.l, vertical: Gaps.s),
                      decoration: clayDecoration(context, color: context.colors.surfaceContainerLow, radius: 999),
                      child: Text(
                        '${_capitalize(context.game.season(season))} · ${context.game.dayTime(time)}',
                        style: context.texts.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const Spacer(),
                  ClayIconButton(
                    key: const ValueKey('open-glossary'),
                    icon: Icons.menu_book_rounded,
                    tooltip: context.l10n.glossaryTitle,
                    onPressed: () => Get.to<void>(() => const GlossaryPage()),
                  ),
                  const SizedBox(width: Gaps.s),
                  ClayIconButton(
                    key: const ValueKey('open-notebook-home'),
                    icon: Icons.bookmarks_rounded,
                    tooltip: context.l10n.notebookTitle,
                    onPressed: () => openNotebook(context),
                  ),
                ],
              ),
              const SizedBox(height: dioramaHeight - 120),
              _RankCard(xp: xp),
            ],
          ),
        ),
      ],
    );
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _RankCard extends StatelessWidget {
  final int xp;

  const _RankCard({required this.xp});

  @override
  Widget build(BuildContext context) {
    final rank = Rank.of(xp);
    final next = rank.next;
    final progress = next == null ? 1.0 : (xp - rank.minXp) / (next.minXp - rank.minXp);
    final tokens = context.druid;
    final onHero = tokens.onHero;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: tokens.heroGradient),
        boxShadow: [
          BoxShadow(
            color: tokens.clay ? tokens.clayShadow : tokens.heroGradient.first.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Gaps.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClayCircle(color: tokens.levelColor(4), icon: Icons.eco_rounded, size: 48),
                const SizedBox(width: Gaps.m),
                Expanded(
                  child: Text(context.game.rank(rank), style: context.texts.headlineSmall?.copyWith(color: onHero)),
                ),
                Text(context.l10n.xpTotal(xp), style: context.texts.titleMedium?.copyWith(color: onHero)),
              ],
            ),
            const SizedBox(height: Gaps.m),
            ClayProgressBar(
              value: progress,
              color: onHero,
              trackColor: onHero.withValues(alpha: 0.25),
              // La barra sta sulla scheda verde, non sulla pagina: l'incavo prende ombra e luce da lei.
              surface: tokens.heroGradient.first,
            ),
            const SizedBox(height: Gaps.s),
            Text(
              next == null ? context.l10n.maxRankReached : context.l10n.nextRank(context.game.rank(next), next.minXp),
              style: context.texts.bodySmall?.copyWith(color: onHero.withValues(alpha: 0.85)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FunFactCard extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final DateTime now;

  const _FunFactCard({required this.catalog, required this.state, required this.now});

  @override
  Widget build(BuildContext context) {
    final fact = funFactOfToday(catalog, state, now);
    final total = catalog.species.fold<int>(0, (sum, s) => sum + funFactsOf(s, catalog).length);
    return AccentCardBox(
      index: 1,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(Gaps.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ClayCircle(color: Color(0xFFF2D49B), icon: Icons.auto_awesome_rounded, size: 40),
                const SizedBox(width: Gaps.m),
                Expanded(child: Text(context.l10n.funOfDayTitle, style: context.texts.titleMedium)),
                Text(context.l10n.funOfDayCount(state.revealedFunFacts.length, total), style: context.texts.bodySmall),
              ],
            ),
            const SizedBox(height: Gaps.s),
            Text(fact == null ? context.l10n.funOfDayEmpty : context.game.funFact(fact)),
            if (fact is CuratedFunFactItem && !fact.verified) ...[
              const SizedBox(height: Gaps.xs),
              Text(context.l10n.funToVerify, style: context.texts.labelSmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final DateTime now;

  const _ReviewsCard({required this.catalog, required this.state, required this.now});

  @override
  Widget build(BuildContext context) {
    final due = dueFacts(catalog, state, now).length;
    return AccentCardBox(
      index: 2,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(Gaps.l),
        child: Row(
          children: [
            const ClayCircle(color: Color(0xFFBFD8C0), icon: Icons.replay_rounded, size: 40),
            const SizedBox(width: Gaps.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.reviewsTitle, style: context.texts.titleMedium),
                  const SizedBox(height: Gaps.xs),
                  Text(due == 0 ? context.l10n.reviewsNone : context.l10n.reviewsDue(due)),
                ],
              ),
            ),
            if (due > 0) ...[
              const SizedBox(width: Gaps.m),
              ClayButton(
                key: const ValueKey('start-review'),
                color: context.colors.primary,
                foreground: context.colors.onPrimary,
                onPressed: () {
                  if (Get.find<StudyController>().startReview(catalog)) Get.to<void>(() => const StudySessionPage());
                },
                label: context.l10n.reviewsStart,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DesiderataSection extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final DateTime now;
  final ProgressController progress;

  const _DesiderataSection({required this.catalog, required this.state, required this.now, required this.progress});

  @override
  Widget build(BuildContext context) {
    final marked = state.desiderata.map(catalog.speciesBySci).whereType<Species>().toList();
    final suggestions = desiderataSuggestions(catalog, state, now);
    final debug = Get.find<AppConfig>().showDebugTools;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClaySectionTitle(
          title: context.l10n.desiderataTitle,
          icon: Icons.star_rounded,
          color: const Color(0xFFF6D98B),
          trailing: Text(context.l10n.desiderataCount(marked.length, maxDesiderata)),
        ),
        const SizedBox(height: Gaps.s),
        if (marked.isEmpty) Text(context.l10n.desiderataEmpty, style: TextStyle(color: context.druid.hint)),
        for (final s in marked) ...[
          _DesiderataCard(
            species: s,
            onRemove: () => progress.toggleDesiderata(s.sci),
            onSimulateEncounter: debug ? () => progress.encounter(s.sci, method: EncounterMethod.simulated) : null,
          ),
          const SizedBox(height: Gaps.s),
        ],
        if (suggestions.isNotEmpty && canAddDesiderata(state)) ...[
          const SizedBox(height: Gaps.m),
          Text(context.l10n.desiderataSuggestions, style: context.texts.titleMedium),
          const SizedBox(height: Gaps.s),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: Gaps.s),
              itemBuilder: (context, i) =>
                  _SuggestionCard(species: suggestions[i], onAdd: () => progress.toggleDesiderata(suggestions[i].sci)),
            ),
          ),
        ],
      ],
    );
  }
}

class _DesiderataCard extends StatelessWidget {
  final Species species;
  final VoidCallback onRemove;
  final VoidCallback? onSimulateEncounter;

  const _DesiderataCard({required this.species, required this.onRemove, this.onSimulateEncounter});

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    return ClayCard(
      key: ValueKey('desiderata-${species.sci}'),
      padding: const EdgeInsets.all(Gaps.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(context.druid.cardRadius / 2),
            child: SizedBox(width: 84, height: 84, child: RemoteImage(species.images.first.url)),
          ),
          const SizedBox(width: Gaps.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(game.name(species), style: context.texts.titleMedium),
                Text(context.l10n.desiderataWhen(game.months(species.topMonths()))),
                Text(context.l10n.desiderataWhere(game.band(species.topBand))),
                Text(context.l10n.desiderataFamily(species.family), style: TextStyle(color: context.druid.hint)),
                Wrap(
                  spacing: Gaps.s,
                  children: [
                    TextButton(onPressed: onRemove, child: Text(context.l10n.desiderataRemove)),
                    if (onSimulateEncounter != null)
                      OutlinedButton.icon(
                        key: ValueKey('simulate-desiderata-${species.sci}'),
                        onPressed: onSimulateEncounter,
                        icon: const Icon(Icons.bug_report_outlined, size: 18),
                        label: Text(context.l10n.simulateEncounter),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final Species species;
  final VoidCallback onAdd;

  const _SuggestionCard({required this.species, required this.onAdd});

  @override
  Widget build(BuildContext context) => Padding(
    // Spazio per l'ombra della plastilina, che altrimenti la lista orizzontale taglia.
    padding: const EdgeInsets.only(bottom: Gaps.l),
    child: SizedBox(
      width: 150,
      child: ClayCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: RemoteImage(species.images.first.url)),
            Padding(
              padding: const EdgeInsets.all(Gaps.s),
              child: Text(context.game.name(species), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            TextButton.icon(
              key: ValueKey('add-desiderata-${species.sci}'),
              onPressed: onAdd,
              icon: const Icon(Icons.star_outline, size: 18),
              label: Text(context.l10n.desiderataAddShort),
            ),
          ],
        ),
      ),
    ),
  );
}

class _YourSpecies extends StatelessWidget {
  final Catalog catalog;
  final GameState state;

  const _YourSpecies({required this.catalog, required this.state});

  @override
  Widget build(BuildContext context) {
    final mine = catalog.species.where((s) => state.hasEncountered(s.sci)).toList()
      ..sort((a, b) => state.levelOf(a.sci).compareTo(state.levelOf(b.sci)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClaySectionTitle(title: context.l10n.yourSpecies, icon: Icons.eco_rounded, color: context.druid.levelColor(2)),
        if (mine.isEmpty) Text(context.l10n.yourSpeciesEmpty, style: TextStyle(color: context.druid.hint)),
        for (final s in mine)
          Padding(
            padding: const EdgeInsets.only(bottom: Gaps.m),
            child: ClayCard(
              key: ValueKey('my-${s.sci}'),
              padding: const EdgeInsets.symmetric(vertical: Gaps.xs),
              onTap: () => Get.to<void>(() => SpeciesPage(speciesSci: s.sci)),
              child: ListTile(
                leading: ClayCircle(
                  color: context.druid.levelColor(state.levelOf(s.sci)),
                  size: 42,
                  child: Text(
                    '${state.levelOf(s.sci)}',
                    style: context.texts.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                title: Text(context.game.name(s)),
                subtitle: Text(levelName(context.l10n, state.levelOf(s.sci))),
                trailing: _StudyButton(catalog: catalog, state: state, species: s),
              ),
            ),
          ),
      ],
    );
  }
}

class _StudyButton extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final Species species;

  const _StudyButton({required this.catalog, required this.state, required this.species});

  @override
  Widget build(BuildContext context) {
    final level = nextStudyLevel(species, catalog, state);
    if (level == null) return const Icon(Icons.check_circle_outline);
    return ClayButton(
      key: ValueKey('study-${species.sci}'),
      color: context.colors.primaryContainer,
      foreground: context.colors.onPrimaryContainer,
      onPressed: () => startLevelStudy(catalog, species.sci, level),
      label: context.l10n.studyLevelButton(level),
    );
  }
}

/// Avvia lo studio di un livello e apre la sessione.
void startLevelStudy(Catalog catalog, String speciesSci, int level) {
  Get.find<StudyController>().startLevel(catalog, speciesSci, level);
  Get.to<void>(() => const StudySessionPage());
}
