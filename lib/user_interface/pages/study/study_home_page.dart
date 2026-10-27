import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/onboarding.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
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
import 'package:druid_app/user_interface/common_widgets/species_name.dart';
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
                _YourSpecies(catalog: catalog, state: state, progress: progress),
                const SizedBox(height: Gaps.xl),
                _TipCard(now: now),
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
        _SpeciesCarousel(
          children: [
            for (final species in suggestions)
              _SpeciesCard(
                key: ValueKey('seasonal-${species.sci}'),
                species: species,
                studyKey: ValueKey('study-suggestion-${species.sci}'),
                studyLabel: context.l10n.seasonalStudy,
                onStudy: () => startLevelStudy(catalog, species.sci, nextStudyLevel(species, catalog, state) ?? 1),
                marked: state.desiderata.contains(species.sci),
                onToggleDesiderata: () => progress.toggleDesiderata(species.sci),
              ),
          ],
        ),
      ],
    );
  }
}

/// Una riga di schede di specie che scorre in orizzontale: "In stagione adesso" e "Le tue specie" (stesse schede, filtro
/// diverso: decisione del 2026-10-27).
class _SpeciesCarousel extends StatelessWidget {
  final List<Widget> children;

  const _SpeciesCarousel({required this.children});

  @override
  Widget build(BuildContext context) => SizedBox(
    // Più margine in verticale che in orizzontale: sopra e sotto le schede c'è posto per luce e ombra.
    height: 250 + Gaps.l + Gaps.s,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      // Le schede escono dal margine della pagina mentre scorrono, ma partono allineate al contenuto.
      clipBehavior: Clip.none,
      padding: const EdgeInsets.only(top: Gaps.l, bottom: Gaps.s),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(width: Gaps.m),
      itemBuilder: (context, i) => children[i],
    ),
  );
}

/// La scheda di una specie nelle righe della Home: foto, nome, Studia e la stella delle desiderata. Con [level] il
/// cerchietto del livello sulla foto e una riga con livello e incontro (le tue specie).
class _SpeciesCard extends StatelessWidget {
  final Species species;
  final Key studyKey;
  final String studyLabel;

  /// `null` = tutti i livelli superati: al posto del pulsante un segno di spunta.
  final VoidCallback? onStudy;
  final bool marked;

  /// `null` se le desiderata sono già al completo; [showStar] falso per le specie già incontrate.
  final VoidCallback? onToggleDesiderata;
  final bool showStar;
  final int? level;
  final String? subtitle;

  const _SpeciesCard({
    super.key,
    required this.species,
    required this.studyKey,
    required this.studyLabel,
    required this.onStudy,
    required this.marked,
    required this.onToggleDesiderata,
    this.showStar = true,
    this.level,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Padding(
    // Spazio per l'ombra della plastilina, che altrimenti la lista orizzontale taglia.
    padding: const EdgeInsets.only(bottom: Gaps.l),
    child: SizedBox(
      width: 150,
      child: ClayCard(
        padding: EdgeInsets.zero,
        onTap: () => Get.to<void>(() => SpeciesPage(speciesSci: species.sci)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RemoteImage(species.images.first.url),
                  // Sulla foto il cerchietto del livello sta su un tondo color pagina, altrimenti non si legge.
                  if (level != null)
                    Positioned(
                      left: Gaps.s,
                      top: Gaps.s,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: context.colors.surfaceContainerLow, shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: LevelMark(level: level, size: 28, surface: context.colors.surfaceContainerLow),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.s, Gaps.s, Gaps.s, 0),
              child: Text(
                context.game.name(species),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: speciesNameStyle(context, DefaultTextStyle.of(context).style, green: false),
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gaps.s),
                child: Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall?.copyWith(color: context.druid.hint),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: onStudy == null
                      ? const Padding(padding: EdgeInsets.all(Gaps.m), child: Icon(Icons.check_circle_outline))
                      : TextButton(
                          key: studyKey,
                          onPressed: onStudy,
                          child: Text(studyLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                ),
                if (showStar)
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
  final ProgressController progress;

  const _YourSpecies({required this.catalog, required this.state, required this.progress});

  @override
  Widget build(BuildContext context) {
    final inStudy = speciesInStudy(state);
    final mine = catalog.species.where((s) => inStudy.contains(s.sci)).toList()
      ..sort((a, b) => state.levelOf(a.sci).compareTo(state.levelOf(b.sci)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClaySectionTitle(title: context.l10n.yourSpecies, icon: Icons.eco_rounded, color: context.druid.levelColor(2)),
        if (mine.isEmpty)
          Text(context.l10n.yourSpeciesEmpty, style: TextStyle(color: context.druid.hint))
        else
          _SpeciesCarousel(
            children: [
              for (final s in mine)
                _SpeciesCard(
                  key: ValueKey('my-${s.sci}'),
                  species: s,
                  level: state.levelOf(s.sci),
                  subtitle:
                      '${levelName(context.l10n, state.levelOf(s.sci))} · '
                      '${state.hasEncountered(s.sci) ? context.l10n.yourSpeciesMet : context.l10n.notEncounteredYet}',
                  studyKey: ValueKey('study-${s.sci}'),
                  studyLabel: switch (nextStudyLevel(s, catalog, state)) {
                    final int level => context.l10n.studyLevelButton(level),
                    null => '',
                  },
                  onStudy: switch (nextStudyLevel(s, catalog, state)) {
                    final int level => () => startLevelStudy(catalog, s.sci, level),
                    null => null,
                  },
                  // La stella solo per quelle da incontrare: le desiderata servono a trovarle.
                  showStar: !state.hasEncountered(s.sci),
                  marked: state.desiderata.contains(s.sci),
                  onToggleDesiderata: () => progress.toggleDesiderata(s.sci),
                ),
            ],
          ),
      ],
    );
  }
}

/// Avvia lo studio di un livello e apre la sessione.
void startLevelStudy(Catalog catalog, String speciesSci, int level) {
  Get.find<StudyController>().startLevel(catalog, speciesSci, level);
  Get.to<void>(() => const StudySessionPage());
}

/// Il consiglio del giorno: una frase su come si gioca, a rotazione (uno al giorno, uguale per tutto il giorno). Prende
/// il posto della curiosità del giorno finché non si decide cosa mostrare delle curiosità e come (2026-10-27).
class _TipCard extends StatelessWidget {
  final DateTime now;

  const _TipCard({required this.now});

  @override
  Widget build(BuildContext context) {
    final tips = context.game.tips;
    final day = DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    return AccentCardBox(
      key: const ValueKey('tip-of-day'),
      index: 1,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(Gaps.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ClayCircle(color: Color(0xFFF2D49B), icon: Icons.lightbulb_outline_rounded, size: 40),
                const SizedBox(width: Gaps.m),
                Expanded(child: Text(context.l10n.tipOfDayTitle, style: context.texts.titleMedium)),
              ],
            ),
            const SizedBox(height: Gaps.s),
            Text(tips[day % tips.length]),
          ],
        ),
      ),
    );
  }
}
