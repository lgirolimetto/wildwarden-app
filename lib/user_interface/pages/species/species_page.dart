import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/fun_facts.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/mystery_cover.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/erbario/level_name.dart';
import 'package:druid_app/user_interface/pages/study/study_home_page.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Pagina d'erbario di una specie. Si compila livello per livello: ciò che non hai ancora imparato è chiuso
/// da un lucchetto che dice a che livello si rivela.
class SpeciesPage extends StatelessWidget {
  final String speciesSci;

  const SpeciesPage({super.key, required this.speciesSci});

  @override
  Widget build(BuildContext context) => Scaffold(
    // I pulsanti tondi galleggiano sopra la foto: niente barra separata.
    appBar: clayAppBar(context, overImage: true),
    extendBodyBehindAppBar: true,
    body: DruidBackground(
      child: GameDataBuilder(
        builder: (context, catalog, state, progress) {
          final species = catalog.speciesBySci(speciesSci)!;
          return state.hasEncountered(speciesSci)
              ? _KnownSpecies(species: species, catalog: catalog, state: state, progress: progress)
              : _UnknownSpecies(species: species, state: state, progress: progress);
        },
      ),
    ),
  );
}

class _UnknownSpecies extends StatelessWidget {
  final Species species;
  final GameState state;
  final ProgressController progress;

  const _UnknownSpecies({required this.species, required this.state, required this.progress});

  @override
  Widget build(BuildContext context) {
    final desired = state.desiderata.contains(species.sci);
    return ListView(
      padding: const EdgeInsets.only(bottom: Gaps.xl),
      children: [
        SpeciesPhotoHeader(
          image: desired
              ? RemoteImage(species.images.first.url)
              : MysteryCover(species: species, borderRadius: SpeciesPhotoHeader.radius),
          title: desired ? context.game.name(species) : context.l10n.unknownSpecies,
          subtitle: context.l10n.notEncounteredYet,
          level: null,
        ),
        _Padded(
          children: [
            Text(context.game.hint(species)),
            const SizedBox(height: Gaps.l),
            FilledButton.icon(
              key: const ValueKey('toggle-desiderata'),
              onPressed: desired || canAddDesiderata(state) ? () => progress.toggleDesiderata(species.sci) : null,
              icon: Icon(desired ? Icons.star : Icons.star_outline),
              label: Text(desired ? context.l10n.desiderataRemove : context.l10n.desiderataAdd),
            ),
            if (!desired && !canAddDesiderata(state)) ...[
              const SizedBox(height: Gaps.xs),
              Text(context.l10n.desiderataFull, style: context.texts.bodySmall),
            ],
            if (Get.find<AppConfig>().showDebugTools) ...[
              const SizedBox(height: Gaps.s),
              OutlinedButton.icon(
                key: const ValueKey('simulate-encounter-page'),
                onPressed: () => progress.encounter(species.sci, method: EncounterMethod.simulated),
                icon: const Icon(Icons.bug_report_outlined),
                label: Text(context.l10n.simulateEncounter),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _KnownSpecies extends StatelessWidget {
  final Species species;
  final Catalog catalog;
  final GameState state;
  final ProgressController progress;

  const _KnownSpecies({required this.species, required this.catalog, required this.state, required this.progress});

  @override
  Widget build(BuildContext context) {
    final level = state.levelOf(species.sci);
    final game = context.game;
    final lore = catalog.lore[species.sci];
    final safety = catalog.safety[species.sci];
    Widget locked(int at) => _Locked(level: at);

    return ListView(
      padding: const EdgeInsets.only(bottom: Gaps.xl),
      children: [
        SpeciesPhotoHeader(
          image: RemoteImage(species.images.first.url),
          credit: '${species.images.first.creator} · ${species.images.first.license}',
          title: game.name(species),
          subtitle: levelName(context.l10n, level),
          level: level,
        ),
        _Padded(
          children: [
            _StudyLadder(species: species, catalog: catalog, state: state),
            const SizedBox(height: Gaps.l),

            _Section(
              title: context.l10n.sectionSci,
              child: level >= 1
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(species.sci, style: const TextStyle(fontStyle: FontStyle.italic)),
                        if (species.images.length > 1) ...[
                          const SizedBox(height: Gaps.s),
                          SizedBox(
                            height: 80,
                            child: Row(
                              children: [
                                for (final image in species.images.skip(1))
                                  Padding(
                                    padding: const EdgeInsets.only(right: Gaps.s),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(width: 100, child: RemoteImage(image.url)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    )
                  : locked(1),
            ),
            _Section(
              title: context.l10n.sectionFamily,
              child: level >= 2
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(species.family),
                        if (catalog.relativesOf(species).isNotEmpty)
                          Text(
                            '${context.l10n.sectionRelatives}: ${catalog.relativesOf(species).map((r) => state.hasEncountered(r.sci) ? game.name(r) : context.l10n.unknownSpecies).join(', ')}',
                          ),
                        if (safety != null) ...[
                          const SizedBox(height: Gaps.xs),
                          Text(
                            context.l10n.safetyWarning(safety.resolve(context.contentLanguage)),
                            style: TextStyle(color: context.druid.warning),
                          ),
                        ],
                      ],
                    )
                  : locked(2),
            ),
            _Section(
              title: context.l10n.sectionWhen,
              child: level >= 3 ? _MonthsChart(species: species) : locked(3),
            ),
            _Section(
              title: species.elevationMedian == null
                  ? context.l10n.sectionWhere(0)
                  : context.l10n.sectionWhere(species.elevationMedian!.round()),
              child: level >= 3
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final band in AltitudeBand.values)
                          _BandBar(label: game.band(band), share: species.bandShare[band] ?? 0),
                        if (species.family == 'Orchidaceae') ...[
                          const SizedBox(height: Gaps.xs),
                          Text(context.l10n.protectedNote, style: context.texts.bodySmall),
                        ],
                      ],
                    )
                  : locked(3),
            ),
            _Section(
              title: context.l10n.sectionLore,
              child: level >= 4
                  ? Text(
                      lore?.resolve(context.contentLanguage) ?? context.l10n.masteryReached,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    )
                  : locked(4),
            ),
            _FunFactsSection(species: species, catalog: catalog, state: state),
            _MasterySection(species: species, catalog: catalog, state: state, progress: progress),
            _NotesSection(species: species, initial: state.notes[species.sci] ?? '', progress: progress),
          ],
        ),
      ],
    );
  }
}

/// Contenuto della scheda sotto la testata, con i margini laterali.
class _Padded extends StatelessWidget {
  final List<Widget> children;

  const _Padded({required this.children});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(Gaps.l, Gaps.l, Gaps.l, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
  );
}

/// Testata della scheda specie: la foto, attaccata in alto, con i margini laterali del contenuto e gli angoli
/// arrotondati, ha solo un'ombra leggera e il pulsante indietro che le galleggia sopra; il nome sta su una lastra di
/// vetro smerigliato in basso, dentro la foto.
class SpeciesPhotoHeader extends StatelessWidget {
  static const _photoHeight = 380.0;
  static const radius = BorderRadius.all(Radius.circular(28));

  final Widget image;
  final String title;
  final String subtitle;
  final String? credit;

  /// Livello di studio, per la sfera colorata accanto al nome (`null` se la specie non è ancora incontrata).
  final int? level;

  const SpeciesPhotoHeader({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.level,
    this.credit,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    // La foto parte dal bordo superiore dello schermo (sotto la barra di stato), con i margini solo ai lati.
    // Si misura la sola barra di stato: il padding della pagina include anche la barra trasparente dei pulsanti.
    final view = View.of(context);
    final statusBar = view.padding.top / view.devicePixelRatio;
    const photoTop = 0.0;
    final photoHeight = _photoHeight + statusBar;
    const bottomRadius = radius;
    return SizedBox(
      height: photoTop + photoHeight,
      child: Stack(
        children: [
          // Solo un'ombra leggera sotto la foto: la stacca dalla pagina senza effetto 3D marcato.
          Positioned(
            left: Gaps.l,
            right: Gaps.l,
            top: photoTop,
            height: photoHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: bottomRadius,
                boxShadow: [
                  BoxShadow(
                    color: tokens.clayShadow.withValues(alpha: tokens.clayShadow.a * 0.6),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: Gaps.l,
            right: Gaps.l,
            top: photoTop,
            height: photoHeight,
            child: ClipRRect(
              borderRadius: bottomRadius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  image,
                  // Velatura in alto: barra di stato, pulsante e crediti si leggono su qualunque foto.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [Color(0x59000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                  // Nome su vetro smerigliato dentro la foto: la foto resta un unico oggetto, come una copertina.
                  Positioned(
                    left: Gaps.m,
                    right: Gaps.m,
                    bottom: Gaps.m,
                    child: _GlassLabel(title: title, subtitle: subtitle, level: level),
                  ),
                  if (credit != null)
                    Positioned(
                      right: Gaps.l,
                      top: statusBar + 70,
                      child: Text(
                        credit!,
                        style: context.texts.labelSmall?.copyWith(
                          color: Colors.white,
                          shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nome e livello su vetro smerigliato: la foto sotto si intravede sfocata. La velatura color pagina è abbastanza
/// piena da tenere il testo leggibile anche su foto chiare o molto fitte; la sfera del livello resta in plastilina.
class _GlassLabel extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? level;

  const _GlassLabel({required this.title, required this.subtitle, required this.level});

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    // Angoli concentrici a quelli della foto: raggio della foto meno il margine.
    final radius = BorderRadius.circular(SpeciesPhotoHeader.radius.topLeft.x - Gaps.m);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(Gaps.l, Gaps.m, Gaps.m, Gaps.m),
          decoration: BoxDecoration(
            borderRadius: radius,
            color: context.colors.surfaceContainerLow.withValues(alpha: 0.6),
            border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: context.texts.headlineSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: level == null ? tokens.hint : context.colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Gaps.m),
              ClayCircle(
                color: level == null ? context.colors.surfaceContainerHigh : tokens.levelColor(level!),
                size: 48,
                child: Text(
                  level == null ? '?' : '$level',
                  style: context.texts.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Gaps.l),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: context.texts.labelMedium?.copyWith(letterSpacing: 0.8, color: context.druid.hint),
        ),
        const SizedBox(height: Gaps.xs),
        child,
      ],
    ),
  );
}

class _Locked extends StatelessWidget {
  final int level;

  const _Locked({required this.level});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(Gaps.s),
    // Riquadro "scavato" (come i campi di testo): ciò che manca si vede come un incavo da riempire.
    decoration: context.druid.clay
        ? BoxDecoration(
            color: context.colors.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(22),
          )
        : BoxDecoration(
            border: Border.all(color: context.colors.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
    child: Row(
      children: [
        ClayCircle(color: context.colors.surfaceContainerHigh, icon: Icons.lock_rounded, size: 28),
        const SizedBox(width: Gaps.m),
        Expanded(child: Text(context.l10n.lockedSection(level, levelName(context.l10n, level)))),
      ],
    ),
  );
}

class _StudyLadder extends StatelessWidget {
  final Species species;
  final Catalog catalog;
  final GameState state;

  const _StudyLadder({required this.species, required this.catalog, required this.state});

  @override
  Widget build(BuildContext context) {
    final next = nextStudyLevel(species, catalog, state);
    return ClayCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Gaps.m),
        child: Row(
          children: [
            for (var level = 1; level <= 4; level++)
              Expanded(
                child: Column(
                  children: [
                    ClayCircle(
                      size: 30,
                      color: state.levelOf(species.sci) >= level
                          ? context.druid.levelColor(level)
                          : context.colors.surfaceContainerHigh,
                      icon: state.levelOf(species.sci) >= level ? Icons.check_rounded : Icons.lock_rounded,
                    ),
                    const SizedBox(height: Gaps.xs),
                    SizedBox(
                      // Altezza fissa per due righe: le sfere restano allineate anche se un nome va a capo.
                      height: 32,
                      child: FittedBox(
                        // Al massimo due righe e mai parole spezzate: se non ci stanno, il testo si rimpicciolisce.
                        fit: BoxFit.scaleDown,
                        child: Text(
                          levelName(context.l10n, level).replaceFirst(' ', '\n'),
                          textAlign: TextAlign.center,
                          style: context.texts.labelSmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: Gaps.s),
            if (next != null)
              FilledButton(
                key: const ValueKey('study-next-level'),
                onPressed: () => startLevelStudy(catalog, species.sci, next),
                child: Text(context.l10n.studyLevelButton(next)),
              )
            else
              Text(context.l10n.studyComplete, style: context.texts.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _MonthsChart extends StatelessWidget {
  final Species species;

  const _MonthsChart({required this.species});

  @override
  Widget build(BuildContext context) {
    final top = species.monthsRelative.reduce(max);
    return SizedBox(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 12; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: top == 0 ? 0 : 52 * species.monthsRelative[i] / top,
                      decoration: BoxDecoration(
                        color: context.druid.levelColor(3),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(context.game.month(i + 1).substring(0, 1).toUpperCase(), style: context.texts.labelSmall),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BandBar extends StatelessWidget {
  final String label;
  final double share;

  const _BandBar({required this.label, required this.share});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Gaps.xs),
    child: Row(
      children: [
        SizedBox(width: 170, child: Text(label, style: context.texts.bodySmall)),
        Expanded(
          child: LinearProgressIndicator(value: share, borderRadius: BorderRadius.circular(4)),
        ),
        SizedBox(width: 44, child: Text('${(share * 100).round()}%', textAlign: TextAlign.end)),
      ],
    ),
  );
}

class _FunFactsSection extends StatelessWidget {
  final Species species;
  final Catalog catalog;
  final GameState state;

  const _FunFactsSection({required this.species, required this.catalog, required this.state});

  @override
  Widget build(BuildContext context) {
    final all = funFactsOf(species, catalog);
    final seen = all.where((f) => state.revealedFunFacts.containsKey(f.id)).toList();
    return _Section(
      title: context.l10n.sectionFunFacts(seen.length, all.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final fact in seen)
            Padding(
              padding: const EdgeInsets.only(bottom: Gaps.xs),
              child: Text('• ${context.game.funFact(fact)}'),
            ),
          if (seen.length < all.length)
            Text(
              context.l10n.sectionFunFactsHidden(all.length - seen.length),
              style: TextStyle(color: context.druid.hint),
            ),
        ],
      ),
    );
  }
}

class _MasterySection extends StatefulWidget {
  final Species species;
  final Catalog catalog;
  final GameState state;
  final ProgressController progress;

  const _MasterySection({required this.species, required this.catalog, required this.state, required this.progress});

  @override
  State<_MasterySection> createState() => _MasterySectionState();
}

class _MasterySectionState extends State<_MasterySection> {
  Trait? _trait;

  @override
  Widget build(BuildContext context) {
    final m = masteryProgress(widget.species, widget.catalog, widget.state);
    final l10n = context.l10n;
    return _Section(
      title: l10n.masteryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.state.mastered.contains(widget.species.sci))
            Text(l10n.masteryReached, style: context.texts.titleMedium),
          Text(l10n.masteryFacts(m.consolidatedFacts, m.totalFacts)),
          Text(l10n.masteryDraws(m.draws, masteryDraws, m.distinctTraits, masteryDistinctTraits)),
          Text(l10n.masteryOnlyField, style: context.texts.bodySmall?.copyWith(color: context.druid.hint)),
          if (Get.find<AppConfig>().showDebugTools) ...[
            const SizedBox(height: Gaps.s),
            Wrap(
              spacing: Gaps.chip,
              runSpacing: Gaps.chipRun,
              children: [
                ClayChip(label: l10n.noTrait, selected: _trait == null, onTap: () => setState(() => _trait = null)),
                for (final trait in Trait.values)
                  ClayChip(
                    label: context.game.trait(trait),
                    selected: _trait == trait,
                    onTap: () => setState(() => _trait = trait),
                  ),
              ],
            ),
            const SizedBox(height: Gaps.xs),
            OutlinedButton.icon(
              key: const ValueKey('simulate-draw'),
              onPressed: () => widget.progress.drawSimulated(widget.species.sci, trait: _trait?.name),
              icon: const Icon(Icons.bug_report_outlined),
              label: Text(l10n.simulateDraw),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotesSection extends StatefulWidget {
  final Species species;
  final String initial;
  final ProgressController progress;

  const _NotesSection({required this.species, required this.initial, required this.progress});

  @override
  State<_NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<_NotesSection> {
  late final TextEditingController _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Section(
    title: context.l10n.notesTitle,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('notes-field'),
          controller: _text,
          minLines: 2,
          maxLines: 6,
          decoration: InputDecoration(hintText: context.l10n.notesHint),
        ),
        const SizedBox(height: Gaps.s),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton(
            key: const ValueKey('save-note'),
            onPressed: () async {
              await widget.progress.saveNote(widget.species.sci, _text.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.notesSaved)));
              }
            },
            child: Text(context.l10n.notesSave),
          ),
        ),
      ],
    ),
  );
}
