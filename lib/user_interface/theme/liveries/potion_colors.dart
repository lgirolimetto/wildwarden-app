import 'package:flutter/material.dart';

/// Colori del liquido nei recipienti delle ricette, uno per tratto nell'ordine di `Trait` (alba, tramonto, luna
/// crescente, piena, calante, nuova, sole, pioggia, nebbia, rugiada, gelo): il tratto colora la pozione, il grado
/// resta al cerchietto (decisione del 2026-10-27). Di sera sono un po' più profondi, come i colori dei gradi.
List<Color> potionTraitColors(Brightness brightness) => brightness == Brightness.light
    ? const [
        Color(0xFFEFA3A0), // alba: rosa
        Color(0xFFE07B39), // tramonto: arancio
        Color(0xFFB9B3DA), // luna crescente: lilla
        Color(0xFFC6CCDA), // luna piena: argento
        Color(0xFF9790C4), // luna calante: lavanda
        Color(0xFF3F3B66), // luna nuova: indaco
        Color(0xFFE8B92E), // sole: oro
        Color(0xFF4A7FB5), // pioggia: blu
        Color(0xFFBDB9AE), // nebbia: perla
        Color(0xFF6FBFA8), // rugiada: verde acqua
        Color(0xFF9FD3EC), // gelo: ghiaccio
      ]
    : const [
        Color(0xFFD98B88),
        Color(0xFFC86A2E),
        Color(0xFF9F98C8),
        Color(0xFFAEB4C4),
        Color(0xFF8079B3),
        Color(0xFF55508A),
        Color(0xFFCFA225),
        Color(0xFF3F6F9F),
        Color(0xFFA29E94),
        Color(0xFF5AA892),
        Color(0xFF86BBD6),
      ];

/// Liquido delle ricette senza tratti (le Comuni): un verde d'erba, neutro.
Color plainPotionColor(Brightness brightness) =>
    brightness == Brightness.light ? const Color(0xFFAFBF72) : const Color(0xFF8E9C58);

/// Colore dei nomi delle specie (in maiuscoletto, come nei cartellini d'erbario): un verde scuro di giorno, chiaro di
/// sera.
Color speciesNameColor(Brightness brightness) =>
    brightness == Brightness.light ? const Color(0xFF3E6B47) : const Color(0xFFA9CFA1);
