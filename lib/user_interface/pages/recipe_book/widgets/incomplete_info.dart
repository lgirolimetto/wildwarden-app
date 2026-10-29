import 'package:druid_app/user_interface/common_widgets/engraved_icon.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// La ⓘ di una Tavola incompleta: apre la spiegazione dei "?" e di dove si trovano i Componenti (capitolo 02,
/// 2026-10-29).
class IncompleteInfoButton extends StatelessWidget {
  final double size;

  const IncompleteInfoButton({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: context.l10n.incompleteInfoTooltip,
    child: InkResponse(
      key: const ValueKey('incomplete-info'),
      radius: size,
      onTap: () => showIncompleteInfo(context),
      child: Icon(Icons.info_outline_rounded, size: size, color: context.druid.hint),
    ),
  );
}

/// La spiegazione, a sezioni brevi con un'icona ciascuna.
Future<void> showIncompleteInfo(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (context) {
    final l10n = context.l10n;
    final sections = [
      (Icons.help_outline_rounded, l10n.incompleteWhatTitle, l10n.incompleteWhatText),
      (Icons.block_rounded, l10n.incompleteBrewTitle, l10n.incompleteBrewText),
      (Icons.travel_explore_rounded, l10n.incompleteWhereTitle, l10n.incompleteWhereText),
    ];
    return SafeArea(
      child: ListView(
        key: const ValueKey('incomplete-info-sheet'),
        shrinkWrap: true,
        padding: const EdgeInsets.all(Gaps.l),
        children: [
          Text(l10n.incompleteInfoTitle, style: context.texts.titleLarge),
          for (final (icon, title, text) in sections) ...[
            const SizedBox(height: Gaps.m),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EngravedIcon(icon, size: 22),
                const SizedBox(width: Gaps.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.texts.titleSmall),
                      const SizedBox(height: Gaps.xs),
                      Text(text, style: context.texts.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  },
);
