import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';
import 'package:druid_app/controllers/subscription/subscription_controller.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Apre il taccuino se il Diario è attivo, altrimenti spiega cosa offre.
void openNotebook(BuildContext context) {
  if (Get.find<SubscriptionController>().diarioActive) {
    Get.to<void>(() => const NotebookPage());
  } else {
    showDiarioUpsell(context);
  }
}

Future<void> showDiarioUpsell(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (context) => Padding(
    padding: const EdgeInsets.fromLTRB(Gaps.xl, 0, Gaps.xl, Gaps.xl),
    child: Text(context.l10n.diarioUpsell, key: const ValueKey('diario-upsell'), style: context.texts.bodyLarge),
  ),
);

/// Taccuino del Diario dell'Erborista: fatti salvati e note, ricercabili.
class NotebookPage extends StatefulWidget {
  const NotebookPage({super.key});

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) => DenseArea(child: _page(context));

  Widget _page(BuildContext context) => Scaffold(
    appBar: clayAppBar(context, title: context.l10n.notebookTitle),
    extendBodyBehindAppBar: true,
    body: DruidBackground(
      belowAppBar: true,
      child: GameDataBuilder(
        builder: (context, catalog, state, _) {
          final entries = _entries(
            context,
            catalog,
            state,
          ).where((e) => _query.isEmpty || e.searchable.toLowerCase().contains(_query.toLowerCase())).toList();
          return ListView(
            padding: const EdgeInsets.all(Gaps.l),
            children: [
              TextField(
                key: const ValueKey('notebook-search'),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: context.l10n.notebookSearch,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: Gaps.l),
              if (entries.isEmpty)
                Text(
                  state.notebook.isEmpty && state.notes.isEmpty
                      ? context.l10n.notebookEmpty
                      : context.l10n.notebookNoResults,
                ),
              for (final entry in entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 48,
                    height: 48,
                    child: ClipRRect(borderRadius: BorderRadius.circular(8), child: RemoteImage(entry.imageUrl)),
                  ),
                  title: Text(entry.title),
                  subtitle: Text(entry.text),
                ),
            ],
          );
        },
      ),
    ),
  );

  List<({String title, String text, String imageUrl, String searchable})> _entries(
    BuildContext context,
    Catalog catalog,
    GameState state,
  ) {
    final game = context.game;
    return [
      for (final id in state.notebook)
        if (catalog.speciesBySci(Fact.parseId(id).speciesSci) case final species?)
          () {
            final text = game.fact(Fact(species, Fact.parseId(id).kind), catalog);
            return (
              title: game.name(species),
              text: text,
              imageUrl: species.images.first.url,
              searchable: '${game.name(species)} ${species.sci} ${species.family} $text',
            );
          }(),
      for (final note in state.notes.entries)
        if (note.value.trim().isNotEmpty)
          if (catalog.speciesBySci(note.key) case final species?)
            (
              title: game.name(species),
              text: '📝 ${note.value}',
              imageUrl: species.images.first.url,
              searchable: '${game.name(species)} ${species.sci} ${note.value}',
            ),
    ];
  }
}
