import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Colori di una scheda decorativa (sfondo e testo sopra).
@immutable
class AccentCard {
  final Color background;
  final Color foreground;

  const AccentCard(this.background, this.foreground);

  static AccentCard lerp(AccentCard a, AccentCard b, double t) =>
      AccentCard(Color.lerp(a.background, b.background, t)!, Color.lerp(a.foreground, b.foreground, t)!);
}

/// Token di gioco che Material non prevede: colori dei livelli di studio, sfumature e texture di sfondo, schede colorate, raggi. Si leggono con `context.druid`.
@immutable
class DruidTokens extends ThemeExtension<DruidTokens> {
  /// Un colore per ogni livello di studio, da 0 (trovata) a 4 (maestria).
  final List<Color> levelColors;

  /// Colore del testo degli indizi.
  final Color hint;

  /// Colore degli avvisi di sicurezza (tossicità).
  final Color warning;

  /// Sfumatura dello sfondo delle pagine principali, dall'alto in basso.
  final List<Color> backgroundGradient;

  /// Texture dello sfondo: opacità della grana (0 = nessuna) e colore delle nervature di foglia
  /// (trasparente = nessuna).
  final double grainOpacity;
  final Color leafPattern;

  /// Sfumatura delle schede "eroe" (titolo e PE) e colore del testo sopra.
  final List<Color> heroGradient;
  final Color onHero;

  /// Schede decorative a colori diversi (curiosità, ripassi, ricette…), usate a rotazione.
  final List<AccentCard> accentCards;
  final double cardRadius;

  /// Stile "plastilina" (claymorphism): schede, pulsanti e icone con volume, riflesso e ombra morbida.
  /// Se falso la livrea resta piatta (Material).
  final bool clay;

  /// Colore delle ombre morbide dello stile plastilina.
  final Color clayShadow;

  const DruidTokens({
    required this.levelColors,
    required this.hint,
    required this.warning,
    required this.backgroundGradient,
    required this.heroGradient,
    required this.onHero,
    required this.accentCards,
    required this.cardRadius,
    this.grainOpacity = 0,
    this.leafPattern = Colors.transparent,
    this.clay = false,
    this.clayShadow = const Color(0x33000000),
  }) : assert(levelColors.length == 5, 'Servono 5 colori: livelli 0-4'),
       assert(accentCards.length >= 3, 'Servono almeno 3 schede decorative');

  Color levelColor(int level) => levelColors[level.clamp(0, levelColors.length - 1)];

  AccentCard accent(int index) => accentCards[index % accentCards.length];

  @override
  DruidTokens copyWith({
    List<Color>? levelColors,
    Color? hint,
    Color? warning,
    List<Color>? backgroundGradient,
    List<Color>? heroGradient,
    Color? onHero,
    List<AccentCard>? accentCards,
    double? cardRadius,
    double? grainOpacity,
    Color? leafPattern,
    bool? clay,
    Color? clayShadow,
  }) => DruidTokens(
    levelColors: levelColors ?? this.levelColors,
    hint: hint ?? this.hint,
    warning: warning ?? this.warning,
    backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    heroGradient: heroGradient ?? this.heroGradient,
    onHero: onHero ?? this.onHero,
    accentCards: accentCards ?? this.accentCards,
    cardRadius: cardRadius ?? this.cardRadius,
    grainOpacity: grainOpacity ?? this.grainOpacity,
    leafPattern: leafPattern ?? this.leafPattern,
    clay: clay ?? this.clay,
    clayShadow: clayShadow ?? this.clayShadow,
  );

  @override
  DruidTokens lerp(covariant DruidTokens? other, double t) {
    if (other == null) return this;
    List<Color> lerpList(List<Color> a, List<Color> b) => [
      for (var i = 0; i < a.length; i++) Color.lerp(a[i], b[i], t)!,
    ];
    final cards = accentCards.length == other.accentCards.length
        ? [for (var i = 0; i < accentCards.length; i++) AccentCard.lerp(accentCards[i], other.accentCards[i], t)]
        : (t < 0.5 ? accentCards : other.accentCards);
    return DruidTokens(
      levelColors: lerpList(levelColors, other.levelColors),
      hint: Color.lerp(hint, other.hint, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      backgroundGradient: lerpList(backgroundGradient, other.backgroundGradient),
      heroGradient: lerpList(heroGradient, other.heroGradient),
      onHero: Color.lerp(onHero, other.onHero, t)!,
      accentCards: cards,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      grainOpacity: lerpDouble(grainOpacity, other.grainOpacity, t)!,
      leafPattern: Color.lerp(leafPattern, other.leafPattern, t)!,
      clay: t < 0.5 ? clay : other.clay,
      clayShadow: Color.lerp(clayShadow, other.clayShadow, t)!,
    );
  }
}

/// Spaziature comuni: non dipendono dalla livrea.
abstract final class Gaps {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;
}
