import 'dart:math';

import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:flutter/material.dart';

/// Momento del giorno, dall'ora locale.
enum DayTime {
  dawn,
  day,
  dusk,
  night;

  static DayTime of(DateTime t) => switch (t.hour) {
    >= 5 && < 8 => DayTime.dawn,
    >= 8 && < 18 => DayTime.day,
    >= 18 && < 21 => DayTime.dusk,
    _ => DayTime.night,
  };
}

/// Piccolo paesaggio "in plastilina" su un'isola fluttuante, in testa alla pagina Studio.
/// Cambia con la stagione e il momento del giorno; in futuro anche con meteo e luna (gli stessi tratti delle essenze).
/// È disegnato in codice: illustrazioni vere potranno sostituirlo nello stesso spazio.
class Diorama extends StatelessWidget {
  final DateTime moment;

  /// Colore in cui il cielo sfuma in basso (lo sfondo della pagina), così il diorama non ha bordi.
  final Color fadeTo;

  const Diorama({super.key, required this.moment, required this.fadeTo});

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _DioramaPainter(season: Season.ofMonth(moment.month), time: DayTime.of(moment), fadeTo: fadeTo),
      child: const SizedBox.expand(),
    ),
  );
}

class _Palette {
  final List<Color> sky;
  final List<Color> hills;
  final Color grass;
  final Color grassDark;
  final List<Color> flowers;
  final bool snow;

  const _Palette({
    required this.sky,
    required this.hills,
    required this.grass,
    required this.grassDark,
    required this.flowers,
    this.snow = false,
  });
}

_Palette _paletteFor(Season season, DayTime time) {
  final base = switch (season) {
    Season.spring => const _Palette(
      sky: [Color(0xFFBFE3D8), Color(0xFFF3E9D6)],
      hills: [Color(0xFF9CC8A0), Color(0xFF6FAE7E), Color(0xFF4E8F68)],
      grass: Color(0xFF6DB46A),
      grassDark: Color(0xFF3F7F4C),
      flowers: [Color(0xFFF2A7B8), Color(0xFFFFE08A), Color(0xFFB9A7F2), Color(0xFFFFFFFF)],
    ),
    Season.summer => const _Palette(
      sky: [Color(0xFFA9D8E8), Color(0xFFF6E7C9)],
      hills: [Color(0xFFB9C978), Color(0xFF8EAF5A), Color(0xFF5F8E4A)],
      grass: Color(0xFFC9B24A),
      grassDark: Color(0xFF7C8A35),
      flowers: [Color(0xFFF28A5B), Color(0xFFFFD25C), Color(0xFFE85D75)],
    ),
    Season.autumn => const _Palette(
      sky: [Color(0xFFF2C9A0), Color(0xFFF4E3D0)],
      hills: [Color(0xFFD9A066), Color(0xFFB9743F), Color(0xFF7E5A3A)],
      grass: Color(0xFFC88A3E),
      grassDark: Color(0xFF8A5A2B),
      flowers: [Color(0xFFE5C26B), Color(0xFFD9653B), Color(0xFFB04A5A)],
    ),
    Season.winter => const _Palette(
      sky: [Color(0xFFC9D8E6), Color(0xFFEDEFF2)],
      hills: [Color(0xFFDDE6EE), Color(0xFFB9C9D6), Color(0xFF8FA6B8)],
      grass: Color(0xFF8DA79A),
      grassDark: Color(0xFF5C786C),
      flowers: [Color(0xFFFFFFFF), Color(0xFFE6F0FA)],
      snow: true,
    ),
  };
  final sky = switch (time) {
    DayTime.dawn => [const Color(0xFFF6C6B4), base.sky.last],
    DayTime.day => base.sky,
    DayTime.dusk => [const Color(0xFFE79A86), const Color(0xFFF2C9A0)],
    DayTime.night => [const Color(0xFF1E2B45), const Color(0xFF3A4766)],
  };
  final dim = time == DayTime.night ? 0.45 : 0.0;
  Color shade(Color c) => Color.lerp(c, const Color(0xFF16213A), dim)!;
  return _Palette(
    sky: sky,
    hills: base.hills.map(shade).toList(),
    grass: shade(base.grass),
    grassDark: shade(base.grassDark),
    flowers: base.flowers.map(shade).toList(),
    snow: base.snow,
  );
}

class _DioramaPainter extends CustomPainter {
  final Season season;
  final DayTime time;
  final Color fadeTo;

  const _DioramaPainter({required this.season, required this.time, required this.fadeTo});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !size.isFinite) return;
    final p = _paletteFor(season, time);
    final w = size.width, h = size.height;
    final random = Random(season.index * 10 + time.index);

    // Cielo che sfuma nello sfondo della pagina.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.sky.first, p.sky.last, fadeTo],
          stops: const [0, 0.55, 1],
        ).createShader(Offset.zero & size),
    );

    // Stelle di notte.
    if (time == DayTime.night) {
      final star = Paint()..color = Colors.white.withValues(alpha: 0.8);
      for (var i = 0; i < 40; i++) {
        canvas.drawCircle(
          Offset(random.nextDouble() * w, random.nextDouble() * h * 0.45),
          random.nextDouble() * 1.4 + 0.4,
          star,
        );
      }
    }

    // Sole o luna, con alone.
    final isNight = time == DayTime.night;
    final orbCenter = Offset(w * 0.78, h * (time == DayTime.day ? 0.22 : 0.34));
    final orbRadius = w * 0.07;
    final orbColor = isNight
        ? const Color(0xFFF4F1E1)
        : (time == DayTime.day ? const Color(0xFFFFE6A3) : const Color(0xFFFFC08A));
    canvas.drawCircle(orbCenter, orbRadius * 2.6, Paint()..color = orbColor.withValues(alpha: 0.22));
    _clayCircle(canvas, orbCenter, orbRadius, orbColor);

    // Nuvola in plastilina.
    if (!isNight || random.nextBool()) {
      _cloud(canvas, Offset(w * 0.42, h * 0.3), w * 0.05, isNight ? const Color(0xFF55617E) : Colors.white);
    }

    // Colline sullo sfondo.
    for (var i = 0; i < 3; i++) {
      final top = h * (0.42 + i * 0.07);
      final path = Path()..moveTo(0, h);
      path.lineTo(0, top + 20);
      for (var x = 0.0; x <= w; x += w / 6) {
        path.quadraticBezierTo(
          x + w / 12,
          top - 18 + random.nextDouble() * 24,
          x + w / 6,
          top + random.nextDouble() * 18,
        );
      }
      path
        ..lineTo(w, h)
        ..close();
      final color = p.hills[i];
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.lerp(color, Colors.white, 0.18)!, color, Color.lerp(color, fadeTo, 0.85)!],
            stops: const [0, 0.35, 1],
          ).createShader(Rect.fromLTWH(0, top - 20, w, h - top + 20)),
      );
      if (p.snow) {
        canvas.drawPath(
          path,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withValues(alpha: 0.85), Colors.white.withValues(alpha: 0)],
              stops: const [0, 0.12],
            ).createShader(Rect.fromLTWH(0, top - 20, w, h * 0.3)),
        );
      }
    }

    // Isola fluttuante: ombra, fianco di terra, piano d'erba.
    final island = Rect.fromCenter(center: Offset(w * 0.5, h * 0.78), width: w * 0.78, height: h * 0.16);
    canvas.drawOval(
      island.shift(Offset(0, island.height * 0.9)).inflate(-island.width * 0.06),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    final side = RRect.fromRectAndCorners(
      Rect.fromLTWH(island.left, island.center.dy, island.width, island.height * 0.9),
      bottomLeft: Radius.circular(island.width * 0.3),
      bottomRight: Radius.circular(island.width * 0.3),
    );
    canvas.drawRRect(
      side,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8A5E3E), Color(0xFF5E3D27)],
        ).createShader(side.outerRect),
    );
    canvas.drawOval(
      island,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.6),
          radius: 1.1,
          colors: [Color.lerp(p.grass, Colors.white, 0.25)!, p.grass, p.grassDark],
          stops: const [0, 0.55, 1],
        ).createShader(island),
    );
    if (p.snow) {
      canvas.drawOval(island.deflate(island.height * 0.12), Paint()..color = Colors.white.withValues(alpha: 0.55));
    }

    // Un alberello in plastilina a sinistra.
    final trunkBase = Offset(island.left + island.width * 0.22, island.center.dy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: trunkBase.translate(0, -h * 0.06), width: w * 0.022, height: h * 0.13),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF6B4430),
    );
    final canopy = season == Season.winter ? const Color(0xFF9AB0A4) : p.hills[1];
    for (final o in const [Offset(0, -0.17), Offset(-0.035, -0.13), Offset(0.035, -0.13)]) {
      _clayCircle(canvas, trunkBase.translate(o.dx * w, o.dy * h), w * 0.055, canopy);
    }

    // Ciuffi d'erba e fiori sull'isola.
    final blade = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2;
    for (var i = 0; i < 46; i++) {
      final x = island.left + island.width * (0.36 + random.nextDouble() * 0.56);
      final y = island.center.dy - island.height * 0.15 + random.nextDouble() * island.height * 0.35;
      final height = h * (0.04 + random.nextDouble() * 0.06);
      final bend = (random.nextDouble() - 0.5) * 14;
      blade.color = Color.lerp(p.grassDark, p.grass, random.nextDouble())!;
      canvas.drawPath(
        Path()
          ..moveTo(x, y)
          ..quadraticBezierTo(x + bend, y - height * 0.6, x + bend * 1.6, y - height),
        blade,
      );
      if (i % 4 == 0 && p.flowers.isNotEmpty) {
        _clayCircle(
          canvas,
          Offset(x + bend * 1.6, y - height),
          3.6 + random.nextDouble() * 2.4,
          p.flowers[i % p.flowers.length],
        );
      }
    }

    // Foglie che cadono d'autunno, fiocchi d'inverno.
    if (season == Season.autumn || season == Season.winter) {
      for (var i = 0; i < 14; i++) {
        final c = Offset(random.nextDouble() * w, h * (0.15 + random.nextDouble() * 0.5));
        if (season == Season.winter) {
          canvas.drawCircle(c, 1.8 + random.nextDouble() * 1.6, Paint()..color = Colors.white.withValues(alpha: 0.9));
        } else {
          canvas.save();
          canvas.translate(c.dx, c.dy);
          canvas.rotate(random.nextDouble() * pi);
          canvas.drawOval(const Rect.fromLTWH(-5, -2.5, 10, 5), Paint()..color = p.flowers[i % p.flowers.length]);
          canvas.restore();
        }
      }
    }
    _fadeBottom(canvas, size);
  }

  /// Sfumatura finale verso lo sfondo della pagina: il diorama non ha un bordo inferiore.
  void _fadeBottom(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.38);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fadeTo.withValues(alpha: 0), fadeTo.withValues(alpha: 0.7), fadeTo],
          stops: const [0, 0.6, 1],
        ).createShader(rect),
    );
  }

  void _clayCircle(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center.translate(0, radius * 0.25),
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.3),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          colors: [Color.lerp(color, Colors.white, 0.45)!, color, Color.lerp(color, Colors.black, 0.15)!],
          stops: const [0, 0.6, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _cloud(Canvas canvas, Offset center, double unit, Color color) {
    for (final (dx, dy, r) in const [(-1.6, 0.3, 1.0), (0.0, -0.2, 1.4), (1.5, 0.3, 1.05), (0.4, 0.5, 1.0)]) {
      _clayCircle(canvas, center.translate(dx * unit, dy * unit), r * unit, color);
    }
  }

  @override
  bool shouldRepaint(_DioramaPainter old) => old.season != season || old.time != time || old.fadeTo != fadeTo;
}
