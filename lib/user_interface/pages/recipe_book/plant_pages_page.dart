import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/business_logic/rules/recipes/recipe_book.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/engraved_icon.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/common_widgets/potion_vessel.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/recipe_book/recipe_page.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/recipe_vessel.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Le Pagine del Ricettario, da sfogliare a destra e a sinistra nell'ordine dell'indice, a partire da [initialSci].
class PlantPagesPage extends StatefulWidget {
  final String initialSci;

  const PlantPagesPage({super.key, required this.initialSci});

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
          builder: (context, catalog, state, _) {
            final pages = collectedPages(catalog, state);
            final start = pages.indexWhere((p) => p.page.plant.sci == widget.initialSci);
            _controller ??= PageController(initialPage: start < 0 ? 0 : start);
            return PageView.builder(
              key: const ValueKey('recipe-book-pager'),
              controller: _controller,
              itemCount: pages.length,
              itemBuilder: (context, i) => _PlantPageView(collected: pages[i], showSwipeHint: pages.length > 1),
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

  const _PlantPageView({required this.collected, required this.showSwipeHint});

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
            Expanded(child: Text(context.game.name(plant), style: context.texts.headlineSmall)),
            Pill(context.l10n.recipeBookPageCount(collected.knownCount, page.recipes.length)),
          ],
        ),
        const SizedBox(height: Gaps.m),
        _PillRow(label: context.l10n.recipeBookFavouredTraits, pills: page.favouredTraits.map(context.game.trait)),
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
              collected.knows(recipe) ? _Plate(recipe: recipe) : _EmptySlot(recipe: recipe),
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

  const _Plate({required this.recipe});

  @override
  Widget build(BuildContext context) => GestureDetector(
    key: ValueKey('plate-${recipe.id}'),
    onTap: () => Get.to<void>(() => PlantRecipePage(recipeId: recipe.id)),
    child: GradeCard(
      grade: recipe.grade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradeDot(grade: recipe.grade, label: context.game.grade(recipe.grade)),
              const Spacer(),
              Tooltip(
                message: context.game.effect(recipe.effect),
                child: EngravedIcon(effectIconOf(recipe.effect), size: 18),
              ),
            ],
          ),
          Expanded(child: _VesselSlot(recipe: recipe)),
          Text(
            recipe.name(context.contentLanguage),
            style: context.texts.titleMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
          Expanded(child: _VesselSlot(recipe: recipe, empty: true)),
          Text(context.game.grade(recipe.grade), style: TextStyle(color: context.druid.hint)),
        ],
      ),
    ),
  );
}

/// Il recipiente nello spazio libero della scheda, tra il cerchietto e il nome: grande quanto ci sta, fino a 88.
class _VesselSlot extends StatelessWidget {
  final PlantRecipe recipe;
  final bool empty;

  const _VesselSlot({required this.recipe, this.empty = false});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = (constraints.maxHeight - Gaps.s).clamp(0.0, 88.0);
      return Center(
        child: RecipeVessel(recipe: recipe, size: size, empty: empty),
      );
    },
  );
}
