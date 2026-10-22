import 'dart:math';

import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Copertina di una specie non ancora incontrata, al posto della foto: la tinta pastello più caratteristica della
/// foto (fiore, bacca…), una trama leggera di foglia e un tassello di plastilina col "?". Il colore è un indizio
/// ("ha qualcosa di viola"), la specie resta da scoprire.
///
/// Non scarica né sfoca immagini: costa quanto un riquadro colorato, anche in una lista lunga.
class MysteryCover extends StatelessWidget {
  final Species species;
  final BorderRadius borderRadius;

  const MysteryCover({super.key, required this.species, this.borderRadius = BorderRadius.zero});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Di sera la tinta si abbassa verso il colore della pagina, senza perdere la sua tonalità.
    final base = dark ? Color.lerp(_tint(species), context.colors.surface, 0.2)! : _tint(species);
    return ClipRRect(
      borderRadius: borderRadius,
      // Colore pieno, senza sfumature: deve risaltare.
      child: ColoredBox(
        color: base,
        child: CustomPaint(
          painter: _LeafPainter(color: Color.lerp(base, Colors.black, 0.12)!.withValues(alpha: 0.35)),
          child: const Center(child: _QuestionTile()),
        ),
      ),
    );
  }
}

/// Tinta della specie; se il catalogo non ce l'ha, un pastello stabile ricavato dal nome.
Color _tint(Species species) {
  final rgb = species.mysteryColor;
  if (rgb != null) return Color(0xFF000000 | rgb);
  final hue = (species.sci.codeUnits.fold(0, (a, b) => a * 31 + b) % 360).toDouble();
  return HSLColor.fromAHSL(1, hue, 0.5, 0.8).toColor();
}

/// Marrone caldo del tassello, uguale di giorno e di sera: sta su tinte pastello, non sul colore della pagina.
const _brown = Color(0xFF94592C);

/// Tassello di plastilina marrone caldo con il "?".
class _QuestionTile extends StatelessWidget {
  const _QuestionTile();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = (min(constraints.maxWidth, constraints.maxHeight) * 0.3).clamp(40.0, 72.0);
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: clayDecoration(context, color: _brown, radius: size * 0.3),
        child: Text(
          '?',
          style: context.texts.headlineMedium?.copyWith(
            color: const Color(0xFFF5EBDD),
            fontSize: size * 0.55,
            height: 1,
          ),
        ),
      );
    },
  );
}

/// Una grande foglia appena accennata (contorno e nervature): dà materia al riquadro senza disegnare la specie.
class _LeafPainter extends CustomPainter {
  final Color color;

  const _LeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !size.isFinite) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final length = size.longestSide * 0.95;
    canvas.save();
    canvas.translate(size.width * 0.08, size.height * 0.92);
    canvas.rotate(-0.75);
    final half = length * 0.26;
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(length * 0.35, -half, length, 0)
        ..quadraticBezierTo(length * 0.35, half, 0, 0),
      paint,
    );
    canvas.drawLine(Offset.zero, Offset(length, 0), paint);
    for (var i = 1; i <= 6; i++) {
      final x = length * i / 8;
      final spread = half * (1 - (x / length - 0.35).abs()) * 0.8;
      canvas.drawLine(Offset(x, 0), Offset(x + length * 0.09, -spread), paint);
      canvas.drawLine(Offset(x, 0), Offset(x + length * 0.09, spread), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LeafPainter old) => old.color != color;
}
