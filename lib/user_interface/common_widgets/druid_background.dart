import 'dart:math';

import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Sfondo della livrea: sfumatura, più (se la livrea li prevede) grana e nervature di foglia.
/// Ogni pagina lo dipinge sotto di sé (non è trasparente sull'intera app), così durante le transizioni non si
/// vede la pagina precedente in trasparenza.
class DruidBackground extends StatelessWidget {
  final Widget child;

  /// Per le pagine con `extendBodyBehindAppBar`: lo sfondo passa sotto la barra, il contenuto parte sotto di essa.
  final bool belowAppBar;

  const DruidBackground({super.key, required this.child, this.belowAppBar = false});

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    final content = belowAppBar ? SafeArea(bottom: false, child: child) : child;
    final textured = tokens.grainOpacity > 0 || tokens.leafPattern.a > 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: tokens.backgroundGradient,
        ),
      ),
      child: textured
          ? Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _TexturePainter(
                          grain: Color.fromRGBO(0, 0, 0, tokens.grainOpacity),
                          leaf: tokens.leafPattern,
                        ),
                      ),
                    ),
                  ),
                ),
                content,
              ],
            )
          : content,
    );
  }
}

/// Grana leggera e due grandi foglie con le nervature, solo a contorno: si notano appena, danno materia.
/// Il disegno è deterministico (seme fisso) e si ridisegna solo se cambiano dimensioni o colori.
class _TexturePainter extends CustomPainter {
  final Color grain;
  final Color leaf;

  const _TexturePainter({required this.grain, required this.leaf});

  @override
  void paint(Canvas canvas, Size size) {
    // Durante transizioni e misure intermedie le dimensioni possono essere vuote o infinite: niente da disegnare.
    if (size.isEmpty || !size.isFinite) return;
    if (grain.a > 0) {
      final random = Random(7);
      final dark = Paint()..color = grain;
      final light = Paint()..color = Color.fromRGBO(255, 255, 255, grain.a);
      final count = (size.width * size.height / 90).round();
      for (var i = 0; i < count; i++) {
        canvas.drawRect(
          Rect.fromLTWH(random.nextDouble() * size.width, random.nextDouble() * size.height, 1.2, 1.2),
          i.isEven ? dark : light,
        );
      }
    }
    if (leaf.a > 0) {
      _leaf(canvas, Offset(size.width * 1.02, size.height * 0.08), size.width * 0.9, 2.5);
      _leaf(canvas, Offset(-size.width * 0.05, size.height * 0.98), size.width * 0.75, -0.7);
    }
  }

  void _leaf(Canvas canvas, Offset base, double length, double angle) {
    final paint = Paint()
      ..color = leaf
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);
    final half = length * 0.28;
    final outline = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(length * 0.35, -half, length, 0)
      ..quadraticBezierTo(length * 0.35, half, 0, 0);
    canvas.drawPath(outline, paint);
    canvas.drawLine(Offset.zero, Offset(length, 0), paint);
    for (var i = 1; i <= 7; i++) {
      final x = length * i / 9;
      final spread = half * (1 - (x / length - 0.35).abs()) * 0.8;
      canvas.drawLine(Offset(x, 0), Offset(x + length * 0.08, -spread), paint);
      canvas.drawLine(Offset(x, 0), Offset(x + length * 0.08, spread), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TexturePainter old) => old.grain != grain || old.leaf != leaf;
}
