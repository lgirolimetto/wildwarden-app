import 'package:druid_app/l10n/app_localizations.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:flutter/material.dart';

/// Termini del glossario dell'erborista: il significato botanico vero e il loro uso nel gioco.
enum GlossaryTerm { erbario, desiderata, erborizzare, stazione, tratto, attingere, maestria, missione }

extension GlossaryTexts on GlossaryTerm {
  String term(AppLocalizations l10n) => switch (this) {
    GlossaryTerm.erbario => l10n.glossErbarioTerm,
    GlossaryTerm.desiderata => l10n.glossDesiderataTerm,
    GlossaryTerm.erborizzare => l10n.glossErborizzareTerm,
    GlossaryTerm.stazione => l10n.glossStazioneTerm,
    GlossaryTerm.tratto => l10n.glossTrattoTerm,
    GlossaryTerm.attingere => l10n.glossAttingereTerm,
    GlossaryTerm.maestria => l10n.glossMaestriaTerm,
    GlossaryTerm.missione => l10n.glossMissioneTerm,
  };

  String text(AppLocalizations l10n) => switch (this) {
    GlossaryTerm.erbario => l10n.glossErbarioText,
    GlossaryTerm.desiderata => l10n.glossDesiderataText,
    GlossaryTerm.erborizzare => l10n.glossErborizzareText,
    GlossaryTerm.stazione => l10n.glossStazioneText,
    GlossaryTerm.tratto => l10n.glossTrattoText,
    GlossaryTerm.attingere => l10n.glossAttingereText,
    GlossaryTerm.maestria => l10n.glossMaestriaText,
    GlossaryTerm.missione => l10n.glossMissioneText,
  };
}

/// Apre la scheda di un termine dal basso.
Future<void> showGlossaryTerm(BuildContext context, GlossaryTerm term) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (context) => Padding(
    padding: const EdgeInsets.fromLTRB(Gaps.xl, 0, Gaps.xl, Gaps.xl),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(term.term(context.l10n), style: context.texts.titleLarge),
        const SizedBox(height: Gaps.s),
        Text(term.text(context.l10n), style: context.texts.bodyLarge),
      ],
    ),
  ),
);

/// Collegamento a un termine del glossario, da mettere sotto un testo.
class GlossaryChip extends StatelessWidget {
  final GlossaryTerm term;

  const GlossaryChip(this.term, {super.key});

  @override
  Widget build(BuildContext context) => ClayChip(
    avatar: const Icon(Icons.menu_book_outlined, size: 16),
    label: term.term(context.l10n),
    onTap: () => showGlossaryTerm(context, term),
  );
}

class GlossaryPage extends StatelessWidget {
  const GlossaryPage({super.key});

  @override
  Widget build(BuildContext context) => DenseArea(child: _page(context));

  Widget _page(BuildContext context) => Scaffold(
    appBar: clayAppBar(context, title: context.l10n.glossaryTitle),
    extendBodyBehindAppBar: true,
    body: DruidBackground(
      belowAppBar: true,
      child: ListView.separated(
        padding: const EdgeInsets.all(Gaps.l),
        itemCount: GlossaryTerm.values.length,
        separatorBuilder: (_, _) => const Divider(height: Gaps.xl),
        itemBuilder: (context, i) {
          final term = GlossaryTerm.values[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(term.term(context.l10n), style: context.texts.titleMedium),
              const SizedBox(height: Gaps.xs),
              Text(term.text(context.l10n)),
            ],
          );
        },
      ),
    ),
  );
}
