import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/mythic.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/album.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/album/plant_album_page.dart';
import 'package:druid_app/user_interface/pages/album/recipe_page.dart';
import 'package:druid_app/user_interface/pages/album/widgets/page_dots.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// L'Album: le Pagine delle piante di cui conosci almeno una Figurina, e le Mitiche numerate (capitolo 02, "Ricette ad
/// affissi e pagine per pianta"). Due linguette; allo step 9 della tappa C arriva lo Scaffale delle pozioni.
class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => DenseArea(
    paintBackground: true,
    child: GameDataBuilder(
      builder: (context, catalog, state, _) {
        final pages = albumPages(catalog, state);
        final figurines = pages.fold(0, (sum, p) => sum + p.knownCount) + knownMythicIds(catalog, state).length;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(Gaps.l, MediaQuery.paddingOf(context).top + Gaps.l, Gaps.l, Gaps.m),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClayPageHeader(
                      title: context.l10n.albumTitle,
                      icon: Icons.collections_bookmark_rounded,
                      iconColor: context.druid.levelColor(4),
                      trailing: Pill(context.l10n.albumFigurines(figurines), key: const ValueKey('album-count')),
                    ),
                    const SizedBox(height: Gaps.l),
                    ClayTabs(
                      tabs: [
                        ClayTab(key: const ValueKey('album-tab-plants'), label: context.l10n.albumTabPlants),
                        ClayTab(key: const ValueKey('album-tab-mythics'), label: context.l10n.albumTabMythics),
                      ],
                      selected: _tab,
                      onChanged: (tab) => setState(() => _tab = tab),
                    ),
                  ],
                ),
              ),
            ),
            if (_tab == 0) ..._plants(context, catalog, pages) else ..._mythics(context, catalog, state),
          ],
        );
      },
    ),
  );

  List<Widget> _plants(BuildContext context, Catalog catalog, List<AlbumEntry> pages) {
    if (pages.isEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gaps.l, Gaps.s, Gaps.l, homeBottomInset),
          sliver: SliverToBoxAdapter(
            child: Text(
              context.l10n.recipesEmpty,
              key: const ValueKey('album-empty'),
              style: TextStyle(color: context.druid.hint),
            ),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(Gaps.l, 0, Gaps.l, Gaps.m),
        sliver: SliverToBoxAdapter(
          child: Text(
            context.l10n.albumPagesSummary(
              pages.length,
              recipeBookOf(catalog).pages.length,
              pages.where((p) => p.complete).length,
            ),
            key: const ValueKey('album-pages-summary'),
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
            child: _PageRow(pages: pages, index: i),
          ),
        ),
      ),
    ];
  }

  List<Widget> _mythics(BuildContext context, Catalog catalog, GameState state) {
    final known = knownMythicIds(catalog, state);
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(Gaps.l, 0, Gaps.l, Gaps.m),
        sliver: SliverToBoxAdapter(
          child: Text(context.l10n.mythicsIntro, style: context.texts.bodySmall?.copyWith(color: context.druid.hint)),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(Gaps.l, 0, Gaps.l, homeBottomInset),
        sliver: SliverList.separated(
          itemCount: catalog.mythics.length,
          separatorBuilder: (_, _) => const SizedBox(height: Gaps.m),
          itemBuilder: (context, i) => RepaintBoundary(
            child: _MythicRow(mythic: catalog.mythics[i], known: known.contains(catalog.mythics[i].id)),
          ),
        ),
      ),
    ];
  }
}

/// Una riga dell'indice: foto, nome, cerchietti delle figurine e quante ne hai.
class _PageRow extends StatelessWidget {
  final List<AlbumEntry> pages;
  final int index;

  const _PageRow({required this.pages, required this.index});

  @override
  Widget build(BuildContext context) {
    final album = pages[index];
    final plant = album.page.plant;
    return ClayCard(
      key: ValueKey('album-page-${plant.sci}'),
      padding: const EdgeInsets.all(Gaps.m),
      onTap: () => Get.to<void>(() => PlantAlbumPage(initialSci: plant.sci)),
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
                Text(context.game.name(plant), style: context.texts.titleMedium),
                const SizedBox(height: Gaps.xs),
                PageDots(album: album),
              ],
            ),
          ),
          Text(context.l10n.albumPageCount(album.knownCount, album.page.recipes.length)),
        ],
      ),
    );
  }
}

/// Una Mitica nell'album numerato: il numero sempre, il nome solo se la conosci.
class _MythicRow extends StatelessWidget {
  final Mythic mythic;
  final bool known;

  const _MythicRow({required this.mythic, required this.known});

  @override
  Widget build(BuildContext context) {
    final number = context.l10n.mythicNumber(mythic.number.toString().padLeft(3, '0'));
    return GradeCard(
      key: ValueKey('mythic-${mythic.id}'),
      grade: Grade.mythic,
      child: InkWell(
        onTap: known ? () => Get.to<void>(() => MythicRecipePage(mythicId: mythic.id)) : null,
        child: Row(
          children: [
            GradeDot(grade: Grade.mythic, label: context.game.grade(Grade.mythic), filled: known),
            const SizedBox(width: Gaps.m),
            Text(number, style: context.texts.labelLarge),
            const SizedBox(width: Gaps.m),
            Expanded(
              child: Text(
                known ? mythic.name(context.contentLanguage) : context.l10n.mythicToFind,
                style: known ? context.texts.titleMedium : TextStyle(color: context.druid.hint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
