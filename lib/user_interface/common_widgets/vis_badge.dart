import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// L'icona della Vis: una foglia con la sua energia.
const visIcon = Symbols.energy_savings_leaf_rounded;

/// Le Vis che chiede un ingrediente, in un badge come quello delle notifiche: niente "1 ×" né conti da fare (capitolo
/// 02, 2026-10-29). La stessa unità della Dispensa e della conferma.
class VisBadge extends StatelessWidget {
  final int vis;

  const VisBadge(this.vis, {super.key});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: context.l10n.pantryVis(vis),
    child: Container(
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: context.colors.primary, borderRadius: BorderRadius.circular(999)),
      child: Text(
        '$vis',
        textAlign: TextAlign.center,
        style: context.texts.labelMedium?.copyWith(color: context.colors.onPrimary, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
