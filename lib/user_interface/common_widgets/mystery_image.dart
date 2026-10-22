import 'dart:ui' show ImageFilter;

import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Foto di una specie non ancora trovata: a colori ma sfocata, si intuiscono tinte e forme.
/// Il "?" sta su un piccolo bollo smerigliato: resta il senso della scoperta senza spegnere la foto.
/// Saturazione +25% e un filo di luce in più.
const _vivid = ColorFilter.matrix(<double>[
  1.197, -0.179, -0.018, 0, 6, //
  -0.053, 1.071, -0.018, 0, 6, //
  -0.053, -0.179, 1.232, 0, 6, //
  0, 0, 0, 1, 0, //
]);

class MysteryImage extends StatelessWidget {
  final String url;

  /// Angoli del riquadro. La sfocatura non rispetta i ritagli arrotondati dei contenitori (sborda dagli angoli),
  /// quindi se il riquadro è arrotondato va ritagliata qui.
  final BorderRadius borderRadius;

  const MysteryImage(this.url, {super.key, this.borderRadius = BorderRadius.zero});

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Sfocatura con i bordi "a specchio" (non pesca il trasparente fuori dalla foto, che la ingrigirebbe) e colori
        // un po' più saturi e luminosi: la specie resta misteriosa ma la foto è viva, quasi un acquerello.
        ClipRRect(
          borderRadius: borderRadius,
          child: ColorFiltered(
            colorFilter: _vivid,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: tokens.mysteryBlur,
                sigmaY: tokens.mysteryBlur,
                tileMode: TileMode.mirror,
              ),
              child: RemoteImage(url),
            ),
          ),
        ),
        if (tokens.mysteryVeil.a > 0) ColoredBox(color: tokens.mysteryVeil),
        Center(
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                ),
                child: Text(
                  '?',
                  style: context.texts.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
