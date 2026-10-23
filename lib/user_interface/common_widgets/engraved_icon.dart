import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Icona "incisa", come stampata a secco: un filo d'ombra in alto a sinistra e uno di luce in basso a destra sotto il
/// segno, che così sembra scavato nella superficie. È lo stile delle icone nelle livree neumorfiche (capitolo 07: i
/// tratti in Feltro, poi tutte le icone): un solo colore, niente sfere colorate né emoji.
class EngravedIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  /// Colore del segno; `null` = quello del testo.
  final Color? color;

  const EngravedIcon(this.icon, {super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    return Icon(
      icon,
      size: size,
      color: (color ?? context.colors.onSurface).withValues(alpha: 0.7),
      shadows: [
        Shadow(color: tokens.clayShadow, offset: const Offset(-0.8, -0.8)),
        Shadow(color: tokens.neuLight, offset: const Offset(0.9, 0.9)),
      ],
    );
  }
}

/// Icona monocromatica di un tratto, dall'emoji con cui catalogo e testi lo scrivono ("❄️ Gelo"…); `null` se l'emoji
/// non è di un tratto.
IconData? traitIconOf(String emoji) => switch (emoji) {
  '❄️' || '❄' => Icons.ac_unit_rounded,
  '🌧' => Icons.umbrella_rounded,
  '💧' => Icons.water_drop_outlined,
  '🌫' => Icons.foggy,
  '☀️' || '☀' => Icons.wb_sunny_outlined,
  '🌕' => Icons.nightlight_outlined,
  '🌅' => Icons.wb_twilight_rounded,
  _ => null,
};
