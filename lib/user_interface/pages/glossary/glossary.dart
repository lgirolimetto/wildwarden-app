import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/l10n/app_localizations.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/inset_badge.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/erbario/level_name.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Termini del glossario dell'erborista: il significato botanico vero e il loro uso nel gioco.
/// Le voci riprendono `idee/glossario.md` del core, che è il riferimento dei termini.
enum GlossaryTerm {
  erbario,
  desiderata,
  erborizzare,
  protetta,
  stazione,
  attingere,
  essenza,
  vis,
  tratto,
  peDaIncassare,
  maestria,
  missione,
  grado,
  bottino,
  figurina,
}

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
    GlossaryTerm.protetta => l10n.glossProtettaTerm,
    GlossaryTerm.essenza => l10n.glossEssenzaTerm,
    GlossaryTerm.vis => l10n.glossVisTerm,
    GlossaryTerm.peDaIncassare => l10n.glossPeDaIncassareTerm,
    GlossaryTerm.grado => l10n.glossGradoTerm,
    GlossaryTerm.bottino => l10n.glossBottinoTerm,
    GlossaryTerm.figurina => l10n.glossFigurinaTerm,
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
    GlossaryTerm.protetta => l10n.glossProtettaText,
    GlossaryTerm.essenza => l10n.glossEssenzaText,
    GlossaryTerm.vis => l10n.glossVisText,
    GlossaryTerm.peDaIncassare => l10n.glossPeDaIncassareText,
    GlossaryTerm.grado => l10n.glossGradoText,
    GlossaryTerm.bottino => l10n.glossBottinoText,
    GlossaryTerm.figurina => l10n.glossFigurinaText,
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

/// Legenda e glossario: prima i simboli dell'app (gradi, bollini, livelli, tratti), poi i termini del gioco.
class GlossaryPage extends StatefulWidget {
  const GlossaryPage({super.key});

  @override
  State<GlossaryPage> createState() => _GlossaryPageState();
}

class _GlossaryPageState extends State<GlossaryPage> {
  /// 0 = Legenda, 1 = Glossario: due linguette invece di due titoli, per non perdere spazio.
  var _tab = 0;

  @override
  Widget build(BuildContext context) => DenseArea(child: _page(context));

  Widget _page(BuildContext context) => Scaffold(
    appBar: clayAppBar(context, title: context.l10n.glossaryTitle),
    extendBodyBehindAppBar: true,
    body: DruidBackground(
      belowAppBar: true,
      child: ListView(
        padding: const EdgeInsets.all(Gaps.l),
        children: [
          ClayTabs(
            tabs: [
              ClayTab(label: context.l10n.legendTitle),
              ClayTab(label: context.l10n.glossarySection),
            ],
            selected: _tab,
            onChanged: (tab) => setState(() => _tab = tab),
          ),
          const SizedBox(height: Gaps.l),
          if (_tab == 0)
            const _Legend()
          else
            for (final (i, term) in GlossaryTerm.values.indexed) ...[
              if (i > 0) const Divider(height: Gaps.xl),
              Text(term.term(context.l10n), key: ValueKey('gloss-${term.name}'), style: context.texts.titleMedium),
              const SizedBox(height: Gaps.xs),
              Text(term.text(context.l10n)),
            ],
        ],
      ),
    ),
  );
}

/// I simboli dell'app, ognuno con il suo significato.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final game = context.game;
    return ClayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.legendGrades, style: context.texts.titleSmall),
          const SizedBox(height: Gaps.s),
          for (final grade in Grade.values)
            _LegendRow(
              symbol: GradeDot(grade: grade, label: game.grade(grade)),
              text: game.grade(grade),
            ),
          const SizedBox(height: Gaps.m),
          Text(l10n.legendBadges, style: context.texts.titleSmall),
          const SizedBox(height: Gaps.s),
          _LegendRow(
            symbol: const ProtectedShield(),
            text: l10n.legendProtected,
          ),
          _LegendRow(
            symbol: StampBadge(
              text: DateFormat.MMMd(context.contentLanguage).format(DateTime(2027, 2, 3)),
              label: l10n.badgeEncountered,
            ),
            text: l10n.legendEncountered,
          ),
          _LegendRow(
            symbol: Icon(Icons.hourglass_top_rounded, color: context.colors.onSurface),
            text: l10n.legendXpToCash,
          ),
          const SizedBox(height: Gaps.m),
          Text(l10n.legendLevels, style: context.texts.titleSmall),
          const SizedBox(height: Gaps.s),
          for (var level = 1; level <= 4; level++)
            _LegendRow(
              symbol: ClayCircle(color: context.druid.levelColor(level), size: 18),
              text: '$level · ${levelName(l10n, level)}',
            ),
          const SizedBox(height: Gaps.m),
          Text(l10n.legendTraits, style: context.texts.titleSmall),
          const SizedBox(height: Gaps.s),
          // Per tipo: luce del giorno, luna, meteo (capitolo 02).
          for (final group in TraitGroup.values) ...[
            Padding(
              padding: const EdgeInsets.only(top: Gaps.xs, bottom: Gaps.s),
              child: Text(game.traitGroup(group), style: context.texts.labelLarge),
            ),
            for (final trait in group.traits)
              Padding(
                padding: const EdgeInsets.only(bottom: Gaps.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Pill(game.trait(trait)),
                    Text(game.traitWhen(trait), style: context.texts.bodySmall),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Widget symbol;
  final String text;

  const _LegendRow({required this.symbol, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Gaps.s),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Align(alignment: Alignment.centerLeft, child: symbol),
        ),
        const SizedBox(width: Gaps.s),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
