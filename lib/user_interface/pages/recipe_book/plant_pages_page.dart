import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/recipes/affinity.dart';
import 'package:druid_app/business_logic/rules/recipes/brewing.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/business_logic/rules/recipes/recipe_book.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/recipe_book/recipe_page.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/plate_face.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/recipe_vessel.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/user_interface/common_widgets/species_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Le Pagine del Ricettario, da sfogliare a destra e a sinistra nell'ordine dell'indice, a partire da [initialSci]. Con
/// [onlyReady] (il filtro dell'indice) solo le pagine con una Tavola preparabile adesso.
class PlantPagesPage extends StatefulWidget {
  final String initialSci;
  final bool onlyReady;

  const PlantPagesPage({super.key, required this.initialSci, this.onlyReady = false});

  @override
  State<PlantPagesPage> createState() => _PlantPagesPageState();
}

class _PlantPagesPageState extends State<PlantPagesPage> {
  PageController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DenseArea(
    child: Scaffold(
      appBar: clayAppBar(context, title: context.l10n.recipeBookTitle),
      extendBodyBehindAppBar: true,
      body: DruidBackground(
        belowAppBar: true,
        child: GameDataBuilder(
          builder: (context, catalog, state, progress) {
            // Quante pozioni prepari di ogni Tavola, con le Vis che hai (solo quelle preparabili adesso).
            final ready = preparableIds(catalog, state, progress.now);
            final brews = {
              for (final id in ready)
                if (brewableOf(catalog, id) case final brewable?) id: brewsOf(brewable, state.essences),
            };
            final pages = [
              for (final p in collectedPages(catalog, state))
                if (!widget.onlyReady || p.page.recipes.any((r) => ready.contains(r.id))) p,
            ];
            final start = pages.indexWhere((p) => p.page.plant.sci == widget.initialSci);
            _controller ??= PageController(initialPage: start < 0 ? 0 : start);
            return PageView.builder(
              key: const ValueKey('recipe-book-pager'),
              controller: _controller,
              itemCount: pages.length,
              itemBuilder: (context, i) => _PlantPageView(
                collected: pages[i],
                showSwipeHint: pages.length > 1,
                bestPotency: state.bestPotency,
                brews: brews,
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _PlantPageView extends StatelessWidget {
  final CollectedPage collected;
  final bool showSwipeHint;

  /// La potenza migliore di ogni ricetta preparata.
  final Map<String, int> bestPotency;

  /// Quante pozioni prepari adesso di ogni Tavola preparabile.
  final Map<String, int> brews;

  const _PlantPageView({
    required this.collected,
    required this.showSwipeHint,
    required this.bestPotency,
    required this.brews,
  });

  @override
  Widget build(BuildContext context) {
    final page = collected.page;
    final plant = page.plant;
    return ListView(
      key: ValueKey('plant-page-${plant.sci}'),
      padding: const EdgeInsets.fromLTRB(Gaps.l, Gaps.s, Gaps.l, Gaps.xl),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: plant.images.isEmpty ? const SizedBox.shrink() : RemoteImage(plant.images.first.url),
          ),
        ),
        const SizedBox(height: Gaps.m),
        Row(
          children: [
            Expanded(
              child: Text(context.game.name(plant), style: speciesNameStyle(context, context.texts.headlineSmall)),
            ),
            Pill(context.l10n.recipeBookPageCount(collected.knownCount, page.recipes.length)),
          ],
        ),
        const SizedBox(height: Gaps.m),
        // Le Affinità solo a parole (2026-10-29): come vive la pianta, non quali Qualia chiederanno le Tavole.
        _Affinity(plant: plant),
        const SizedBox(height: Gaps.m),
        _PillRow(label: context.l10n.recipeBookVocation, pills: page.vocation.map(context.game.effect)),
        const SizedBox(height: Gaps.l),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.85,
          crossAxisSpacing: Gaps.l,
          mainAxisSpacing: Gaps.xl,
          children: [
            for (final recipe in page.recipes)
              collected.knows(recipe)
                  ? _Plate(
                      recipe: recipe,
                      missing: collected.missingOf(recipe),
                      bestPotency: bestPotency[recipe.id],
                      brews: brews[recipe.id] ?? 0,
                    )
                  : _EmptySlot(recipe: recipe),
          ],
        ),
        if (showSwipeHint) ...[
          const SizedBox(height: Gaps.l),
          Center(
            child: Text(
              context.l10n.recipeBookSwipeHint,
              style: context.texts.bodySmall?.copyWith(color: context.druid.hint),
            ),
          ),
        ],
      ],
    );
  }
}

class _PillRow extends StatelessWidget {
  final String label;
  final Iterable<String> pills;

  const _PillRow({required this.label, required this.pills});

  /// Le pillole sono piatte, con il solo bordo: tra le righe basta poco spazio (quello di [Gaps.chipRun] serve alle
  /// ombre del rilievo).
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.texts.labelMedium?.copyWith(color: context.druid.hint)),
      const SizedBox(height: Gaps.xs),
      Wrap(spacing: Gaps.s, runSpacing: Gaps.s, children: [for (final p in pills) Pill(p)]),
    ],
  );
}

/// Una Tavola che hai: grado e nome (intero o, dal Bottino, parziale). Un tocco apre la ricetta.
class _Plate extends StatelessWidget {
  final PlantRecipe recipe;
  final int missing;

  /// La potenza migliore raggiunta, se l'hai preparata.
  final int? bestPotency;

  /// Quante pozioni ne prepari adesso.
  final int brews;

  const _Plate({required this.recipe, required this.missing, this.bestPotency, required this.brews});

  @override
  Widget build(BuildContext context) => GestureDetector(
    key: ValueKey('plate-${recipe.id}'),
    onTap: () => Get.to<void>(() => PlantRecipePage(recipeId: recipe.id)),
    child: GradeCard(
      grade: recipe.grade,
      child: PlateFace(
        recipe: recipe,
        missing: missing,
        brews: brews,
        caption: switch (bestPotency) {
          final int best when missing == 0 => context.l10n.recipeBestPotency(best),
          _ => null,
        },
      ),
    ),
  );
}

/// Una Tavola che manca: solo il cerchietto del grado (decisione del 2026-10-27: nella pagina lo slot vuoto ha già
/// un indizio, la pianta e il grado).
class _EmptySlot extends StatelessWidget {
  final PlantRecipe recipe;

  const _EmptySlot({required this.recipe});

  @override
  Widget build(BuildContext context) => Opacity(
    key: ValueKey('empty-slot-${recipe.id}'),
    opacity: 0.6,
    child: GradeCard(
      grade: recipe.grade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradeDot(grade: recipe.grade, label: context.l10n.recipeBookMissingPlate, filled: false),
          Expanded(
            child: VesselSlot(
              builder: (size) => RecipeVessel(recipe: recipe, size: size, empty: true),
            ),
          ),
          Text(context.game.grade(recipe.grade), style: TextStyle(color: context.druid.hint)),
        ],
      ),
    ),
  );
}

/// Le Affinità della pianta: il titolo e una frase dai dati del catalogo (luce, umidità, quota).
class _Affinity extends StatelessWidget {
  final Species plant;

  const _Affinity({required this.plant});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = affinityProfile(plant);
    final bands = [
      for (final b in profile.bands)
        switch (b) {
          AltitudeBand.plain => l10n.affinityBandPlain,
          AltitudeBand.hill => l10n.affinityBandHill,
          AltitudeBand.mountain => l10n.affinityBandMountain,
        },
    ];
    final sentence = [
      ?switch (profile.light) {
        LightLiking.full => l10n.affinityLightFull,
        LightLiking.half => l10n.affinityLightHalf,
        LightLiking.shade => l10n.affinityLightShade,
        null => null,
      },
      ?switch (profile.moisture) {
        MoistureLiking.dry => l10n.affinityMoistureDry,
        MoistureLiking.damp => l10n.affinityMoistureDamp,
        null => null,
      },
      if (bands.isNotEmpty) l10n.affinityBands(bands.join(l10n.affinityAnd)),
    ].join(' ');
    if (sentence.isEmpty) return const SizedBox.shrink();
    return Column(
      key: const ValueKey('plant-affinity'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recipeBookFavouredTraits, style: context.texts.labelMedium?.copyWith(color: context.druid.hint)),
        const SizedBox(height: Gaps.xs),
        Text(sentence, style: context.texts.bodyMedium),
      ],
    );
  }
}
