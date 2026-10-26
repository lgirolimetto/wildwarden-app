import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/engraved_icon.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Etichetta a pillola (livello di una ricetta, tratto di un ingrediente). Prende il colore del testo del contesto,
/// quindi si legge sia sulle pagine sia dentro le schede colorate. Se il testo comincia con un'emoji (i tratti) e la
/// livrea è in plastilina, l'emoji diventa una piccola sfera pastello; nelle livree neumorfiche un'icona incisa.
class Pill extends StatelessWidget {
  final String text;

  const Pill(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colors.onSurface;
    final emoji = context.druid.clay ? leadingEmoji(text) : null;
    const radius = BorderRadius.all(Radius.circular(999));
    // Nelle livree neumorfiche la pillola non si preme, quindi non è scavata: un solco sottile tutt'intorno e,
    // subito dentro, la pillola che risale in rilievo (come la foto della scheda specie).
    // Valori scelti (effetto minimale): solco depth 0.8 / strength 0.45, rilievo depth 0.8 / strength 0.35.
    // Variante appena più accennata, provata e da tenere come alternativa: solco depth 1 / strength 0.6,
    // rilievo depth 1 / strength 0.5.
    Widget frame(EdgeInsets padding, Widget child, BoxDecoration flat) => context.druid.neu
        ? NeuInset(
            radius: radius,
            depth: 0.8,
            strength: 0.45,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: NeuInset(
                radius: radius,
                depth: 0.8,
                strength: 0.35,
                convex: true,
                child: Padding(padding: padding, child: child),
              ),
            ),
          )
        : Container(padding: padding, decoration: flat, child: child);
    if (emoji != null) {
      return frame(
        // Nell'incavo l'icona si stacca dal bordo sinistro, che è in ombra.
        EdgeInsets.fromLTRB(
          context.druid.neu ? Gaps.m : Gaps.xs,
          Gaps.xs + (context.druid.neu ? 2 : 0),
          Gaps.m,
          Gaps.xs + (context.druid.neu ? 2 : 0),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nelle livree neumorfiche niente sfera colorata: l'icona del tratto, di un solo colore, incisa.
            if (context.druid.neu)
              EngravedIcon(traitIconOf(emoji) ?? Icons.eco_outlined, color: color, mirrored: traitIconMirrored(emoji))
            else
              ClayCircle(color: _orbColor(emoji), emoji: emoji, size: 28),
            const SizedBox(width: Gaps.s),
            Text(text.substring(emoji.length).trim(), style: context.texts.labelLarge?.copyWith(color: color)),
          ],
        ),
        BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: radius),
      );
    }
    return frame(
      const EdgeInsets.symmetric(horizontal: Gaps.m, vertical: Gaps.xs + 2),
      Text(text, style: context.texts.labelLarge?.copyWith(color: color)),
      BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: radius,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
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
  '🌅' || '🌄' => const Color(0xFFF7C4A8),
  '🌑' => const Color(0xFFD5D3E8),
  '🌓' || '🌗' => const Color(0xFFDDD8F0),
  _ => const Color(0xFFE8DCC6),
};
