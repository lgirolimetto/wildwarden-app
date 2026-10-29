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
    Widget frame(EdgeInsets padding, Widget child, BoxDecoration flat) => pillFrame(context, padding, child, flat);
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

/// Il bordo delle pillole, condiviso con le chip di sola lettura ([IconBadgeChip]). Nelle livree neumorfiche la
/// pillola non si preme, quindi non è scavata: un solco sottile tutt'intorno e, subito dentro, la pillola che risale in
/// rilievo (come la foto della scheda specie). Valori scelti (effetto minimale): solco depth 0.8 / strength 0.45,
/// rilievo depth 0.8 / strength 0.35. Variante appena più accennata, provata e da tenere come alternativa: solco
/// depth 1 / strength 0.6, rilievo depth 1 / strength 0.5. Altrimenti [flat].
Widget pillFrame(BuildContext context, EdgeInsets padding, Widget child, BoxDecoration flat) {
  const radius = BorderRadius.all(Radius.circular(999));
  return context.druid.neu
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
}

/// Chip di sola lettura con un'icona incisa e un numero nel badge tondo, come le notifiche (capitolo 02, 2026-10-29):
/// la beuta con le pozioni che prepari ("2", "2+"), la foglia della Vis con le Vis che chiede un ingrediente ("10").
class IconBadgeChip extends StatelessWidget {
  final IconData icon;
  final String badge;

  /// Tooltip e lettore di schermo ("Prepari almeno 2 pozioni", "10 Vis").
  final String message;

  const IconBadgeChip({super.key, required this.icon, required this.badge, required this.message});

  @override
  Widget build(BuildContext context) {
    final color = context.colors.onSurface;
    final chip = pillFrame(
      context,
      const EdgeInsets.symmetric(horizontal: Gaps.m, vertical: Gaps.xs),
      EngravedIcon(icon, size: 20, color: color),
      BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
    );
    return Tooltip(
      message: message,
      child: Semantics(
        label: message,
        excludeSemantics: true,
        child: Padding(
          // Spazio per il badge, che sporge in alto a destra.
          padding: const EdgeInsets.only(top: 6, right: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              chip,
              Positioned(
                top: -6,
                right: -8,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: context.colors.primary, borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    badge,
                    style: context.texts.labelSmall?.copyWith(
                      color: context.colors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
