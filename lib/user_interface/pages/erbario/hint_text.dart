import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';
import 'package:druid_app/l10n/app_localizations.dart';

/// Compone l'indizio nella lingua dell'utente: "Una pianta della famiglia X, che si fa notare
/// soprattutto in inverno, in collina."
String hintText(AppLocalizations l10n, SpeciesHint hint) {
  final parts = [
    l10n.hintFamily(hint.family),
    if (hint.season != null) _season(l10n, hint.season!),
    if (hint.band != null) _band(l10n, hint.band!),
  ];
  return '${parts.join(', ')}.';
}

String _season(AppLocalizations l10n, Season season) => switch (season) {
  Season.winter => l10n.hintSeasonWinter,
  Season.spring => l10n.hintSeasonSpring,
  Season.summer => l10n.hintSeasonSummer,
  Season.autumn => l10n.hintSeasonAutumn,
};

String _band(AppLocalizations l10n, AltitudeBand band) => switch (band) {
  AltitudeBand.plain => l10n.hintBandPlain,
  AltitudeBand.hill => l10n.hintBandHill,
  AltitudeBand.mountain => l10n.hintBandMountain,
};
