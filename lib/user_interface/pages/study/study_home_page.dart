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
import 'package:druid_app/user_interface/common_widgets/status_bar_scrim.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/erbario/level_name.dart';
import 'package:druid_app/user_interface/pages/settings/settings_page.dart';
import 'package:druid_app/user_interface/pages/notebook/notebook_page.dart';
import 'package:druid_app/user_interface/pages/species/species_page.dart';
import 'package:druid_app/user_interface/pages/study/study_session_page.dart';
import 'package:druid_app/user_interface/pages/study/widgets/mission_banner.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudyHomePage extends StatefulWidget {
  const StudyHomePage({super.key});

  @override
  State<StudyHomePage> createState() => _StudyHomePageState();
}

class _StudyHomePageState extends State<StudyHomePage> {
  /// Opacità del velo sotto la barra di stato: compare quando il cielo del diorama è uscito dallo schermo.
  double _scrim = 0;

  static double _scrimFor(double offset) => ((offset - _DioramaHeader.dioramaHeight * 0.6) / 60).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      NotificationListener<ScrollUpdateNotification>(
        onNotification: (n) {
          // Si ricostruisce solo quando il velo cambia, non a ogni pixel di scorrimento.
          final scrim = _scrimFor(n.metrics.pixels);
          if (n.depth == 0 && n.metrics.axis == Axis.vertical && scrim != _scrim) setState(() => _scrim = scrim);
          return false;
        },
        child: _content(context),
      ),
      StatusBarScrim(color: context.druid.backgroundGradient.first, opacity: _scrim),
    ],
  );

  Widget _content(BuildContext context) => GameDataBuilder(
    builder: (context, catalog, state, progress) {
      // La curiosità del giorno si consegna all'apertura (l'operazione non fa nulla se è già stata data).
      WidgetsBinding.instance.addPostFrameCallback((_) => progress.revealTodayFunFact());
      final now = progress.now;
      final mission = currentMission(state, catalog);
      return ListView(
        key: const ValueKey('study-home-list'),
        padding: const EdgeInsets.only(bottom: homeBottomInset),
        children: [
          _DioramaHeader(now: now, xp: state.xp, xpToCash: state.xpToCash),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (mission != null) ...[
                  const SizedBox(height: Gaps.l),
                  MissionBanner(mission: mission, catalog: catalog, state: state, now: now),
                ],
                const SizedBox(height: Gaps.xl),
                _SeasonalSection(catalog: catalog, state: state, now: now, progress: progress),
                if (dueFacts(catalog, state, now).isNotEmpty) ...[
                  const SizedBox(height: Gaps.l),
                  _ReviewsCard(catalog: catalog, state: state, now: now),
                ],
                const SizedBox(height: Gaps.xl),
                _YourSpecies(catalog: catalog, state: state),
                const SizedBox(height: Gaps.xl),
                _DesiderataSection(catalog: catalog, state: state, progress: progress),
                const SizedBox(height: Gaps.xl),
                _FunFactCard(catalog: catalog, state: state, now: now),
              ],
            ),
          ),
        ],
      );
    },
  );
}

/// Testata della pagina Studio: il diorama della stagione e del momento del giorno, con la barra integrata
/// (stagione, impostazioni, taccuino; legenda e glossario si aprono dalle impostazioni) e la scheda del titolo
/// appoggiata sul bordo inferiore.
class _DioramaHeader extends StatelessWidget {
  static const dioramaHeight = 300.0;
  final DateTime now;
  final int xp;
  final int xpToCash;

  const _DioramaHeader({required this.now, required this.xp, required this.xpToCash});

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
                    key: const ValueKey('open-settings'),
                    icon: Icons.tune_rounded,
                    tooltip: context.l10n.settingsTitle,
                    onPressed: () => Get.to<void>(() => const SettingsPage()),
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
              _RankCard(xp: xp, xpToCash: xpToCash),
            ],
          ),
        ),
      ],
    );
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Rango e PE di carriera; sotto, ben visibili, i PE virtuali ancora da incassare.
class _RankCard extends StatelessWidget {
  final int xp;
  final int xpToCash;

  const _RankCard({required this.xp, required this.xpToCash});

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
                // Sulla scheda verde del rango l'icona incisa è chiara, con luce e ombra ricavate dalla scheda.
                ClayCircle(
                  color: tokens.levelColor(4),
                  icon: Icons.eco_rounded,
                  size: 48,
                  surface: tokens.heroGradient.first,
                ),
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
            if (xpToCash > 0) ...[
              const SizedBox(height: Gaps.s),
              Row(
                key: const ValueKey('xp-to-cash'),
                children: [
                  Icon(Icons.hourglass_top_rounded, size: 18, color: onHero),
                  const SizedBox(width: Gaps.xs),
                  Expanded(
                    child: Text(
                      context.l10n.xpToCash(xpToCash),
                      style: context.texts.bodyMedium?.copyWith(color: onHero, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
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

/// Le desiderata segnate (al massimo [maxDesiderata]). Si scelgono dal carosello "In stagione adesso" o
/// dall'erbario.
class _DesiderataSection extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final ProgressController progress;

  const _DesiderataSection({required this.catalog, required this.state, required this.progress});

  @override
  Widget build(BuildContext context) {
    final marked = state.desiderata.map(catalog.speciesBySci).whereType<Species>().toList();
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
        if (marked.isEmpty) Text(context.l10n.desiderataEmpty, style: TextStyle(color: context.druid.hint)),
        for (final s in marked) ...[
          _DesiderataCard(
            species: s,
            onRemove: () => progress.toggleDesiderata(s.sci),
            onSimulateEncounter: debug ? () => progress.encounter(s.sci, method: EncounterMethod.simulated) : null,
          ),
          const SizedBox(height: Gaps.l),
        ],
      ],
    );
  }
}

/// "In stagione adesso": specie da cominciare a studiare, con la stellina per segnarle come desiderata. Al primo
/// avvio sono le 3 specie proposte per iniziare subito, anche da casa.
class _SeasonalSection extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final DateTime now;
  final ProgressController progress;

  const _SeasonalSection({required this.catalog, required this.state, required this.now, required this.progress});

  @override
  Widget build(BuildContext context) {
    final suggestions = seasonalSuggestions(catalog, state, now);
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClaySectionTitle(
          title: context.l10n.desiderataSuggestions,
          icon: Icons.local_florist_rounded,
          color: context.druid.levelColor(1),
        ),
        Text(
          speciesInStudy(state).isEmpty ? context.l10n.seasonalFirstHint : context.l10n.seasonalHint,
          style: TextStyle(color: context.druid.hint),
        ),
        SizedBox(
          // Più margine in verticale che in orizzontale: sopra e sotto le schede c'è posto per luce e ombra.
          height: 250 + Gaps.l + Gaps.s,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // Le schede escono dal margine della pagina mentre scorrono, ma partono allineate al contenuto.
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(top: Gaps.l, bottom: Gaps.s),
            itemCount: suggestions.length,
            separatorBuilder: (_, _) => const SizedBox(width: Gaps.m),
            itemBuilder: (context, i) {
              final species = suggestions[i];
              final marked = state.desiderata.contains(species.sci);
              return _SuggestionCard(
                species: species,
                onStudy: () => startLevelStudy(catalog, species.sci, nextStudyLevel(species, catalog, state) ?? 1),
                marked: marked,
                onToggleDesiderata: marked || canAddDesiderata(state)
                    ? () => progress.toggleDesiderata(species.sci)
                    : null,
              );
            },
          ),
        ),
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
                  spacing: Gaps.chip,
                  runSpacing: Gaps.chipRun,
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
  final VoidCallback onStudy;
  final bool marked;

  /// `null` se le desiderata sono già al completo.
  final VoidCallback? onToggleDesiderata;

  const _SuggestionCard({
    required this.species,
    required this.onStudy,
    required this.marked,
    required this.onToggleDesiderata,
  });

  @override
  Widget build(BuildContext context) => Padding(
    // Spazio per l'ombra della plastilina, che altrimenti la lista orizzontale taglia.
    padding: const EdgeInsets.only(bottom: Gaps.l),
    child: SizedBox(
      width: 150,
      child: ClayCard(
        key: ValueKey('seasonal-${species.sci}'),
        padding: EdgeInsets.zero,
        onTap: () => Get.to<void>(() => SpeciesPage(speciesSci: species.sci)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: RemoteImage(species.images.first.url)),
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.s, Gaps.s, Gaps.s, 0),
              child: Text(context.game.name(species), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    key: ValueKey('study-suggestion-${species.sci}'),
                    onPressed: onStudy,
                    child: Text(context.l10n.seasonalStudy),
                  ),
                ),
                IconButton(
                  key: ValueKey('add-desiderata-${species.sci}'),
                  tooltip: marked ? context.l10n.desiderataRemove : context.l10n.desiderataAdd,
                  onPressed: onToggleDesiderata,
                  icon: Icon(marked ? Icons.star_rounded : Icons.star_outline_rounded),
                ),
              ],
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
    final inStudy = speciesInStudy(state);
    final mine = catalog.species.where((s) => inStudy.contains(s.sci)).toList()
      ..sort((a, b) => state.levelOf(a.sci).compareTo(state.levelOf(b.sci)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClaySectionTitle(title: context.l10n.yourSpecies, icon: Icons.eco_rounded, color: context.druid.levelColor(2)),
        if (mine.isEmpty) Text(context.l10n.yourSpeciesEmpty, style: TextStyle(color: context.druid.hint)),
        for (final s in mine)
          Padding(
            padding: const EdgeInsets.only(bottom: Gaps.l),
            child: ClayCard(
              key: ValueKey('my-${s.sci}'),
              padding: const EdgeInsets.symmetric(vertical: Gaps.xs),
              onTap: () => Get.to<void>(() => SpeciesPage(speciesSci: s.sci)),
              child: ListTile(
                leading: LevelMark(level: state.levelOf(s.sci)),
                title: Text(context.game.name(s)),
                subtitle: Text(
                  '${levelName(context.l10n, state.levelOf(s.sci))} · '
                  '${state.hasEncountered(s.sci) ? context.l10n.yourSpeciesMet : context.l10n.notEncounteredYet}',
                ),
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
