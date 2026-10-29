import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/essence.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/engraved_icon.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/common_widgets/species_name.dart';
import 'package:druid_app/user_interface/common_widgets/vis_badge.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// La Dispensa, la seconda linguetta del Laboratorio: le Essenze attinte con Vis, purezza e Qualia, per specie (la
/// specie attinta più di recente in cima). Le Essenze finite (0 Vis) non si mostrano.
class PantryView extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final Widget header;

  const PantryView({super.key, required this.catalog, required this.state, required this.header});

  @override
  Widget build(BuildContext context) {
    // Dalla più recente: le specie per l'ultima Essenza attinta, le Essenze di una specie per data.
    final recent = [
      for (final e in state.essences)
        if (e.vis > 0) e,
    ]..sort((a, b) => b.drawnAt.compareTo(a.drawnAt));
    final bySpecies = <String, List<Essence>>{};
    for (final e in recent) {
      (bySpecies[e.speciesSci] ??= []).add(e);
    }
    return ListView(
      key: const ValueKey('pantry'),
      padding: EdgeInsets.fromLTRB(Gaps.l, MediaQuery.paddingOf(context).top + Gaps.l, Gaps.l, homeBottomInset),
      children: [
        header,
        const SizedBox(height: Gaps.l),
        if (bySpecies.isEmpty)
          Text(
            context.l10n.pantryEmpty,
            key: const ValueKey('pantry-empty'),
            style: TextStyle(color: context.druid.hint),
          ),
        for (final MapEntry(key: sci, value: essences) in bySpecies.entries) ...[
          RepaintBoundary(
            child: _SpeciesShelf(catalog: catalog, speciesSci: sci, essences: essences),
          ),
          const SizedBox(height: Gaps.m),
        ],
      ],
    );
  }
}

/// Le Essenze di una specie: foto, nome e Vis in tutto, poi una riga per Essenza.
class _SpeciesShelf extends StatelessWidget {
  final Catalog catalog;
  final String speciesSci;
  final List<Essence> essences;

  const _SpeciesShelf({required this.catalog, required this.speciesSci, required this.essences});

  @override
  Widget build(BuildContext context) {
    final species = catalog.speciesBySci(speciesSci);
    final vis = essences.fold(0, (sum, e) => sum + e.vis);
    return ClayCard(
      key: ValueKey('pantry-$speciesSci'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.square(
                  dimension: 48,
                  child: species == null || species.images.isEmpty
                      ? const SizedBox.shrink()
                      : RemoteImage(species.images.first.url),
                ),
              ),
              const SizedBox(width: Gaps.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      species == null ? speciesSci : context.game.name(species),
                      style: speciesNameStyle(context, context.texts.titleMedium),
                    ),
                    Text(
                      context.l10n.pantrySpeciesSummary(essences.length, vis),
                      style: context.texts.bodySmall?.copyWith(color: context.druid.hint),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Gaps.s),
          // Le Essenze come piccole card, una accanto all'altra, a capo quando finisce lo spazio (2026-10-29).
          Wrap(
            spacing: Gaps.s,
            runSpacing: Gaps.s,
            children: [for (final e in essences) _EssenceCard(essence: e)],
          ),
        ],
      ),
    );
  }
}

/// Un'Essenza, una piccola card (capitolo 02, 2026-10-29): in testa la data (con l'anno solo se non è quello in corso);
/// poi la Vis come nel Ricettario (il fulmine con le Vis nel badge) con sotto la purezza, una barretta oro; sotto le
/// icone delle Qualia.
class _EssenceCard extends StatelessWidget {
  final Essence essence;

  const _EssenceCard({required this.essence});

  @override
  Widget build(BuildContext context) {
    final hint = context.texts.bodySmall?.copyWith(color: context.druid.hint);
    final lang = context.contentLanguage;
    final drawn = essence.drawnAt;
    final date = drawn.year == Get.find<ProgressController>().now.year
        ? DateFormat.MMMd(lang).format(drawn)
        : DateFormat.yMMMd(lang).format(drawn);
    final traits = [
      for (final t in essence.traits)
        if (Trait.values.asNameMap()[t] case final Trait trait) trait,
    ];
    final purity = (essence.purity * 100).round();
    final color = context.colors.onSurface;
    return pillFrame(
      context,
      const EdgeInsets.all(Gaps.s),
      Column(
        key: ValueKey('essence-${essence.index}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(date, style: hint),
          const SizedBox(height: Gaps.xs),
          VisBadge(essence.vis),
          const SizedBox(height: Gaps.xs),
          Tooltip(
            message: context.l10n.pantryPurity(purity),
            child: Semantics(
              label: context.l10n.pantryPurity(purity),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  width: 40,
                  height: 5,
                  child: LinearProgressIndicator(
                    value: essence.purity.clamp(0.0, 1.0),
                    backgroundColor: context.druid.hint.withValues(alpha: 0.2),
                    color: context.druid.purityColor,
                  ),
                ),
              ),
            ),
          ),
          if (traits.isNotEmpty) ...[
            const SizedBox(height: Gaps.s),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (i, t) in traits.indexed) ...[
                  if (i > 0) const SizedBox(width: Gaps.xs),
                  QualiaIcon(label: context.game.trait(t)),
                ],
              ],
            ),
          ],
        ],
      ),
      BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      radius: BorderRadius.circular(16),
    );
  }
}
