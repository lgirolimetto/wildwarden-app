import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Bollino: un piccolo incavo rotondo con un'icona (es. lo scudo delle specie protette), come il cerchietto del grado.
/// Il significato è nel [label]: suggerimento a pressione lunga e testo per i lettori di schermo; la legenda lo spiega.
class InsetBadge extends StatelessWidget {
  static const size = 26.0;

  final IconData icon;
  final String label;

  /// Colore dell'icona; `null` = quello del testo.
  final Color? color;

  const InsetBadge({super.key, required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Semantics(
      label: label,
      child: SizedBox.square(
        dimension: size,
        child: NeuInset(
          radius: BorderRadius.circular(size / 2),
          depth: 2,
          child: Center(child: Icon(icon, size: 15, color: color ?? context.colors.onSurface)),
        ),
      ),
    ),
  );
}

/// Timbro dell'incontro: un incavo a pillola con la spunta e la data, come un timbro sul quaderno.
class StampBadge extends StatelessWidget {
  final String text;
  final String label;

  const StampBadge({super.key, required this.text, required this.label});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Semantics(
      label: '$label $text',
      excludeSemantics: true,
      child: NeuInset(
        radius: BorderRadius.circular(InsetBadge.size / 2),
        depth: 2,
        child: SizedBox(
          height: InsetBadge.size,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_outlined, size: 14, color: context.colors.primary),
                const SizedBox(width: 4),
                Text(text, style: context.texts.labelMedium?.copyWith(color: context.colors.primary)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
