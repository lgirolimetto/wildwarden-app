import 'package:flutter/material.dart';

/// Colori dei gradi (comune, non comune, rara, mitica): il riferimento è bianco, argento, oro, oro rosso (capitolo
/// 02). Di sera sono un po' più profondi, perché non abbaglino sulle superfici scure. Ogni livrea può declinarli
/// nella sua palette; per ora tutte usano questi.
List<Color> metalGradeColors(Brightness brightness) => brightness == Brightness.light
    ? const [Color(0xFFF3EEE3), Color(0xFFB8C0C6), Color(0xFFD9A93A), Color(0xFFC4613A)]
    : const [Color(0xFFD8D2C4), Color(0xFF9AA3AA), Color(0xFFC8982C), Color(0xFFB0532F)];
