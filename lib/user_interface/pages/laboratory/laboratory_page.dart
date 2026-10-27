import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/rules/economy.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/trove.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/accent_card.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/laboratory/trove_opening_page.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Il Laboratorio, il capanno-serra della Home: dove si lavora (capitolo 02, "Ricettario, Tavole, Laboratorio e
/// Zone"). Oggi c'è solo il Bottino; Dispensa, Ricette pronte e Scaffale arrivano come linguette negli step successivi
/// della tappa C (con una sola linguetta la fila non serve).
class LaboratoryPage extends StatefulWidget {
  const LaboratoryPage({super.key});

  @override
  State<LaboratoryPage> createState() => _LaboratoryPageState();
}

class _LaboratoryPageState extends State<LaboratoryPage> {
  @override
  void initState() {
    super.initState();
    // Il regalo "bentornato" si offre quando entri: è qui che lo trovi.
    Get.find<ProgressController>().offerWelcomeGiftIfDue();
  }

  @override
  Widget build(BuildContext context) => DenseArea(
    child: Scaffold(
      appBar: clayAppBar(context, title: context.l10n.labTitle),
      extendBodyBehindAppBar: true,
      body: DruidBackground(
        belowAppBar: true,
        child: GameDataBuilder(
          builder: (context, catalog, state, progress) =>
              _TrovePane(catalog: catalog, state: state, progress: progress),
        ),
      ),
    ),
  );
}

/// Il Bottino: il saldo, il regalo se c'è, un Bottino dell'Esperienza per grado con il suo costo.
class _TrovePane extends StatelessWidget {
  final Catalog catalog;
  final GameState state;
  final ProgressController progress;

  const _TrovePane({required this.catalog, required this.state, required this.progress});

  @override
  Widget build(BuildContext context) {
    final now = progress.now;
    final gift = welcomeGiftOf(state);
    final recycled = state.recycled.values.fold(0, (a, b) => a + b);
    final hint = context.texts.bodySmall?.copyWith(color: context.druid.hint);
    return ListView(
      key: const ValueKey('laboratory-trove'),
      padding: const EdgeInsets.fromLTRB(Gaps.l, Gaps.s, Gaps.l, Gaps.xl),
      children: [
        ClayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(context.l10n.labBalance, style: context.texts.labelLarge?.copyWith(color: context.druid.hint)),
                  const Spacer(),
                  Pill(
                    context.l10n.labTrovesLeft(
                      EconomyRules.trovesPerDay - trovesToday(state, now),
                      EconomyRules.trovesPerDay,
                    ),
                  ),
                ],
              ),
              Text(context.l10n.labBalanceXp(state.balance), style: context.texts.headlineSmall),
              if (state.missingPieces.isNotEmpty || recycled > 0) ...[
                const SizedBox(height: Gaps.xs),
                Text(
                  [
                    if (state.missingPieces.isNotEmpty) context.l10n.labIncomplete(state.missingPieces.length),
                    if (recycled > 0) context.l10n.labRecycled(recycled),
                  ].join(' · '),
                  style: hint,
                ),
              ],
            ],
          ),
        ),
        if (gift != WelcomeGift.none) ...[
          const SizedBox(height: Gaps.l),
          _WelcomeGiftCard(gift: gift, state: state, progress: progress),
        ],
        const SizedBox(height: Gaps.l),
        for (final grade in Grade.values) ...[
          _TroveCard(grade: grade, block: troveBlock(state, grade, now), state: state, progress: progress),
          const SizedBox(height: Gaps.m),
        ],
        const SizedBox(height: Gaps.s),
        Text(context.l10n.troveRules, style: hint),
      ],
    );
  }
}

class _TroveCard extends StatelessWidget {
  final Grade grade;
  final TroveBlock? block;
  final GameState state;
  final ProgressController progress;

  const _TroveCard({required this.grade, required this.block, required this.state, required this.progress});

  @override
  Widget build(BuildContext context) {
    final cost = EconomyRules.troveCost(grade);
    final hint = context.texts.bodySmall?.copyWith(color: context.druid.hint);
    return GradeCard(
      key: ValueKey('trove-${grade.name}'),
      grade: grade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradeDot(grade: grade, label: context.game.grade(grade)),
              const SizedBox(width: Gaps.m),
              Expanded(
                child: Text(context.l10n.troveName(context.game.troveGrade(grade)), style: context.texts.titleMedium),
              ),
              Pill(context.l10n.troveCost(cost)),
            ],
          ),
          const SizedBox(height: Gaps.xs),
          Text(context.game.troveContents(grade), style: hint),
          const SizedBox(height: Gaps.m),
          switch (block) {
            null => ClayButton(
              key: ValueKey('open-trove-${grade.name}'),
              label: context.l10n.troveOpen,
              icon: Icons.auto_awesome_rounded,
              onPressed: () => _open(context, progress, grade),
            ),
            TroveBlock.balance => Text(context.l10n.troveNeedXp(cost - state.balance), style: hint),
            TroveBlock.dailyLimit => Text(context.l10n.troveDailyLimit(EconomyRules.trovesPerDay), style: hint),
          },
        ],
      ),
    );
  }
}

/// "Ehi, c'è un regalo per te": il primo Bottino raro a prezzo di favore, da riscattare dopo un'Essenza.
class _WelcomeGiftCard extends StatelessWidget {
  final WelcomeGift gift;
  final GameState state;
  final ProgressController progress;

  const _WelcomeGiftCard({required this.gift, required this.state, required this.progress});

  @override
  Widget build(BuildContext context) => AccentCardBox(
    key: const ValueKey('welcome-gift'),
    index: 1,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(Gaps.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.welcomeGiftTitle, style: context.texts.titleMedium),
          const SizedBox(height: Gaps.xs),
          Text(context.l10n.welcomeGiftBody(EconomyRules.welcomeTrovePrice, EconomyRules.troveCost(Grade.rare))),
          const SizedBox(height: Gaps.m),
          if (gift == WelcomeGift.waitingForEssence)
            Text(context.l10n.welcomeGiftWaiting, style: context.texts.bodySmall)
          else if (troveBlock(state, Grade.rare, progress.now, gift: true) == null)
            ClayButton(
              key: const ValueKey('redeem-welcome-gift'),
              label: context.l10n.welcomeGiftRedeem(EconomyRules.welcomeTrovePrice),
              icon: Icons.redeem_rounded,
              onPressed: () => _open(context, progress, Grade.rare, gift: true),
            )
          else
            Text(
              context.l10n.troveNeedXp(EconomyRules.welcomeTrovePrice - state.balance),
              style: context.texts.bodySmall,
            ),
        ],
      ),
    ),
  );
}

Future<void> _open(BuildContext context, ProgressController progress, Grade grade, {bool gift = false}) async {
  final finds = await progress.openTrove(grade, gift: gift);
  if (finds == null) return;
  await Get.to<void>(() => TroveOpeningPage(grade: grade, finds: finds));
}
