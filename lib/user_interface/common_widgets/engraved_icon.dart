import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Icona "incisa", come stampata a secco: un filo d'ombra in alto a sinistra e uno di luce in basso a destra sotto il
/// segno, che così sembra scavato nella superficie. È lo stile delle icone nelle livree neumorfiche (capitolo 07: i
/// tratti in Feltro, poi tutte le icone): un solo colore, niente sfere colorate né emoji.
class EngravedIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  /// Colore del segno; `null` = quello del testo (bianco su un fondo scuro).
  final Color? color;

  /// Fondo su cui sta l'icona, se diverso dalla pagina. Su un fondo scuro (es. la scheda verde del rango) il segno è
  /// chiaro e luce e ombra si ricavano dal fondo, con il gioco invertito: le ombre della livrea sono pensate per la
  /// pagina chiara e lì sembrerebbero luci (capitolo 07).
  final Color? surface;

  const EngravedIcon(this.icon, {super.key, this.size = 20, this.color, this.surface});

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    final dark = surface != null && ThemeData.estimateBrightnessForColor(surface!) == Brightness.dark;
    return Icon(
      icon,
      size: size,
      color: (color ?? (dark ? Colors.white : context.colors.onSurface)).withValues(alpha: dark ? 0.9 : 0.7),
      shadows: dark
          ? [
              Shadow(color: Color.lerp(surface, Colors.white, 0.25)!, offset: const Offset(-0.8, -0.8)),
              Shadow(color: Color.lerp(surface, Colors.black, 0.45)!, offset: const Offset(0.9, 0.9)),
            ]
          : [
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
  '🌕' => Icons.circle,
  '🌑' => Icons.circle_outlined,
  '🌅' => Icons.wb_twilight_rounded,
  '🌄' => Icons.brightness_6_outlined,
  '🌌' => Icons.auto_awesome_outlined,
  '⛈' || '⛈️' => Icons.thunderstorm_outlined,
  _ => null,
};
