import 'dart:math' as math;

import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/rules/recipes/affixes.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Forma del recipiente: una per base della ricetta, più quella delle Mitiche.
enum VesselShape {
  cup, // Infuso: tazza
  pot, // Decotto: pentolino
  bottle, // Sciroppo: bottiglietta
  jar, // Unguento: vasetto basso
  dropper, // Tintura: boccetta con contagocce
  lidded, // Balsamo: barattolo col tappo
  vial, // Elisir: fiala
  still, // Distillato: alambicco
  flask, // Filtro: ampolla tonda
  starred; // Mitica: ampolla con le stelle

  static VesselShape of(RecipeBase base) => switch (base) {
    RecipeBase.infusion => cup,
    RecipeBase.decoction => pot,
    RecipeBase.syrup => bottle,
    RecipeBase.ointment => jar,
    RecipeBase.tincture => dropper,
    RecipeBase.balm => lidded,
    RecipeBase.elixir => vial,
    RecipeBase.distillate => still,
    RecipeBase.philtre => flask,
  };
}

/// Icona dell'effetto, accanto al recipiente: un segno solo, inciso come le icone dei tratti.
IconData effectIconOf(PotionEffect effect) => switch (effect) {
  PotionEffect.regrowth => Icons.spa_outlined,
  PotionEffect.clarity => Icons.visibility_outlined,
  PotionEffect.omen => Icons.auto_awesome_outlined,
  PotionEffect.abundance => Icons.grass_rounded,
};

/// Il recipiente di una ricetta (decisione del 2026-10-27): la forma dice la base (Infuso, Balsamo…), il colore del
/// liquido i tratti, uno strato per tratto. Senza [liquids] resta il solo contorno: una Tavola che manca.
///
/// Disegnato con il codice, nello stile delle icone incise (filo d'ombra in alto a sinistra, di luce in basso a
/// destra) e senza sfocature: le schede con il recipiente si ripetono nelle griglie.
class PotionVessel extends StatelessWidget {
  final VesselShape shape;

  /// Colori del liquido dal fondo in su; vuota = recipiente vuoto.
  final List<Color> liquids;
  final double size;

  /// Per i lettori di schermo (es. "Infuso · Alba, Sole").
  final String? semanticLabel;

  const PotionVessel({super.key, required this.shape, this.liquids = const [], this.size = 64, this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    final empty = liquids.isEmpty;
    return Semantics(
      label: semanticLabel,
      image: true,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(size),
          painter: _VesselPainter(
            shape: shape,
            liquids: liquids,
            line: (empty ? tokens.hint : context.colors.onSurface).withValues(alpha: empty ? 0.6 : 0.7),
            shadow: tokens.clayShadow,
            light: tokens.neu ? tokens.neuLight : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

/// Le parti di un recipiente in un quadrato di lato 1: [body] contiene il liquido, [outline] è il profilo del vetro
/// (corpo e collo uniti), [extras] i pezzi a parte (manico, tappo, piattino, tubo, stelle).
class _Parts {
  final Path body;
  final Path outline;
  final List<Path> extras;

  /// Dove arriva il liquido, da 0 (in alto) a 1 (in basso).
  final double level;

  _Parts(this.body, {Path? neck, this.extras = const [], this.level = 0.5})
    : outline = neck == null ? body : Path.combine(PathOperation.union, body, neck);
}

Path _rrect(double l, double t, double r, double b, double radius) =>
    Path()..addRRect(RRect.fromLTRBR(l, t, r, b, Radius.circular(radius)));

Path _roundBottom(double l, double t, double r, double b, double radius) => Path()
  ..addRRect(
    RRect.fromLTRBAndCorners(
      l,
      t,
      r,
      b,
      topLeft: const Radius.circular(0.02),
      topRight: const Radius.circular(0.02),
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    ),
  );

Path _circle(double x, double y, double r) => Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: r));

/// Stella a quattro punte, piccola, attorno alle Mitiche.
Path _sparkle(double x, double y, double r) {
  final p = Path()..moveTo(x, y - r);
  for (var i = 1; i <= 8; i++) {
    final a = -math.pi / 2 + i * math.pi / 4;
    final d = i.isOdd ? r * 0.3 : r;
    p.lineTo(x + d * math.cos(a), y + d * math.sin(a));
  }
  return p..close();
}

_Parts _partsOf(VesselShape shape) => switch (shape) {
  VesselShape.cup => _Parts(
    _roundBottom(0.16, 0.4, 0.7, 0.8, 0.2),
    extras: [
      Path()..addArc(const Rect.fromLTRB(0.6, 0.46, 0.86, 0.7), -math.pi / 2, math.pi),
      Path()
        ..moveTo(0.08, 0.86)
        ..lineTo(0.78, 0.86),
      Path()
        ..moveTo(0.36, 0.32)
        ..quadraticBezierTo(0.3, 0.25, 0.36, 0.18),
      Path()
        ..moveTo(0.5, 0.32)
        ..quadraticBezierTo(0.44, 0.25, 0.5, 0.16),
    ],
    level: 0.5,
  ),
  VesselShape.pot => _Parts(
    _roundBottom(0.14, 0.42, 0.68, 0.84, 0.12),
    extras: [
      Path()
        ..moveTo(0.1, 0.42)
        ..lineTo(0.72, 0.42),
      Path()
        ..moveTo(0.68, 0.48)
        ..lineTo(0.94, 0.4),
    ],
    level: 0.54,
  ),
  VesselShape.bottle => _Parts(
    _rrect(0.3, 0.42, 0.7, 0.88, 0.1),
    neck: Path()
      ..moveTo(0.42, 0.22)
      ..lineTo(0.58, 0.22)
      ..lineTo(0.58, 0.34)
      ..quadraticBezierTo(0.7, 0.36, 0.7, 0.46)
      ..lineTo(0.3, 0.46)
      ..quadraticBezierTo(0.3, 0.36, 0.42, 0.34)
      ..close(),
    extras: [_rrect(0.4, 0.12, 0.6, 0.22, 0.03)],
    level: 0.5,
  ),
  VesselShape.jar => _Parts(
    _rrect(0.18, 0.54, 0.82, 0.86, 0.1),
    extras: [_rrect(0.14, 0.44, 0.86, 0.54, 0.04)],
    level: 0.62,
  ),
  VesselShape.dropper => _Parts(
    _rrect(0.3, 0.52, 0.7, 0.88, 0.1),
    neck: _rrect(0.42, 0.44, 0.58, 0.56, 0.02),
    extras: [_rrect(0.38, 0.34, 0.62, 0.44, 0.03), Path()..addOval(const Rect.fromLTRB(0.42, 0.12, 0.58, 0.34))],
    level: 0.6,
  ),
  VesselShape.lidded => _Parts(
    _rrect(0.24, 0.4, 0.76, 0.88, 0.12),
    extras: [
      Path()
        ..moveTo(0.2, 0.4)
        ..quadraticBezierTo(0.5, 0.24, 0.8, 0.4)
        ..close(),
      _circle(0.5, 0.25, 0.05),
    ],
    level: 0.5,
  ),
  VesselShape.vial => _Parts(
    _roundBottom(0.4, 0.22, 0.6, 0.88, 0.1),
    extras: [_rrect(0.36, 0.16, 0.64, 0.22, 0.02)],
    level: 0.45,
  ),
  VesselShape.still => _Parts(
    _circle(0.36, 0.66, 0.22),
    neck: _rrect(0.31, 0.26, 0.41, 0.48, 0.02),
    extras: [
      Path()
        ..moveTo(0.41, 0.3)
        ..quadraticBezierTo(0.7, 0.24, 0.86, 0.6),
      _circle(0.86, 0.72, 0.06),
    ],
    level: 0.42,
  ),
  VesselShape.flask => _Parts(
    _circle(0.5, 0.62, 0.26),
    neck: _rrect(0.43, 0.2, 0.57, 0.4, 0.02),
    extras: [_rrect(0.39, 0.14, 0.61, 0.2, 0.02)],
    level: 0.42,
  ),
  VesselShape.starred => _Parts(
    _circle(0.5, 0.64, 0.24),
    neck: _rrect(0.44, 0.24, 0.56, 0.44, 0.02),
    extras: [
      _rrect(0.4, 0.16, 0.6, 0.24, 0.03),
      _sparkle(0.18, 0.3, 0.08),
      _sparkle(0.84, 0.24, 0.06),
      _sparkle(0.86, 0.5, 0.05),
    ],
    level: 0.42,
  ),
};

class _VesselPainter extends CustomPainter {
  final VesselShape shape;
  final List<Color> liquids;
  final Color line;
  final Color shadow;
  final Color light;

  _VesselPainter({
    required this.shape,
    required this.liquids,
    required this.line,
    required this.shadow,
    required this.light,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final parts = _partsOf(shape);
    final s = size.shortestSide;
    canvas.scale(s);
    // Il segno resta largo 1,6 punti a ogni misura.
    final stroke = 1.6 / s;

    if (liquids.isNotEmpty) {
      final bounds = parts.body.getBounds();
      final top = bounds.top + parts.level * bounds.height;
      final band = (bounds.bottom - top) / liquids.length;
      canvas.save();
      canvas.clipPath(parts.body);
      for (var i = 0; i < liquids.length; i++) {
        // Dal fondo in su: il primo tratto sta sotto.
        final bottom = bounds.bottom - i * band;
        canvas.drawRect(Rect.fromLTRB(bounds.left, bottom - band, bounds.right, bottom), Paint()..color = liquids[i]);
      }
      // Il pelo del liquido, un filo più chiaro.
      canvas.drawLine(
        Offset(bounds.left, top),
        Offset(bounds.right, top),
        Paint()
          ..color = Color.lerp(liquids.last, Colors.white, 0.5)!
          ..strokeWidth = stroke,
      );
      // Il riflesso sul vetro, a sinistra.
      canvas.drawLine(
        Offset(bounds.left + bounds.width * 0.2, top + band * 0.2),
        Offset(bounds.left + bounds.width * 0.2, bounds.bottom - bounds.height * 0.18),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.45)
          ..strokeWidth = stroke * 1.4
          ..strokeCap = StrokeCap.round,
      );
      canvas.restore();
    }

    final paths = [parts.outline, ...parts.extras];
    void strokeAll(Color color, Offset offset) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      for (final p in paths) {
        canvas.drawPath(p.shift(offset), paint);
      }
    }

    // Inciso: ombra in alto a sinistra, luce in basso a destra, poi il segno.
    final px = 0.8 / s;
    strokeAll(shadow, Offset(-px, -px));
    strokeAll(light, Offset(px, px));
    strokeAll(line, Offset.zero);
  }

  @override
  bool shouldRepaint(_VesselPainter old) =>
      old.shape != shape ||
      old.line != line ||
      old.shadow != shadow ||
      old.light != light ||
      !_sameColors(old.liquids, liquids);

  static bool _sameColors(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
