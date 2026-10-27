import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/essence.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// La Dispensa, la seconda linguetta del Laboratorio: le Essenze attinte con tratti, purezza e Vis, per specie (la
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
                    Text(species == null ? speciesSci : context.game.name(species), style: context.texts.titleMedium),
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
          for (final (i, e) in essences.indexed) ...[if (i > 0) const Divider(height: Gaps.l), _EssenceRow(essence: e)],
        ],
      ),
    );
  }
}

/// Un'Essenza: quando, i tratti come pillole, purezza e Vis.
class _EssenceRow extends StatelessWidget {
  final Essence essence;

  const _EssenceRow({required this.essence});

  @override
  Widget build(BuildContext context) {
    final hint = context.texts.bodySmall?.copyWith(color: context.druid.hint);
    final traits = [
      for (final t in essence.traits)
        if (Trait.values.asNameMap()[t] case final Trait trait) trait,
    ];
    return Column(
      key: ValueKey('essence-${essence.index}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(DateFormat.MMMd(context.contentLanguage).format(essence.drawnAt), style: hint),
            const SizedBox(width: Gaps.m),
            Expanded(
              child: Text(
                '${context.l10n.pantryPurity((essence.purity * 100).round())} · ${context.l10n.pantryVis(essence.vis)}',
                style: context.texts.labelLarge,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: Gaps.xs),
        if (traits.isEmpty)
          Text(context.l10n.pantryNoTraits, style: hint)
        else
          Wrap(spacing: Gaps.s, runSpacing: Gaps.s, children: [for (final t in traits) Pill(context.game.trait(t))]),
      ],
    );
  }
}
