import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/erbario_views.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/mystery_cover.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/controllers/erbario/erbario_views_controller.dart';
import 'package:druid_app/user_interface/pages/erbario/widgets/erbario_views_bar.dart';
import 'package:druid_app/user_interface/pages/erbario/widgets/species_tile.dart';
import 'package:druid_app/user_interface/pages/species/species_page.dart';
import 'package:druid_app/user_interface/pages/study/study_home_page.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Erbario della zona: tutte le specie con foto e nome, prima le incontrate e poi quelle da trovare, filtrate dalla
/// vista scelta (le viste già pronte e quelle salvate dall'utente).
class ErbarioPage extends StatelessWidget {
  const ErbarioPage({super.key});

  @override
  Widget build(BuildContext context) => GameDataBuilder(
    builder: (context, catalog, state, progress) => GetBuilder<ErbarioViewsController>(
      builder: (views) => _ErbarioContent(
        catalog: catalog,
        state: state,
        filter: views.filter,
        now: progress.now,
        onSimulateEncounter: Get.find<AppConfig>().showDebugTools
            ? (sci) => progress.encounter(sci, method: EncounterMethod.simulated)
            : null,
      ),
    ),
  );
}

class _ErbarioContent extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final ErbarioFilter filter;
  final DateTime now;
  final void Function(String sci)? onSimulateEncounter;

  const _ErbarioContent({
    required this.catalog,
    required this.state,
    required this.filter,
    required this.now,
    required this.onSimulateEncounter,
  });

  @override
  Widget build(BuildContext context) {
    final shown = catalog.species.where((s) => filter.matches(s, state, now));
    final encountered = shown.where((s) => state.hasEncountered(s.sci)).toList()
      ..sort((a, b) => state.firstEncounters[b.sci]!.compareTo(state.firstEncounters[a.sci]!));
    final missing = shown.where((s) => !state.hasEncountered(s.sci)).toList();
    // Ogni specie ha 5 pagine: l'incontro e i 4 livelli. Si contano tutte, non solo quelle della vista.
    final pages = catalog.species
        .where((s) => state.hasEncountered(s.sci))
        .fold<int>(0, (sum, s) => sum + 1 + state.levelOf(s.sci));
    void open(String sci) => Get.to<void>(() => SpeciesPage(speciesSci: sci));
    VoidCallback? study(Species s) => switch (nextStudyLevel(s, catalog, state)) {
      final level? => () => startLevelStudy(catalog, s.sci, level),
      null => null,
    };

    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.l),
            sliver: SliverToBoxAdapter(
              child: ClayPageHeader(
                title: context.l10n.erbarioTitle,
                subtitle: context.l10n.erbarioPages(pages, catalog.species.length * 5),
                icon: Icons.menu_book_rounded,
                iconColor: context.druid.levelColor(1),
                trailing: Pill(context.l10n.erbarioFound(state.encounteredCount, catalog.species.length)),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: ErbarioViewsBar(catalog: catalog)),
        if (encountered.isEmpty && missing.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(Gaps.l),
            sliver: SliverToBoxAdapter(
              child: Text(
                context.l10n.viewEmpty,
                key: const ValueKey('view-empty'),
                style: TextStyle(color: context.druid.hint),
              ),
            ),
          ),
        if (encountered.isNotEmpty)
          _Tray(
            title: context.l10n.erbarioEncounteredSection,
            icon: Icons.eco_rounded,
            // Nelle livree neumorfiche i vassoi riprendono le schede delle ricette: trovate come "Base" (la più
            // chiara), da trovare come "Intermedia".
            color: context.druid.neu
                ? context.druid.accent(2).background
                : Color.lerp(context.druid.levelColor(2), context.colors.surface, 0.55)!,
            orbColor: context.druid.levelColor(2),
            tiles: [
              for (final s in encountered)
                (
                  // Altezza stimata, in larghezze di tessera: foto + nome, timbro e livello (+ "Studia").
                  1 / tileAspect(s) + 0.6 + (study(s) == null ? 0 : 0.2),
                  GestureDetector(
                    onTap: () => open(s.sci),
                    child: EncounteredSpeciesTile(
                      key: ValueKey('met-${s.sci}'),
                      species: s,
                      level: state.levelOf(s.sci),
                      encounteredAt: state.firstEncounters[s.sci],
                      onStudy: study(s),
                    ),
                  ),
                ),
            ],
          ),
        if (missing.isNotEmpty)
          _Tray(
            title: context.l10n.erbarioMissingSection,
            icon: Icons.search_rounded,
            // Di giorno verde bosco, lo stesso del tassello "?" delle copertine, con le tessere crema; di sera verde
            // bosco più profondo, un po' più chiaro delle tessere verde notte. Titolo crema in entrambi.
            color: context.druid.neu
                ? context.druid.accent(0).background
                : Theme.of(context).brightness == Brightness.light
                ? mysteryTileColor(context)
                : Color.lerp(context.colors.primaryContainer, Colors.black, 0.2)!,
            foreground: context.druid.neu ? null : context.druid.onHero,
            orbColor: context.druid.levelColor(4),
            tiles: [
              for (final s in missing)
                (
                  // Foto + nome (+ bollino "protetta", + "Studia").
                  1 / tileAspect(s) + 0.3 + (s.isProtected ? 0.2 : 0) + (study(s) == null ? 0 : 0.2),
                  GestureDetector(
                    onTap: () => open(s.sci),
                    child: UnknownSpeciesTile(
                      key: ValueKey('unknown-${s.sci}'),
                      species: s,
                      level: state.levelOf(s.sci),
                      onStudy: study(s),
                      onSimulateEncounter: onSimulateEncounter == null ? null : () => onSimulateEncounter!(s.sci),
                    ),
                  ),
                ),
            ],
          ),
        const SliverToBoxAdapter(child: SizedBox(height: homeBottomInset)),
      ],
    );
  }
}

/// Vassoio in plastilina di una sezione dell'erbario: titolo con la sua sfera e, dentro, le tessere delle specie.
class _Tray extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color orbColor;

  /// Colore del titolo e del conteggio, se il vassoio è scuro.
  final Color? foreground;

  /// Tessere con la loro altezza stimata (in larghezze di tessera), per distribuirle nelle colonne.
  final List<(double, Widget)> tiles;

  const _Tray({
    required this.title,
    required this.icon,
    required this.color,
    required this.orbColor,
    required this.tiles,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(Gaps.l, Gaps.s, Gaps.l, Gaps.l),
    sliver: SliverToBoxAdapter(
      child: ClayCard(
        color: color,
        padding: const EdgeInsets.all(Gaps.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.xs, Gaps.xs, Gaps.xs, Gaps.s),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: foreground),
                child: ClaySectionTitle(
                  title: title,
                  titleColor: foreground,
                  icon: icon,
                  color: orbColor,
                  trailing: Text('${tiles.length}', style: context.texts.titleMedium?.copyWith(color: foreground)),
                ),
              ),
            ),
            _Masonry(tiles: tiles),
          ],
        ),
      ),
    ),
  );
}

/// Disposizione a mattoncini: colonne di uguale larghezza, ogni tessera alta quanto le serve. Ogni tessera va nella
/// colonna più bassa (secondo l'altezza stimata), così le colonne finiscono quasi pari. Le specie di una zona sono
/// poche decine: le tessere si costruiscono tutte, senza caricamento pigro. Ognuna però ha il suo RepaintBoundary:
/// senza, a ogni frame dello scroll si ridipingevano tutte, anche quelle fuori schermo (issue #15).
class _Masonry extends StatelessWidget {
  final List<(double, Widget)> tiles;

  const _Masonry({required this.tiles});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final count = (constraints.maxWidth / 190).floor().clamp(2, 6);
      final columns = List.generate(count, (_) => <Widget>[]);
      final heights = List.filled(count, 0.0);
      for (final (height, tile) in tiles) {
        var target = 0;
        for (var i = 1; i < count; i++) {
          if (heights[i] < heights[target]) target = i;
        }
        columns[target].add(
          Padding(
            // Tra una tessera e l'altra più spazio in verticale che in orizzontale, per il rilievo.
            padding: const EdgeInsets.only(bottom: Gaps.l),
            child: RepaintBoundary(child: tile),
          ),
        );
        heights[target] += height;
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, column) in columns.indexed) ...[
            if (i > 0) const SizedBox(width: Gaps.m),
            Expanded(child: Column(children: column)),
          ],
        ],
      );
    },
  );
}
