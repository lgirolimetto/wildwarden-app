import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';
import 'package:druid_app/user_interface/common_widgets/inset_badge.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/pages/erbario/level_name.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/species_name.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Scheda di una specie non ancora incontrata: foto e nome, come una pagina già stampata dell'erbario. Il resto si
/// scopre studiando e incontrandola. [onSimulateEncounter] è presente solo con gli strumenti di debug attivi.
class UnknownSpeciesTile extends StatelessWidget {
  final Species species;
  final int level;
  final VoidCallback? onSimulateEncounter;

  /// `null` se la specie non ha più livelli da studiare.
  final VoidCallback? onStudy;

  const UnknownSpeciesTile({super.key, required this.species, this.level = 0, this.onSimulateEncounter, this.onStudy});

  @override
  Widget build(BuildContext context) => _TileFrame(
    aspect: tileAspect(species),
    color: context.druid.neu ? context.colors.surfaceBright : null,
    image: species.images.isEmpty ? const SizedBox.shrink() : RemoteImage(species.images.first.url),
    protected: species.isProtected,
    children: [
      Text(
        species.name.resolve(context.contentLanguage),
        style: speciesNameStyle(context, context.texts.titleMedium, green: false),
      ),
      if (level > 0) ...[const SizedBox(height: Gaps.xs), _LevelDots(level: level)],
      if (onStudy != null) _StudyTileButton(species: species, onStudy: onStudy!),
      if (onSimulateEncounter != null) ...[
        const SizedBox(height: Gaps.s),
        TextButton.icon(
          key: ValueKey('simulate-${species.sci}'),
          onPressed: onSimulateEncounter,
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
          icon: const Icon(Icons.bug_report_outlined, size: 16),
          label: Text(context.l10n.simulateShort, maxLines: 1),
        ),
      ],
    ],
  );
}

/// Scheda di una specie già incontrata: foto, nome, livello di studio.
class EncounteredSpeciesTile extends StatelessWidget {
  final Species species;
  final int level;

  /// Data del primo incontro: il timbro sulla tessera.
  final DateTime? encounteredAt;

  /// `null` se la specie non ha più livelli da studiare.
  final VoidCallback? onStudy;

  const EncounteredSpeciesTile({super.key, required this.species, this.level = 0, this.encounteredAt, this.onStudy});

  @override
  Widget build(BuildContext context) => _TileFrame(
    aspect: tileAspect(species),
    image: species.images.isEmpty ? const SizedBox.shrink() : RemoteImage(species.images.first.url),
    // Nelle livree neumorfiche le tessere hanno colori propri: incontrate le più chiare (`surfaceContainerLowest`),
    // da trovare un tono sotto (`surfaceBright`).
    color: context.druid.neu ? context.colors.surfaceContainerLowest : null,
    protected: species.isProtected,
    children: [
      Text(
        species.name.resolve(context.contentLanguage),
        style: speciesNameStyle(context, context.texts.titleMedium, green: false),
      ),
      if (encounteredAt != null) ...[
        const SizedBox(height: Gaps.s),
        StampBadge(
          key: ValueKey('stamp-${species.sci}'),
          text: DateFormat.MMMd(context.contentLanguage).format(encounteredAt!),
          label: context.l10n.badgeEncountered,
        ),
      ],
      const SizedBox(height: Gaps.s),
      _LevelDots(level: level),
      const SizedBox(height: Gaps.xs),
      Text(levelName(context.l10n, level), style: context.texts.bodySmall?.copyWith(color: context.druid.hint)),
      if (onStudy != null) _StudyTileButton(species: species, onStudy: onStudy!),
    ],
  );
}

/// "Studia" sulla tessera: apre il prossimo livello da studiare.
class _StudyTileButton extends StatelessWidget {
  final Species species;
  final VoidCallback onStudy;

  const _StudyTileButton({required this.species, required this.onStudy});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: TextButton.icon(
      key: ValueKey('tile-study-${species.sci}'),
      onPressed: onStudy,
      style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
      icon: const Icon(Icons.school_outlined, size: 16),
      label: Text(context.l10n.seasonalStudy, maxLines: 1),
    ),
  );
}

/// Proporzioni della foto di una tessera (larghezza / altezza): verticale, quadrata o orizzontale. Il catalogo non ha
/// le dimensioni delle foto, quindi si sceglie dal nome scientifico: sempre la stessa per una specie, varia tra le
/// specie (i mattoncini dell'erbario vengono sfalsati). La foto è ritagliata, non deformata.
double tileAspect(Species species) => const [0.8, 1.0, 1.25][species.sci.codeUnits.fold(0, (a, b) => a + b) % 3];

/// Angoli della foto dentro la tessera: concentrici a quelli della tessera.
BorderRadius _photoRadius(BuildContext context) => BorderRadius.circular(context.druid.cardRadius - Gaps.s);

/// Tessera in plastilina con la foto "incastonata": un bordo tutt'intorno e angoli suoi. L'altezza segue la foto e
/// il testo, così nell'erbario le tessere si dispongono a mattoncini.
class _TileFrame extends StatelessWidget {
  final Widget image;
  final double aspect;
  final List<Widget> children;

  /// Colore della tessera (`null`: quello delle schede).
  final Color? color;

  /// Specie protetta: lo scudo sulla foto, in alto a sinistra.
  final bool protected;

  const _TileFrame({
    required this.image,
    required this.aspect,
    required this.children,
    this.color,
    this.protected = false,
  });

  @override
  Widget build(BuildContext context) => ClayCard(
    color: color,
    padding: const EdgeInsets.all(Gaps.s),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: _photoRadius(context),
              child: AspectRatio(aspectRatio: aspect, child: image),
            ),
            if (protected) const Positioned(left: Gaps.s, top: Gaps.s, child: ProtectedShield()),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Gaps.xs, Gaps.s, Gaps.xs, Gaps.xs),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    ),
  );
}

/// Quattro sferette: una colorata per ogni livello di studio superato.
class _LevelDots extends StatelessWidget {
  static const maxLevel = 4;
  final int level;

  const _LevelDots({required this.level});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 1; i <= maxLevel; i++)
        Padding(
          padding: const EdgeInsets.only(right: Gaps.xs),
          child: ClayCircle(
            size: 12,
            color: i <= level ? context.druid.levelColor(i) : context.colors.surfaceContainerHigh,
          ),
        ),
    ],
  );
}
