import 'dart:math';

import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Altezza dei bollini di una riga (il timbro dell'incontro).
const badgeHeight = 26.0;

/// Scudo delle specie protette: un tondo bianco con il contorno dello scudo nel colore principale, in stile normale
/// (non neumorfico) perché sta sopra le foto e sul vetro dell'etichetta, dove un incavo non si leggerebbe; il bianco
/// e l'ombra lo staccano da qualunque foto. Il significato è nel suggerimento a pressione lunga e nel testo per i
/// lettori di schermo; la legenda lo spiega.
class ProtectedShield extends StatelessWidget {
  final double size;

  const ProtectedShield({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.badgeProtected;
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: context.colors.shadow.withValues(alpha: 0.35), blurRadius: 4, offset: const Offset(0, 1)),
            ],
          ),
          child: Icon(Icons.shield_outlined, size: size * 0.6, color: context.colors.primary),
        ),
      ),
    );
  }
}

/// Timbro dell'incontro: la spunta e la data, scritte come "Studia" sulla tessera, senza incavo (scavato vorrebbe dire
/// "scelto", regola del rilievo). Il colore è uno di quelli dello studio: tra i livelli 1–3 quello che si legge meglio
/// sulla tessera (di giorno il più scuro, di sera il più chiaro), perché il testo è piccolo.
class StampBadge extends StatelessWidget {
  final String text;
  final String label;

  const StampBadge({super.key, required this.text, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _readableStudyColor(context);
    return Tooltip(
      message: label,
      child: Semantics(
        label: '$label $text',
        excludeSemantics: true,
        child: SizedBox(
          height: badgeHeight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_outlined, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                text,
                style: context.texts.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Il colore di studio (livelli 1–3) con più contrasto sul fondo delle tessere delle specie incontrate.
Color _readableStudyColor(BuildContext context) {
  final background = context.druid.neu ? context.colors.surfaceContainerLowest : context.colors.surface;
  double contrast(Color c) {
    final a = c.computeLuminance(), b = background.computeLuminance();
    return (max(a, b) + 0.05) / (min(a, b) + 0.05);
  }

  return [
    for (var level = 1; level <= 3; level++) context.druid.levelColor(level),
  ].reduce((best, c) => contrast(c) > contrast(best) ? c : best);
}
