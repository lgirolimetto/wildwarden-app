import 'package:druid_app/business_logic/rules/recipes/album.dart';
import 'package:druid_app/business_logic/rules/recipes/recipe_book.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/album/recipe_page.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Le Pagine dell'album, da sfogliare a destra e a sinistra nell'ordine dell'indice, a partire da [initialSci].
class PlantAlbumPage extends StatefulWidget {
  final String initialSci;

  const PlantAlbumPage({super.key, required this.initialSci});

  @override
  State<PlantAlbumPage> createState() => _PlantAlbumPageState();
}

class _PlantAlbumPageState extends State<PlantAlbumPage> {
  PageController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DenseArea(
    child: Scaffold(
      appBar: clayAppBar(context, title: context.l10n.albumTitle),
      extendBodyBehindAppBar: true,
      body: DruidBackground(
        belowAppBar: true,
        child: GameDataBuilder(
          builder: (context, catalog, state, _) {
            final pages = albumPages(catalog, state);
            final start = pages.indexWhere((p) => p.page.plant.sci == widget.initialSci);
            _controller ??= PageController(initialPage: start < 0 ? 0 : start);
            return PageView.builder(
              key: const ValueKey('album-pager'),
              controller: _controller,
              itemCount: pages.length,
              itemBuilder: (context, i) => _PlantPageView(album: pages[i], showSwipeHint: pages.length > 1),
            );
          },
        ),
      ),
    ),
  );
}

class _PlantPageView extends StatelessWidget {
  final AlbumEntry album;
  final bool showSwipeHint;

  const _PlantPageView({required this.album, required this.showSwipeHint});

  @override
  Widget build(BuildContext context) {
    final page = album.page;
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
            Expanded(child: Text(context.game.name(plant), style: context.texts.headlineSmall)),
            Pill(context.l10n.albumPageCount(album.knownCount, page.recipes.length)),
          ],
        ),
        const SizedBox(height: Gaps.m),
        _PillRow(label: context.l10n.albumFavouredTraits, pills: page.favouredTraits.map(context.game.trait)),
        const SizedBox(height: Gaps.s),
        _PillRow(label: context.l10n.albumVocation, pills: page.vocation.map(context.game.effect)),
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
              album.knows(recipe) ? _Figurine(recipe: recipe) : _EmptySlot(recipe: recipe),
          ],
        ),
        if (showSwipeHint) ...[
          const SizedBox(height: Gaps.l),
          Center(
            child: Text(
              context.l10n.albumSwipeHint,
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

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Gaps.chip,
    runSpacing: Gaps.chipRun,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(label, style: context.texts.labelMedium?.copyWith(color: context.druid.hint)),
      for (final p in pills) Pill(p),
    ],
  );
}

/// Una figurina che hai: grado e nome (intero o, dal Bottino, parziale). Un tocco apre la ricetta.
class _Figurine extends StatelessWidget {
  final PlantRecipe recipe;

  const _Figurine({required this.recipe});

  @override
  Widget build(BuildContext context) => GestureDetector(
    key: ValueKey('figurine-${recipe.id}'),
    onTap: () => Get.to<void>(() => PlantRecipePage(recipeId: recipe.id)),
    child: GradeCard(
      grade: recipe.grade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradeDot(grade: recipe.grade, label: context.game.grade(recipe.grade)),
          const Spacer(),
          Text(
            recipe.name(context.contentLanguage),
            style: context.texts.titleMedium,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

/// Una figurina che manca: solo il cerchietto del grado (decisione del 2026-10-27: nella pagina lo slot vuoto ha già
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
          GradeDot(grade: recipe.grade, label: context.l10n.albumMissingFigurine, filled: false),
          const Spacer(),
          Text(context.game.grade(recipe.grade), style: TextStyle(color: context.druid.hint)),
        ],
      ),
    ),
  );
}
