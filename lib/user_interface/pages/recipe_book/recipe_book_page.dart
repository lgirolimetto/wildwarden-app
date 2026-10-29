import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/brewing.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/recipe_book/mythics_page.dart';
import 'package:druid_app/user_interface/pages/recipe_book/plant_pages_page.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/page_dots.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/ready_mark.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/user_interface/common_widgets/species_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Il Ricettario, la prima linguetta del Laboratorio: la collezione delle Tavole (capitolo 02, "Ricettario, Tavole,
/// Laboratorio e Zone"). In cima le Mitiche della Zona, poi le Pagine delle piante di cui conosci almeno una Tavola,
/// dalla più recente. Si guarda e si sfoglia. [header] è la testata del Laboratorio (titolo e linguette), che scorre con
/// la lista. Le Tavole preparabili adesso hanno l'icona "pronta"; con [onlyReady] restano solo le piante (e le Mitiche)
/// che ne hanno almeno una.
class RecipeBookView extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final Widget header;

  /// Il filtro "Mostra solo preparabili".
  final bool onlyReady;

  /// `null`: il filtro è fisso (al passo della pozione del tutorial).
  final ValueChanged<bool>? onOnlyReadyChanged;

  const RecipeBookView({
    super.key,
    required this.catalog,
    required this.state,
    required this.header,
    this.onlyReady = false,
    this.onOnlyReadyChanged,
  });

  /// Le Tavole che hai, Mitiche comprese: il numero nella testata del Laboratorio.
  static int platesOf(Catalog catalog, GameState state) =>
      collectedPages(catalog, state).fold(0, (sum, p) => sum + p.knownCount) + knownMythicIds(catalog, state).length;

  @override
  Widget build(BuildContext context) {
    final ready = preparableIds(catalog, state, Get.find<ProgressController>().now);
    // Quante pozioni prepari comunque con le Vis condivise tra le Tavole di una pagina (o tra le Mitiche): "2+".
    ({int least, bool more}) brewsOf(Iterable<String> ids) => groupBrews([
      for (final id in ids)
        if (ready.contains(id)) ?brewableOf(catalog, id),
    ], state.essences);
    final all = collectedPages(catalog, state);
    final pages = onlyReady ? all.where((p) => p.page.recipes.any((r) => ready.contains(r.id))).toList() : all;
    final mythicsReady = catalog.mythics.any((m) => ready.contains(m.id));
    return CustomScrollView(
      key: const ValueKey('recipe-book'),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(Gaps.l, MediaQuery.paddingOf(context).top + Gaps.l, Gaps.l, Gaps.l),
          sliver: SliverToBoxAdapter(child: header),
        ),
        if (all.isNotEmpty || onlyReady)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gaps.l, 0, Gaps.l, Gaps.l),
            sliver: SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ClayChip(
                  key: const ValueKey('recipe-book-only-ready'),
                  label: context.l10n.recipeBookOnlyReady,
                  avatar: const ReadyMark(size: 18),
                  selected: onlyReady,
                  onTap: onOnlyReadyChanged == null ? null : () => onOnlyReadyChanged!(!onlyReady),
                ),
              ),
            ),
          ),
        if (catalog.mythics.isNotEmpty && (!onlyReady || mythicsReady))
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gaps.l, 0, Gaps.l, Gaps.l),
            sliver: SliverToBoxAdapter(
              child: _MythicsRow(
                catalog: catalog,
                state: state,
                brews: mythicsReady ? brewsOf(catalog.mythics.map((m) => m.id)) : null,
              ),
            ),
          ),
        if (pages.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gaps.l, Gaps.s, Gaps.l, homeBottomInset),
            sliver: SliverToBoxAdapter(
              child: Text(
                onlyReady && !mythicsReady ? context.l10n.recipeBookNoneReady : context.l10n.recipesEmpty,
                key: ValueKey(onlyReady ? 'recipe-book-none-ready' : 'recipe-book-empty'),
                style: TextStyle(color: context.druid.hint),
              ),
            ),
          )
        else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gaps.l, 0, Gaps.l, Gaps.m),
            sliver: SliverToBoxAdapter(
              child: Text(
                // Il conto di tutto il Ricettario, anche con il filtro: dice che cosa hai, non che cosa vedi.
                context.l10n.recipeBookPagesSummary(
                  all.length,
                  recipeBookOf(catalog).pages.length,
                  all.where((p) => p.complete).length,
                ),
                key: const ValueKey('recipe-book-pages-summary'),
                style: context.texts.bodySmall?.copyWith(color: context.druid.hint),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gaps.l, 0, Gaps.l, homeBottomInset),
            sliver: SliverList.separated(
              itemCount: pages.length,
              separatorBuilder: (_, _) => const SizedBox(height: Gaps.m),
              // Un RepaintBoundary per riga: scorrendo non si ridipingono tutte (CLAUDE.md, prestazioni).
              itemBuilder: (context, i) => RepaintBoundary(
                child: _PageRow(
                  collected: pages[i],
                  brews: pages[i].page.recipes.any((r) => ready.contains(r.id))
                      ? brewsOf(pages[i].page.recipes.map((r) => r.id))
                      : null,
                  onlyReady: onlyReady,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// La riga speciale delle Mitiche della Zona: c'è sempre, anche a 0, come promessa di cosa si può trovare.
class _MythicsRow extends StatelessWidget {
  final Catalog catalog;
  final GameState state;

  /// Le pozioni che prepari con le Mitiche; `null` se nessuna è preparabile.
  final ({int least, bool more})? brews;

  const _MythicsRow({required this.catalog, required this.state, required this.brews});

  @override
  Widget build(BuildContext context) {
    final known = knownMythicIds(catalog, state);
    return GradeCard(
      key: const ValueKey('recipe-book-mythics'),
      grade: Grade.mythic,
      onTap: () => Get.to<void>(() => const MythicsPage()),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: context.druid.gradeColor(Grade.mythic.index)),
          const SizedBox(width: Gaps.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.recipeBookMythicsRow(catalog.regionName.resolve(context.contentLanguage)),
                  style: context.texts.titleMedium,
                ),
                const SizedBox(height: Gaps.xs),
                Wrap(
                  spacing: Gaps.xs,
                  children: [
                    for (final m in catalog.mythics)
                      GradeDot(
                        grade: Grade.mythic,
                        label: context.game.grade(Grade.mythic),
                        filled: known.contains(m.id),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (brews case final b?) ReadyCount(count: b.least, more: b.more),
        ],
      ),
    );
  }
}

/// Una riga dell'indice: foto, nome, cerchietti delle Tavole e quante ne hai.
class _PageRow extends StatelessWidget {
  final CollectedPage collected;

  /// Le pozioni che prepari con le Tavole della pagina; `null` se nessuna è preparabile.
  final ({int least, bool more})? brews;

  /// Il filtro è acceso: le pagine da sfogliare sono solo quelle con una Tavola preparabile.
  final bool onlyReady;

  const _PageRow({required this.collected, required this.brews, required this.onlyReady});

  @override
  Widget build(BuildContext context) {
    final plant = collected.page.plant;
    return ClayCard(
      key: ValueKey('recipe-book-page-${plant.sci}'),
      padding: const EdgeInsets.all(Gaps.m),
      onTap: () => Get.to<void>(() => PlantPagesPage(initialSci: plant.sci, onlyReady: onlyReady)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox.square(
              dimension: 56,
              child: plant.images.isEmpty ? const SizedBox.shrink() : RemoteImage(plant.images.first.url),
            ),
          ),
          const SizedBox(width: Gaps.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.game.name(plant), style: speciesNameStyle(context, context.texts.titleMedium)),
                const SizedBox(height: Gaps.xs),
                PageDots(collected: collected),
              ],
            ),
          ),
          // Quante pozioni prepari, non quante Tavole hai: quelle le dicono i cerchietti (2026-10-29).
          if (brews case final b?) ...[const SizedBox(width: Gaps.s), ReadyCount(count: b.least, more: b.more)],
        ],
      ),
    );
  }
}
