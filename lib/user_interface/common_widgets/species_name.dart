import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Il nome di una specie come nei cartellini d'erbario: in maiuscoletto (IM FELL English SC: le minuscole sono già
/// maiuscolette) e nel verde della livrea, diverso dal resto del testo (decisione del 2026-10-27).
TextStyle speciesNameStyle(BuildContext context, TextStyle? base) => (base ?? const TextStyle()).copyWith(
  fontFamily: 'FellSC',
  color: context.druid.speciesName ?? base?.color,
  letterSpacing: 0.4,
  // Il Fell è più piccolo a parità di corpo: un filo più grande, per stare in riga con il testo intorno.
  fontSize: (base?.fontSize ?? 14) * 1.08,
);

/// Un testo in cui il nome della pianta [plant] (se c'è) prende lo stile delle specie: per i nomi delle ricette
/// ("Infuso di BORRAGINE COMUNE dell'Abbondanza").
class TextWithSpecies extends StatelessWidget {
  final String text;
  final String? plant;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;

  const TextWithSpecies(this.text, {super.key, required this.plant, this.style, this.maxLines, this.textAlign});

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final at = plant == null || plant!.isEmpty ? -1 : text.indexOf(plant!);
    return Text.rich(
      at < 0
          ? TextSpan(text: text)
          : TextSpan(
              children: [
                TextSpan(text: text.substring(0, at)),
                TextSpan(text: plant, style: speciesNameStyle(context, base)),
                TextSpan(text: text.substring(at + plant!.length)),
              ],
            ),
      style: base,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}
