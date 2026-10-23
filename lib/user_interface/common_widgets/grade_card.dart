import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Scheda di un oggetto con un grado (comune, non comune, rara, mitica): ricette oggi, poi figurine, pozioni e
/// Bottino. Le schede sono tutte uguali, del colore della livrea; il grado lo dice un solco sottile inciso poco dentro
/// il bordo, che prende la luce del colore del grado (come il solco attorno alla foto della scheda specie in Feltro).
class GradeCard extends StatelessWidget {
  /// Larghezza del solco e distanza dal bordo.
  static const grooveWidth = 2.0;
  static const grooveInset = 8.0;

  final Grade grade;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GradeCard({super.key, required this.grade, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      // Il contenuto sta dentro il solco: al margine si aggiunge il rientro.
      ClayCard(padding: padding.add(const EdgeInsets.all(grooveInset)), child: child),
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            painter: _GroovePainter(
              color: context.druid.gradeColor(grade.index),
              surface: context.colors.surfaceContainerLow,
              radius: context.druid.cardRadius,
              dark: Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        ),
      ),
    ],
  );
}

/// Solco inciso parallelo al bordo della scheda. Con la luce dall'alto a sinistra (come nel resto del rilievo): il
/// fondo del solco è molto più scuro della scheda, lo spigolo in alto a sinistra è in ombra, quello in basso a destra
/// prende la luce, ed è lì che sta il colore del grado. Di giorno anche fondo e ombra sono gradazioni del colore del
/// grado: un grigio neutro accanto all'oro rosso staccherebbe.
class _GroovePainter extends CustomPainter {
  final Color color;
  final Color surface;
  final double radius;

  /// Di sera il solco è più profondo; di giorno, sulle superfici chiare, più tenue.
  final bool dark;

  const _GroovePainter({required this.color, required this.surface, required this.radius, required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    const inset = GradeCard.grooveInset;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, size.width - 2 * inset, size.height - 2 * inset),
      Radius.circular(radius - inset),
    );
    Paint stroke(Color c, double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = c;
    canvas
      // Fondo del solco: di sera quasi nero; di giorno il colore del grado più profondo, con la sua saturazione
      // (mescolarlo con il nero o con la scheda lo spegne in un grigio).
      ..drawRRect(
        rect,
        stroke(dark ? Color.lerp(surface, Colors.black, 0.6)! : _deeper(color, 0.78), GradeCard.grooveWidth),
      )
      // Spigolo in ombra.
      ..drawRRect(
        rect.shift(const Offset(-0.9, -0.9)),
        stroke(dark ? Colors.black.withValues(alpha: 0.6) : _deeper(color, 0.55), 1),
      )
      // Spigolo in luce, del colore del grado.
      ..drawRRect(rect.shift(const Offset(1.1, 1.1)), stroke(color, 1.2));
  }

  /// Lo stesso colore con la luminosità ridotta a [factor], tinta e saturazione intatte.
  static Color _deeper(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * factor).clamp(0, 1)).toColor();
  }

  @override
  bool shouldRepaint(_GroovePainter old) =>
      old.color != color || old.surface != surface || old.radius != radius || old.dark != dark;
}
