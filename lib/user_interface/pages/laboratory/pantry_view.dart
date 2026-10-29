import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/essence.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/harvest.dart';
import 'package:druid_app/business_logic/rules/recipes/potion_effects.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/engraved_icon.dart';
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
          for (final (i, e) in essences.indexed) ...[if (i > 0) const Divider(height: Gaps.l), _EssenceRow(essence: e)],
        ],
      ),
    );
  }
}

/// Un'Essenza (capitolo 02, 2026-10-29): in alto la data (con l'anno solo se non è quello in corso); sotto la Vis, con
/// l'anello oro della purezza intorno all'icona, la barretta e il numero, poi le icone delle Qualia.
class _EssenceRow extends StatelessWidget {
  final Essence essence;

  const _EssenceRow({required this.essence});

  /// La barretta è piena al massimo che dà un Attingere (con l'Abbondanza al massimo).
  static final _fullVis = visWithAbundance(visPerDraw, 10);

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
    return Column(
      key: ValueKey('essence-${essence.index}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(date, style: hint),
        const SizedBox(height: Gaps.xs),
        Row(
          children: [
            Tooltip(
              message: context.l10n.pantryPurity(purity),
              child: _PurityChip(purity: essence.purity, semanticLabel: context.l10n.pantryPurity(purity)),
            ),
            const SizedBox(width: Gaps.s),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                width: 48,
                height: 6,
                child: LinearProgressIndicator(
                  value: (essence.vis / _fullVis).clamp(0.0, 1.0),
                  backgroundColor: context.druid.hint.withValues(alpha: 0.2),
                  color: context.colors.primary,
                ),
              ),
            ),
            const SizedBox(width: Gaps.s),
            Text(context.l10n.pantryVis(essence.vis), style: context.texts.labelLarge),
            const Spacer(),
            for (final t in traits) ...[const SizedBox(width: Gaps.s), _QualiaIcon(label: context.game.trait(t))],
          ],
        ),
      ],
    );
  }
}

/// L'icona della Vis in una chip con intorno l'anello della purezza, del colore della luce: pieno a purezza 100 %.
class _PurityChip extends StatelessWidget {
  final double purity;
  final String semanticLabel;

  const _PurityChip({required this.purity, required this.semanticLabel});

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    child: SizedBox.square(
      dimension: 36,
      child: CustomPaint(
        painter: _RingPainter(
          progress: purity.clamp(0.0, 1.0),
          track: context.druid.hint.withValues(alpha: 0.2),
          fill: context.druid.traitColor(Trait.sun.index),
        ),
        child: const Center(child: EngravedIcon(visIcon, size: 18)),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color track;
  final Color fill;

  const _RingPainter({required this.progress, required this.track, required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 3.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, paint..color = track);
    if (progress > 0) canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, paint..color = fill);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.track != track || old.fill != fill;
}

/// Una Qualia come icona incisa, senza testo: il nome tenendo premuto.
class _QualiaIcon extends StatelessWidget {
  /// Il nome con l'emoji davanti ("☀️ Sole"), come lo scrivono i testi.
  final String label;

  const _QualiaIcon({required this.label});

  @override
  Widget build(BuildContext context) {
    final emoji = leadingEmoji(label);
    final name = emoji == null ? label : label.substring(emoji.length).trim();
    return Tooltip(
      message: name,
      child: Semantics(
        label: name,
        child: EngravedIcon(
          (emoji == null ? null : traitIconOf(emoji)) ?? Icons.eco_outlined,
          size: 22,
          mirrored: emoji != null && traitIconMirrored(emoji),
        ),
      ),
    );
  }
}
