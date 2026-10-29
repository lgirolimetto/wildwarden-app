import 'package:druid_app/user_interface/common_widgets/pill.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';

/// L'icona della Vis: una foglia con la sua energia.
const visIcon = Symbols.energy_savings_leaf_rounded;

/// Le Vis che chiede un ingrediente: la foglia della Vis in una chip, il numero nel badge (capitolo 02, 2026-10-29).
/// Niente "1 ×" né conti da fare: la stessa unità della Dispensa e della conferma.
class VisBadge extends StatelessWidget {
  final int vis;

  const VisBadge(this.vis, {super.key});

  @override
  Widget build(BuildContext context) =>
      IconBadgeChip(icon: visIcon, badge: '$vis', message: context.l10n.pantryVis(vis));
}
