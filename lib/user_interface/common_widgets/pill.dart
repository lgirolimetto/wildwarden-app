import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Etichetta a pillola (livello di una ricetta, tratto di un ingrediente). Prende il colore del testo del contesto,
/// quindi si legge sia sulle pagine sia dentro le schede colorate. Se il testo comincia con un'emoji (i tratti) e la
/// livrea è in plastilina, l'emoji diventa una piccola sfera pastello.
class Pill extends StatelessWidget {
  final String text;

  const Pill(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colors.onSurface;
    final emoji = context.druid.clay ? leadingEmoji(text) : null;
    if (emoji != null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(Gaps.xs, Gaps.xs, Gaps.m, Gaps.xs),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClayCircle(color: _orbColor(emoji), emoji: emoji, size: 28),
            const SizedBox(width: Gaps.s),
            Text(text.substring(emoji.length).trim(), style: context.texts.labelLarge?.copyWith(color: color)),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gaps.m, vertical: Gaps.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(text, style: context.texts.labelLarge?.copyWith(color: color)),
    );
  }
}

/// Colore pastello della sfera di un tratto, dall'emoji: fresco per gelo e acqua, caldo per sole e tramonto.
Color _orbColor(String emoji) => switch (emoji) {
  '❄️' || '❄' => const Color(0xFFCFE6F5),
  '🌧' || '💧' => const Color(0xFFB9DCEB),
  '🌫' => const Color(0xFFDCDDE3),
  '☀️' || '☀' => const Color(0xFFFFE3A0),
  '🌕' => const Color(0xFFE6DDF7),
  '🌅' => const Color(0xFFF7C4A8),
  _ => const Color(0xFFE8DCC6),
};
