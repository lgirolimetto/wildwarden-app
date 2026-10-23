import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/pages/erbario/level_name.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:flutter/material.dart';

/// Scheda di una specie non ancora incontrata: foto e nome, come una pagina già stampata dell'erbario. Il resto si
/// scopre studiando e incontrandola. [onSimulateEncounter] è presente solo con gli strumenti di debug attivi.
class UnknownSpeciesTile extends StatelessWidget {
  final Species species;
  final VoidCallback? onSimulateEncounter;

  const UnknownSpeciesTile({super.key, required this.species, this.onSimulateEncounter});

  @override
  Widget build(BuildContext context) => _TileFrame(
    aspect: tileAspect(species),
    color: context.druid.neu ? context.colors.surfaceBright : null,
    image: species.images.isEmpty ? const SizedBox.shrink() : RemoteImage(species.images.first.url),
    children: [
      Text(species.name.resolve(context.contentLanguage), style: context.texts.titleMedium),
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

  const EncounteredSpeciesTile({super.key, required this.species, this.level = 0});

  @override
  Widget build(BuildContext context) => _TileFrame(
    aspect: tileAspect(species),
    image: species.images.isEmpty ? const SizedBox.shrink() : RemoteImage(species.images.first.url),
    // Nelle livree neumorfiche le tessere hanno colori propri: incontrate le più chiare (`surfaceContainerLowest`),
    // da trovare un tono sotto (`surfaceBright`).
    color: context.druid.neu ? context.colors.surfaceContainerLowest : null,
    children: [
      Text(species.name.resolve(context.contentLanguage), style: context.texts.titleMedium),
      const SizedBox(height: Gaps.xs),
      _LevelDots(level: level),
      const SizedBox(height: Gaps.xs),
      Text(levelName(context.l10n, level), style: context.texts.bodySmall?.copyWith(color: context.druid.hint)),
    ],
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

  const _TileFrame({required this.image, required this.aspect, required this.children, this.color});

  @override
  Widget build(BuildContext context) => ClayCard(
    color: color,
    padding: const EdgeInsets.all(Gaps.s),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: _photoRadius(context),
          child: AspectRatio(aspectRatio: aspect, child: image),
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
