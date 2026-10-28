import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/essences.dart';
import 'package:druid_app/business_logic/rules/fun_facts.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/harvest.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';
import 'package:druid_app/business_logic/rules/study/review_schedule.dart';
import 'package:druid_app/business_logic/rules/study/study_session.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/engraved_icon.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/common_widgets/status_bar_scrim.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/erbario/level_name.dart';
import 'package:druid_app/user_interface/pages/study/study_home_page.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/inset_badge.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/user_interface/pages/recipe_book/plant_pages_page.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/page_dots.dart';
import 'package:druid_app/user_interface/common_widgets/species_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Pagina d'erbario di una specie. Si compila livello per livello: ciò che non hai ancora imparato è chiuso
/// da un lucchetto che dice a che livello si rivela.
class SpeciesPage extends StatelessWidget {
  final String speciesSci;

  const SpeciesPage({super.key, required this.speciesSci});

  @override
  Widget build(BuildContext context) => DenseArea(child: _page(context));

  Widget _page(BuildContext context) => Scaffold(
    // Niente barra: il pulsante indietro sta nella testata, sull'angolo della foto, e scorre con lei.
    body: Stack(
      children: [
        DruidBackground(
          child: GameDataBuilder(
            builder: (context, catalog, state, progress) {
              final species = catalog.speciesBySci(speciesSci)!;
              return _SpeciesSheet(species: species, catalog: catalog, state: state, progress: progress);
            },
          ),
        ),
        // Nelle livree neumorfiche la foto parte sotto la barra di stato: il contenuto che scorre sfuma sotto l'orologio.
        // Builder: il colore va letto sotto il tema della pagina (denso).
        Builder(
          builder: (context) => context.druid.neu
              ? StatusBarScrim(color: context.druid.backgroundGradient.first)
              : const SizedBox.shrink(),
        ),
        // Il pulsante indietro, fisso: sempre disponibile mentre la pagina scorre. All'apertura sta sull'angolo in alto a
        // sinistra della cornice della foto, allineato ai margini della pagina.
        Positioned(
          left: Gaps.l,
          top: MediaQuery.paddingOf(context).top + Gaps.s,
          child: ClayIconButton(
            key: const ValueKey('clay-back'),
            icon: Icons.arrow_back_rounded,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    ),
  );
}

/// Per una specie non ancora incontrata: dove e quando cercarla, la stella delle desiderata e, negli strumenti di
/// prova, l'incontro simulato.
class _ToFind extends StatelessWidget {
  final Species species;
  final GameState state;
  final ProgressController progress;

  const _ToFind({required this.species, required this.state, required this.progress});

  @override
  Widget build(BuildContext context) {
    final desired = state.desiderata.contains(species.sci);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gaps.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.game.hint(species)),
          const SizedBox(height: Gaps.m),
          FilledButton.icon(
            key: const ValueKey('toggle-desiderata'),
            onPressed: () => progress.toggleDesiderata(species.sci),
            icon: Icon(desired ? Icons.star : Icons.star_outline),
            label: Text(desired ? context.l10n.desiderataRemove : context.l10n.desiderataAdd),
          ),
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
    );
  }
}

/// Specie protetta: il messaggio di rispetto, con la legge che la protegge. Sempre visibile, come l'avviso di
/// tossicità: è un safari fotografico, si guarda e non si tocca. Sta in una scheda terracotta come quella del rango in
/// Home (sfumatura e ombra morbida), con lo scudo inciso come le icone dei tratti, chiaro perché il fondo è scuro
/// (sulla foto invece lo scudo è il tondo bianco di [ProtectedShield]).
class _ProtectedNote extends StatelessWidget {
  final Species species;

  const _ProtectedNote({required this.species});

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    final surface = context.colors.primary;
    final content = Padding(
      padding: const EdgeInsets.all(Gaps.l),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClayCircle(color: context.colors.primaryContainer, icon: Icons.shield_outlined, size: 32, surface: surface),
          const SizedBox(width: Gaps.m),
          Expanded(
            child: Text(
              context.l10n.protectedNote(species.protection.map(context.game.protectionSource).join(', ')),
              style: TextStyle(color: context.colors.onPrimary),
            ),
          ),
        ],
      ),
    );
    return Padding(
      key: const ValueKey('protected-note'),
      padding: const EdgeInsets.only(bottom: Gaps.l),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.cardRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [surface, Color.lerp(surface, context.colors.onPrimary, 0.12)!],
          ),
          boxShadow: [
            BoxShadow(
              color: tokens.clay ? tokens.clayShadow : surface.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

/// Avviso di tossicità, sempre visibile in cima alla scheda: la sicurezza non si sblocca studiando.
class _SafetyWarning extends StatelessWidget {
  final Species species;
  final Catalog catalog;

  const _SafetyWarning({required this.species, required this.catalog});

  @override
  Widget build(BuildContext context) {
    final safety = catalog.safety[species.sci];
    if (safety == null) return const SizedBox.shrink();
    // Il segnale è un'icona, non un'emoji: incisa nelle livree neumorfiche, come le altre icone.
    const icon = Icons.warning_amber_rounded;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gaps.l),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (context.druid.neu)
            EngravedIcon(icon, color: context.druid.warning)
          else
            Icon(icon, size: 20, color: context.druid.warning),
          const SizedBox(width: Gaps.s),
          Expanded(
            child: Text(
              key: const ValueKey('safety-warning'),
              context.l10n.safetyWarning(safety.resolve(context.contentLanguage)),
              style: TextStyle(color: context.druid.warning),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pagina d'erbario di una specie, incontrata o no: ciò che si sa si sblocca studiando.
class _SpeciesSheet extends StatelessWidget {
  final Species species;
  final Catalog catalog;
  final GameState state;
  final ProgressController progress;

  const _SpeciesSheet({required this.species, required this.catalog, required this.state, required this.progress});

  @override
  Widget build(BuildContext context) {
    final level = state.levelOf(species.sci);
    final levelLabel = progress.masteryDormant(species.sci)
        ? context.l10n.levelMasteryDormant
        : levelName(context.l10n, level);
    final game = context.game;
    final lore = catalog.lore[species.sci];
    Widget locked(int at) => _Locked(level: at);

    return ListView(
      padding: const EdgeInsets.only(bottom: Gaps.xl),
      children: [
        SpeciesPhotoHeader(
          image: RemoteImage(species.images.first.url),
          credit: '${species.images.first.creator} · ${species.images.first.license}',
          title: game.name(species),
          subtitle: state.hasEncountered(species.sci) ? levelLabel : '${context.l10n.notEncounteredYet} · $levelLabel',
          level: level,
          protected: species.isProtected,
        ),
        _Padded(
          children: [
            _SafetyWarning(species: species, catalog: catalog),
            if (species.isProtected) _ProtectedNote(species: species),
            if (!state.hasEncountered(species.sci)) _ToFind(species: species, state: state, progress: progress),
            _StudyLadder(species: species, catalog: catalog, state: state),
            _RecipeBookLink(species: species, catalog: catalog, state: state),
            const SizedBox(height: Gaps.l),
            _Section(
              title: context.l10n.sectionTraits,
              child: game.traitLines(species, level).isEmpty
                  ? locked(1)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final line in game.traitLines(species, level)) Text(line),
                        const SizedBox(height: Gaps.xs),
                        Text(
                          context.l10n.sourcesTraits,
                          style: context.texts.labelSmall?.copyWith(color: context.druid.hint),
                        ),
                      ],
                    ),
            ),

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
                            '${context.l10n.sectionRelatives}: ${catalog.relativesOf(species).map(game.name).join(', ')}',
                          ),
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
/// arrotondati, ha solo un'ombra leggera e il pulsante indietro che le galleggia sopra; il nome sta su un velo
/// semitrasparente in basso, dentro la foto.
class SpeciesPhotoHeader extends StatelessWidget {
  static const _photoHeight = 380.0;
  static const radius = BorderRadius.all(Radius.circular(28));

  final Widget image;
  final String title;
  final String subtitle;
  final String? credit;

  /// Livello di studio, per la sfera colorata accanto al nome (`null` se la specie non è ancora incontrata).
  final int? level;

  /// Specie protetta: lo scudo a sinistra del nome.
  final bool protected;

  const SpeciesPhotoHeader({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.level,
    this.credit,
    this.protected = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    // La foto parte dal bordo superiore dello schermo (sotto la barra di stato), con i margini solo ai lati.
    // Si misura la sola barra di stato: il padding della pagina include anche la barra trasparente dei pulsanti.
    final view = View.of(context);
    final statusBar = view.padding.top / view.devicePixelRatio;
    // Nelle livree neumorfiche la foto si stacca anche dal bordo in alto: si vede tutto il bordo inciso.
    final photoTop = tokens.neu ? statusBar + Gaps.s : 0.0;
    final photoHeight = tokens.neu ? _photoHeight : _photoHeight + statusBar;
    // Nelle livree neumorfiche la foto è incorniciata da un bordo piatto, inciso lungo il contorno come una pillola
    // che non si preme: si legge anche quando la foto è scura.
    final frame = tokens.neu ? Gaps.m : 0.0;
    final bottomRadius = tokens.neu ? BorderRadius.circular(radius.topLeft.x - frame) : radius;
    final header = SizedBox(
      height: photoTop + photoHeight,
      child: Stack(
        children: [
          // Un'ombra leggera sotto la foto: la stacca dalla pagina senza effetto 3D marcato. Nelle livree neumorfiche
          // invece la cornice è piatta, con il bordo inciso come una pillola: la foto si guarda, non si preme.
          Positioned(
            left: Gaps.l,
            right: Gaps.l,
            top: photoTop,
            height: photoHeight,
            child: tokens.neu
                ? const GroovedPanel(radius: radius, child: SizedBox.expand())
                : DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
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
            left: Gaps.l + frame,
            right: Gaps.l + frame,
            top: photoTop + frame,
            height: photoHeight - frame * 2,
            // Nelle livree neumorfiche la cornice è piatta con il bordo inciso; la foto ci sta dentro, senza altri bordi.
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
                  // Nome su un velo dentro la foto: la foto resta un unico oggetto, come una copertina.
                  Positioned(
                    left: Gaps.m,
                    right: Gaps.m,
                    bottom: Gaps.m,
                    child: _PhotoLabel(title: title, subtitle: subtitle, level: level, protected: protected),
                  ),
                  if (credit != null)
                    Positioned(
                      right: Gaps.l,
                      top: tokens.neu ? Gaps.l + Gaps.s : statusBar + 70,
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
    // Fuori dalle livree neumorfiche la foto passa sotto la barra di stato: icone di sistema chiare sopra la foto.
    return tokens.neu
        ? header
        : AnnotatedRegion<SystemUiOverlayStyle>(value: SystemUiOverlayStyle.light, child: header);
  }
}

/// Nome e livello su vetro scuro: la foto sotto si intravede sfocata, velata con i colori della scheda "eroe" della
/// livrea (scura in entrambi i temi), così il testo chiaro si legge su qualunque foto. Nelle livree neumorfiche il
/// bordo è un solco ricavato dal vetro, come per il cerchietto della scheda del rango: si guarda, non si preme.
class _PhotoLabel extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? level;
  final bool protected;

  const _PhotoLabel({required this.title, required this.subtitle, required this.level, required this.protected});

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    final onHero = tokens.onHero;
    final surface = tokens.heroGradient.first;
    // Angoli concentrici a quelli della foto: raggio della foto meno il margine.
    final radius = BorderRadius.circular(SpeciesPhotoHeader.radius.topLeft.x - Gaps.m);
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(Gaps.l, Gaps.m, Gaps.m, Gaps.m),
      child: Row(
        children: [
          if (protected) ...[const ProtectedShield(key: ValueKey('protected-shield')), const SizedBox(width: Gaps.m)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: speciesNameStyle(context, context.texts.headlineSmall?.copyWith(color: onHero), green: false),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: onHero.withValues(alpha: level == null ? 0.7 : 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Gaps.m),
          LevelMark(level: level, size: 48, style: context.texts.titleLarge, surface: surface),
        ],
      ),
    );
    final veil = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [for (final c in tokens.heroGradient) c.withValues(alpha: 0.62)],
        ),
        // Nelle livree neumorfiche il bordo è il solco.
        border: tokens.neu ? null : Border.all(color: onHero.withValues(alpha: 0.3), width: 1.2),
      ),
      child: tokens.neu ? GroovedPanel(radius: radius, surface: surface, child: content) : content,
    );
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: veil),
    );
  }
}

/// La riga che porta alla Pagina della pianta nel Ricettario, se ne conosci almeno una Tavola.
class _RecipeBookLink extends StatelessWidget {
  final Species species;
  final Catalog catalog;
  final GameState state;

  const _RecipeBookLink({required this.species, required this.catalog, required this.state});

  @override
  Widget build(BuildContext context) {
    final collected = collectedPages(catalog, state).where((p) => p.page.plant.sci == species.sci).firstOrNull;
    if (collected == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Gaps.l),
      child: ClayCard(
        key: const ValueKey('species-collected-link'),
        padding: const EdgeInsets.all(Gaps.m),
        onTap: () => Get.to<void>(() => PlantPagesPage(initialSci: species.sci)),
        child: Row(
          children: [
            const Icon(Icons.collections_bookmark_rounded),
            const SizedBox(width: Gaps.m),
            Expanded(
              child: Text(
                context.l10n.recipeBookSpeciesLink(collected.knownCount, collected.page.recipes.length),
                style: context.texts.titleMedium,
              ),
            ),
            PageDots(collected: collected),
          ],
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
    final reached = state.levelOf(species.sci);
    // Il riquadro non si preme (si preme solo il pulsante dentro): nelle livree neumorfiche è piatto, con il bordo
    // inciso come una pillola; altrove una scheda. I livelli sono una lista, con i nomi a grandezza piena (sotto i
    // cerchietti, in un quarto di riga, sul telefono erano illeggibili); il prossimo da studiare è in evidenza.
    return _flatPanel(
      context,
      Padding(
        padding: const EdgeInsets.all(Gaps.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l10n.levelsTitle, style: context.texts.titleSmall),
            const SizedBox(height: Gaps.s),
            for (var level = 1; level <= 4; level++)
              Padding(
                key: ValueKey('level-row-$level'),
                padding: const EdgeInsets.only(bottom: Gaps.s),
                child: Row(
                  children: [
                    ClayCircle(
                      size: 30,
                      // Il colore dice il livello raggiunto: resta anche nelle livree neumorfiche.
                      keepColor: true,
                      color: reached >= level ? context.druid.levelColor(level) : context.colors.surfaceContainerHigh,
                      icon: reached >= level ? Icons.check_rounded : Icons.lock_rounded,
                    ),
                    const SizedBox(width: Gaps.m),
                    Expanded(
                      child: Text(
                        '$level · ${levelName(context.l10n, level)}',
                        style: context.texts.bodyLarge?.copyWith(
                          color: level == next
                              ? context.colors.primary
                              : reached >= level
                              ? null
                              : context.druid.hint,
                          fontWeight: level == next ? FontWeight.w700 : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: Gaps.xs),
            if (next != null)
              FilledButton(
                key: const ValueKey('study-next-level'),
                onPressed: () => startLevelStudy(catalog, species.sci, next),
                child: Text(context.l10n.studyButton),
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
        Expanded(child: ClayProgressBar(value: share, height: 4)),
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
  /// Tratti scelti per "Simula attingere": un'essenza porta tutti i tratti veri in quel momento.
  final _traits = <Trait>{};

  @override
  Widget build(BuildContext context) {
    final m = masteryProgress(widget.species, widget.catalog, widget.state);
    final l10n = context.l10n;
    return _Section(
      title: l10n.masteryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.progress.masteryDormant(widget.species.sci))
            _DormantMastery(speciesSci: widget.species.sci, catalog: widget.catalog)
          else if (widget.state.mastered.contains(widget.species.sci)) ...[
            Text(l10n.masteryReached, style: context.texts.titleMedium),
            Text(
              l10n.masteryKeepHint(masteryDormantDays),
              style: context.texts.bodySmall?.copyWith(color: context.druid.hint),
            ),
            const SizedBox(height: Gaps.xs),
          ],
          if ((widget.state.pendingXp[widget.species.sci] ?? 0) > 0)
            Text(
              l10n.speciesXpToCash(widget.state.pendingXp[widget.species.sci]!),
              key: const ValueKey('species-xp-to-cash'),
              style: context.texts.titleSmall,
            ),
          if ((widget.state.vis[widget.species.sci] ?? 0) > 0)
            Text(l10n.visStored(widget.state.vis[widget.species.sci]!)),
          Text(l10n.masteryFacts(m.consolidatedFacts, m.totalFacts)),
          // Con più tratti per essenza si supera facilmente il traguardo: i contatori si fermano lì.
          Text(
            l10n.masteryDraws(
              min(m.draws, masteryDraws),
              masteryDraws,
              min(m.distinctTraits, masteryDistinctTraits),
              masteryDistinctTraits,
            ),
          ),
          Text(l10n.masteryOnlyField, style: context.texts.bodySmall?.copyWith(color: context.druid.hint)),
          if (Get.find<AppConfig>().showDebugTools) ...[
            const SizedBox(height: Gaps.s),
            Wrap(
              spacing: Gaps.chip,
              runSpacing: Gaps.chipRun,
              children: [
                ClayChip(label: l10n.noTrait, selected: _traits.isEmpty, onTap: () => setState(_traits.clear)),
                for (final trait in Trait.values)
                  ClayChip(
                    key: ValueKey('draw-trait-${trait.name}'),
                    label: context.game.trait(trait),
                    selected: _traits.contains(trait),
                    onTap: () => setState(() => _traits.contains(trait) ? _traits.remove(trait) : _traits.add(trait)),
                  ),
              ],
            ),
            const SizedBox(height: Gaps.xs),
            OutlinedButton.icon(
              key: const ValueKey('simulate-draw'),
              onPressed: canDraw(widget.state, widget.species.sci, widget.progress.now)
                  ? () => widget.progress.drawSimulated(
                      widget.species.sci,
                      traits: [
                        for (final trait in Trait.values)
                          if (_traits.contains(trait)) trait.name,
                      ],
                    )
                  : null,
              icon: const Icon(Icons.bug_report_outlined),
              label: Text(l10n.simulateDraw),
            ),
            if (!widget.state.hasEncountered(widget.species.sci))
              Text(l10n.drawNeedsEncounter, style: context.texts.bodySmall)
            else if (isExhausted(widget.state, widget.species.sci, widget.progress.now))
              Text(l10n.drawExhausted, key: const ValueKey('draw-exhausted'), style: context.texts.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// La Maestria sopita: che cosa vuol dire e il pulsante del mini-quiz che la risveglia.
class _DormantMastery extends StatelessWidget {
  final String speciesSci;
  final Catalog catalog;

  const _DormantMastery({required this.speciesSci, required this.catalog});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.levelMasteryDormant, key: const ValueKey('mastery-dormant'), style: context.texts.titleMedium),
        const SizedBox(height: Gaps.xs),
        Text(
          l10n.masteryDormantText(
            masteryDormantDays,
            (purityOfLevel(maxStudyLevel) * 100).round(),
            (purityOfLevel(maxStudyLevel + 1) * 100).round(),
            awakeningQuestions,
            awakeningQuestions - awakeningMistakesAllowed,
          ),
        ),
        const SizedBox(height: Gaps.s),
        FilledButton.icon(
          key: const ValueKey('awaken-mastery'),
          onPressed: () => startAwakening(catalog, speciesSci),
          icon: const Icon(Icons.wb_twilight_rounded),
          label: Text(l10n.awakenMasteryButton),
        ),
        const SizedBox(height: Gaps.s),
      ],
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

/// Riquadro che non si preme: nelle livree neumorfiche piatto con il bordo inciso ([GroovedPanel]), altrove una scheda.
Widget _flatPanel(BuildContext context, Widget child) => context.druid.neu
    ? GroovedPanel(radius: BorderRadius.circular(context.druid.cardRadius), child: child)
    : ClayCard(padding: EdgeInsets.zero, child: child);
