import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// L'icona "pronta" di una Tavola preparabile adesso, e della riga della pianta (o delle Mitiche) che ne ha almeno una
/// (capitolo 02, 2026-10-29: al posto della linguetta Ricette pronte).
class ReadyMark extends StatelessWidget {
  final double size;

  const ReadyMark({super.key, this.size = 20});

  static const icon = Symbols.check_circle_rounded;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: context.l10n.recipeReady,
    child: Icon(icon, fill: 1, size: size, color: context.colors.primary, semanticLabel: context.l10n.recipeReady),
  );
}
