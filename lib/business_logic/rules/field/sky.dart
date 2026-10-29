import 'dart:math';

import 'package:druid_app/business_logic/models/enums/trait.dart';

/// Astronomia per i tratti della luce e della luna, calcolata sul telefono (capitolo 02, "I tratti delle essenze"):
/// serve al mirino della fotocamera nel blocco 2 e all'attingere nel blocco 3. Precisione di qualche minuto, più che
/// sufficiente per finestre di un'ora.

/// Alba: dalle prime luci (sole 6° sotto l'orizzonte, crepuscolo civile) a circa un'ora dopo il sorgere del sole.
const dawnAfterSunrise = Duration(hours: 1);

/// Tramonto: da circa un'ora prima del tramonto fino al tramonto, mai a buio fatto.
const duskBeforeSunset = Duration(hours: 1);

/// Mese sinodico in giorni e una luna nuova di riferimento (6 gennaio 2000, 18:14 UTC).
const synodicMonth = 29.530588853;
final _referenceNewMoon = DateTime.utc(2000, 1, 6, 18, 14);

/// Alba, sorgere e tramonto del sole in un giorno (UTC). Null dove il sole non sorge o non tramonta (vicino ai poli).
class SunTimes {
  final DateTime firstLight;
  final DateTime sunrise;
  final DateTime sunset;

  const SunTimes({required this.firstLight, required this.sunrise, required this.sunset});
}

/// Algoritmo della NOAA: [day] è il giorno di calendario (vale solo la data), [latitude] e [longitude] in gradi
/// (est positiva).
SunTimes? sunTimes(DateTime day, double latitude, double longitude) {
  final sunrise = _sunEvent(day, latitude, longitude, -0.833, rising: true);
  final sunset = _sunEvent(day, latitude, longitude, -0.833, rising: false);
  final firstLight = _sunEvent(day, latitude, longitude, -6, rising: true);
  if (sunrise == null || sunset == null || firstLight == null) return null;
  return SunTimes(firstLight: firstLight, sunrise: sunrise, sunset: sunset);
}

DateTime? _sunEvent(DateTime day, double latitude, double longitude, double altitude, {required bool rising}) {
  double rad(double deg) => deg * pi / 180;
  double deg(double rad) => rad * 180 / pi;

  final noon = DateTime.utc(day.year, day.month, day.day, 12);
  // Giorni giuliani dal 2000-01-01 12:00 UTC, corretti per la longitudine.
  final n = noon.difference(DateTime.utc(2000, 1, 1, 12)).inDays - longitude / 360;
  final meanAnomaly = (357.5291 + 0.98560028 * n) % 360;
  final center = 1.9148 * sin(rad(meanAnomaly)) + 0.02 * sin(rad(2 * meanAnomaly)) + 0.0003 * sin(rad(3 * meanAnomaly));
  final eclipticLongitude = (meanAnomaly + center + 180 + 102.9372) % 360;
  final transit = n + 0.0053 * sin(rad(meanAnomaly)) - 0.0069 * sin(rad(2 * eclipticLongitude));
  final declination = asin(sin(rad(eclipticLongitude)) * sin(rad(23.4397)));
  final cosHourAngle =
      (sin(rad(altitude)) - sin(rad(latitude)) * sin(declination)) / (cos(rad(latitude)) * cos(declination));
  if (cosHourAngle.abs() > 1) return null;
  final hourAngle = deg(acos(cosHourAngle));
  final event = transit + (rising ? -hourAngle : hourAngle) / 360;
  return DateTime.utc(2000, 1, 1, 12).add(Duration(milliseconds: (event * Duration.millisecondsPerDay).round()));
}

/// Il tratto della luce in quel momento: Alba, Tramonto o nessuno.
Trait? daylightTrait(DateTime now, double latitude, double longitude) {
  final utc = now.toUtc();
  final sun = sunTimes(now, latitude, longitude);
  if (sun == null) return null;
  if (!utc.isBefore(sun.firstLight) && utc.isBefore(sun.sunrise.add(dawnAfterSunrise))) return Trait.dawn;
  if (!utc.isBefore(sun.sunset.subtract(duskBeforeSunset)) && utc.isBefore(sun.sunset)) return Trait.dusk;
  return null;
}

/// Età della luna in giorni (0 = luna nuova, circa 14,8 = piena).
double moonAge(DateTime when) {
  final days = when.toUtc().difference(_referenceNewMoon).inMinutes / Duration.minutesPerDay;
  return days % synodicMonth;
}

/// Frazione illuminata del disco (0–1).
double moonIllumination(DateTime when) => (1 - cos(2 * pi * moonAge(when) / synodicMonth)) / 2;

/// Il tratto della luna per tutto il giorno (si guarda il mezzogiorno): piena oltre il 95 % di illuminazione, nuova
/// sotto il 5 %, altrimenti crescente o calante (capitolo 02).
Trait moonTrait(DateTime day) {
  final noon = DateTime(day.year, day.month, day.day, 12);
  final illumination = moonIllumination(noon);
  if (illumination > 0.95) return Trait.moon;
  if (illumination < 0.05) return Trait.newMoon;
  return moonAge(noon) < synodicMonth / 2 ? Trait.waxingMoon : Trait.waningMoon;
}

/// I tratti del cielo in un momento e in un posto: la luce (se c'è) e la luna.
List<Trait> skyTraits(DateTime now, double latitude, double longitude) => [
  ?daylightTrait(now, latitude, longitude),
  moonTrait(now),
];
