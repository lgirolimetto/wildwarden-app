import 'package:druid_app/l10n/app_localizations.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:flutter/material.dart';

/// Scorciatoie per leggere tema, token e testi localizzati dentro i widget.
extension ThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get texts => Theme.of(this).textTheme;

  DruidTokens get druid => Theme.of(this).extension<DruidTokens>()!;

  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Lingua da usare per i contenuti del catalogo.
  String get contentLanguage => Localizations.localeOf(this).languageCode;
}
