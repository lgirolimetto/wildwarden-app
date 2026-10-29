import 'package:druid_app/business_logic/rules/field/stations.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/erbario_views.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/business_logic/rules/tutorial.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
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

/// Erbario della zona: tutte le specie con foto e nome, prima le incontrate e poi quelle da trovare, in un vassoio solo
/// filtrato dalla vista scelta (le viste già pronte, tra cui "Incontrate", e quelle salvate dall'utente). Le tessere
/// dicono già se una specie è incontrata (decisione del 2026-10-27: due vassoi ripetevano un filtro).
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
    (double, Widget) metTile(Species s) => (
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
          photo: firstPhotoOf(state, s.sci)?.photo,
        ),
      ),
    );
    (double, Widget) unknownTile(Species s) => (
      // Foto + nome (+ "Studia"); lo scudo delle protette sta sulla foto.
      1 / tileAspect(s) + 0.3 + (study(s) == null ? 0 : 0.2),
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
    );
    // Le aromatiche del tutorial: un vassoio loro, solo durante il tutorial o quando ne hai Incontrata o studiata una.
    final kitchen = [
      for (final s in catalog.kitchen)
        if (tutorialStatus(state) == TutorialStatus.inProgress ||
            state.hasEncountered(s.sci) ||
            state.levelOf(s.sci) > 0)
          s,
    ];

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
                trailing: Pill(
                  context.l10n.erbarioFound(
                    catalog.species.where((s) => state.hasEncountered(s.sci)).length,
                    catalog.species.length,
                  ),
                ),
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
        if (encountered.isNotEmpty || missing.isNotEmpty)
          _Tray(
            // La vista scelta è già nella linguetta: qui solo quante specie mostra.
            title: context.l10n.erbarioSpecies,
            icon: Icons.eco_rounded,
            // Nelle livree neumorfiche il vassoio riprende le schede delle ricette ("Base", la più chiara).
            color: context.druid.neu
                ? context.druid.accent(2).background
                : Color.lerp(context.druid.levelColor(2), context.colors.surface, 0.55)!,
            orbColor: context.druid.levelColor(2),
            tiles: [for (final s in encountered) metTile(s), for (final s in missing) unknownTile(s)],
          ),
        if (kitchen.isNotEmpty)
          _Tray(
            key: const ValueKey('kitchen-tray'),
            title: context.l10n.erbarioKitchen,
            icon: Icons.soup_kitchen_outlined,
            color: context.druid.neu
                ? context.druid.accent(1).background
                : Color.lerp(context.druid.levelColor(1), context.colors.surface, 0.55)!,
            orbColor: context.druid.levelColor(1),
            tiles: [for (final s in kitchen) state.hasEncountered(s.sci) ? metTile(s) : unknownTile(s)],
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

  /// Tessere con la loro altezza stimata (in larghezze di tessera), per distribuirle nelle colonne.
  final List<(double, Widget)> tiles;

  const _Tray({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.orbColor,
    required this.tiles,
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
              child: ClaySectionTitle(
                title: title,
                icon: icon,
                color: orbColor,
                trailing: Text('${tiles.length}', style: context.texts.titleMedium),
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
