import 'dart:ui' show lerpDouble;

import 'package:druid_app/business_logic/models/enums/trait.dart';
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

  /// Variante neumorfica dello stile plastilina: superfici dello stesso colore della pagina, sollevate solo da una
  /// luce in alto a sinistra ([neuLight]) e da un'ombra in basso a destra ([clayShadow]). Richiede [clay].
  final bool neu;
  final Color neuLight;

  /// Colori dei gradi: comune, non comune, rara, mitica (vedi `liveries/grade_colors.dart`).
  final List<Color> gradeColors;

  /// Colori del liquido delle pozioni, uno per tratto nell'ordine di `Trait` (vedi `liveries/potion_colors.dart`).
  final List<Color> traitColors;

  /// Liquido delle pozioni senza tratti (le Comuni); `null` = quello degli indizi.
  final Color? plainPotion;

  /// Colore dei nomi delle specie; `null` = quello del testo.
  final Color? speciesName;

  /// L'oro della purezza (la barretta nella Dispensa); `null` = quello del Sole tra le Qualia.
  final Color? purity;

  /// Pagine dense (ricette, impostazioni, glossario…): sfondo e superfici più chiari, per dare contrasto dove la
  /// livrea è molto scura. `null` = come le altre pagine. Vedi `DenseArea`.
  final Color? denseBackground;
  final Color? denseSurface;

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
    this.neu = false,
    this.neuLight = Colors.transparent,
    this.gradeColors = const [],
    this.traitColors = const [],
    this.plainPotion,
    this.speciesName,
    this.purity,
    this.denseBackground,
    this.denseSurface,
  }) : assert(levelColors.length == 5, 'Servono 5 colori: livelli 0-4'),
       assert(accentCards.length >= 3, 'Servono almeno 3 schede decorative');

  /// L'oro della purezza.
  Color get purityColor => purity ?? traitColor(Trait.sun.index);

  Color levelColor(int level) => levelColors[level.clamp(0, levelColors.length - 1)];

  AccentCard accent(int index) => accentCards[index % accentCards.length];

  /// Colore del grado [index] (0 = comune … 3 = mitica); se la livrea non li ha, quelli dei livelli di studio.
  Color gradeColor(int index) => gradeColors.length == 4 ? gradeColors[index] : levelColor(index + 1);

  /// Colore del liquido per il tratto [index]; se la livrea non li ha, quello degli indizi.
  Color traitColor(int index) => index < traitColors.length ? traitColors[index] : hint;

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
    bool? neu,
    Color? neuLight,
    List<Color>? gradeColors,
    List<Color>? traitColors,
    Color? plainPotion,
    Color? speciesName,
    Color? purity,
    Color? denseBackground,
    Color? denseSurface,
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
    neu: neu ?? this.neu,
    neuLight: neuLight ?? this.neuLight,
    gradeColors: gradeColors ?? this.gradeColors,
    traitColors: traitColors ?? this.traitColors,
    plainPotion: plainPotion ?? this.plainPotion,
    speciesName: speciesName ?? this.speciesName,
    purity: purity ?? this.purity,
    denseBackground: denseBackground ?? this.denseBackground,
    denseSurface: denseSurface ?? this.denseSurface,
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
      neu: t < 0.5 ? neu : other.neu,
      neuLight: Color.lerp(neuLight, other.neuLight, t)!,
      gradeColors: gradeColors.length == other.gradeColors.length
          ? lerpList(gradeColors, other.gradeColors)
          : (t < 0.5 ? gradeColors : other.gradeColors),
      traitColors: traitColors.length == other.traitColors.length
          ? lerpList(traitColors, other.traitColors)
          : (t < 0.5 ? traitColors : other.traitColors),
      plainPotion: Color.lerp(plainPotion, other.plainPotion, t),
      speciesName: Color.lerp(speciesName, other.speciesName, t),
      purity: Color.lerp(purity, other.purity, t),
      denseBackground: Color.lerp(denseBackground, other.denseBackground, t),
      denseSurface: Color.lerp(denseSurface, other.denseSurface, t),
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

  /// Distanza tra le chip in fila e tra le righe di chip: abbastanza perché le ombre del rilievo non si sovrappongano.
  static const chip = 12.0;
  static const chipRun = 18.0;
}
