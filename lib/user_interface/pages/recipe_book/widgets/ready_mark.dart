import 'package:druid_app/business_logic/rules/recipes/brewing.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// L'icona "pronta" di una Tavola preparabile adesso, e della riga della pianta (o delle Mitiche) che ne ha almeno una
/// (capitolo 02, 2026-10-29: al posto della linguetta Ricette pronte). È la beuta del Laboratorio nella barra in basso,
/// nel colore delle azioni: la Tavola è pronta per il Laboratorio.
class ReadyMark extends StatelessWidget {
  final double size;

  const ReadyMark({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: context.l10n.recipeReady,
    child: Icon(
      Icons.science_rounded,
      size: size,
      color: context.colors.primary,
      semanticLabel: context.l10n.recipeReady,
    ),
  );
}

/// La beuta con quante pozioni prepari: "×3" su una Tavola ([times]), "2+" sulla riga di una pianta ([more]: ordinando
/// bene se ne fanno di più). Capitolo 02, 2026-10-29.
class ReadyCount extends StatelessWidget {
  final int count;
  final bool more;
  final bool times;
  final double size;

  const ReadyCount({super.key, required this.count, this.more = false, this.times = false, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = times ? l10n.recipeTimes(count) : '$count${more || count >= brewCountCap ? '+' : ''}';
    return Tooltip(
      message: more ? l10n.recipePotionsLeast(count) : l10n.recipePotionsExact(count),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.science_rounded, size: size, color: context.colors.primary),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(fontSize: size * 0.85, fontWeight: FontWeight.w700, color: context.colors.primary),
          ),
        ],
      ),
    );
  }
}
