import 'package:druid_app/l10n/app_localizations.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:flutter/material.dart';

/// Una livrea è l'identità visiva dell'app: palette Material, token di gioco e font.
///
/// Per aggiungerne una:
/// 1. crea una sottoclasse in `liveries/` (copia `erbario_livery.dart` come base);
/// 2. aggiungila a `LiveryRegistry.all`;
/// 3. aggiungi il suo nome in `lib/l10n/app_*.arb` e in [displayName].
/// I test in `test/user_interface/theme/` verificano in automatico che ogni livrea registrata produca
/// un tema valido, chiaro e scuro.
abstract class Livery {
  const Livery();

  /// Identificatore stabile, salvato nelle preferenze dell'utente.
  String get id;

  String displayName(AppLocalizations l10n);

  /// Colore da cui Material 3 deriva l'intera palette.
  Color get seed;

  /// Font del testo; `null` = font di sistema.
  String? get fontFamily => null;

  /// Font di titoli e intestazioni; `null` = lo stesso del testo.
  String? get displayFontFamily => null;

  /// Palette Material. Di default è derivata da [seed]; una livrea può ritoccarla (es. superfici "carta").
  ColorScheme colorScheme(Brightness brightness) => ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

  DruidTokens tokens(Brightness brightness, ColorScheme scheme);
}
