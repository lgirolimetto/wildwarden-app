import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/rules/field/station_state.dart';
import 'package:druid_app/business_logic/rules/field/suspension.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Il nome della pianta di una Stazione: quello del catalogo, o quello di Pl@ntNet per Ospiti e Scoperte.
String stationName(BuildContext context, Station station, Catalog catalog) =>
    switch (catalog.speciesBySci(station.speciesSci)) {
      final species? => context.game.name(species),
      null => station.commonName ?? station.speciesSci,
    };

/// "alle 17:30" oggi, "gio alle 05:12" un altro giorno.
String whenText(BuildContext context, DateTime when, DateTime now) {
  final time = DateFormat.Hm(context.contentLanguage).format(when);
  final sameDay = when.year == now.year && when.month == now.month && when.day == now.day;
  return sameDay
      ? context.l10n.whenToday(time)
      : context.l10n.whenOtherDay(DateFormat.E(context.contentLanguage).format(when), time);
}

String suspensionReason(BuildContext context, SevereWeather reason) => switch (reason) {
  SevereWeather.storm => context.l10n.suspendedStorm,
  SevereWeather.hail => context.l10n.suspendedHail,
  SevereWeather.wind => context.l10n.suspendedWind,
  SevereWeather.snow => context.l10n.suspendedSnow,
};

/// Lo stato di una Stazione in una riga: pronta, esaurita o in rigenerazione (con quando torna pronta), sospesa (con
/// quando riprende). La sospensione vince: anche una Stazione pronta non si Attinge.
String stationStatusText(
  BuildContext context, {
  required StationStatus status,
  required DateTime? readyAt,
  required Suspension? suspension,
  required DateTime now,
}) {
  if (suspension != null) {
    return context.l10n.stationSuspended(
      suspensionReason(context, suspension.reason),
      whenText(context, suspension.until, now),
    );
  }
  return switch (status) {
    StationStatus.ready => context.l10n.stationReady,
    StationStatus.exhausted => context.l10n.stationExhausted(whenText(context, readyAt!, now)),
    StationStatus.regrowing => context.l10n.stationRegrowing(whenText(context, readyAt!, now)),
  };
}
