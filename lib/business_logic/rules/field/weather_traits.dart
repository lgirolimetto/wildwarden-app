import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/weather_now.dart';
import 'package:druid_app/business_logic/rules/field/sky.dart';

/// I tratti del meteo dal tempo di adesso (capitolo 02, "I tratti delle essenze", e i testi di quando vale ogni
/// tratto). Le soglie sono le 🟡 proposte del capitolo, da tarare con il blocco 3; il mirino le usa già.

/// Solare: di giorno, nuvole fino a questa copertura e niente pioggia.
const sunMaxCloud = 30.0;

/// Nebbia: codici WMO 45/48 o visibilità sotto questi metri.
const fogMaxVisibility = 1000.0;

/// Rugiada: notte con temperatura entro 2 °C dal punto di rugiada, poche nuvole e poco vento; vale dalle prime luci a
/// circa 2 ore dopo il sorgere del sole, sopra zero (sotto è Gelo).
const dewSpread = 2.0;
const dewMaxCloud = 40.0;
const dewMaxWind = 10.0;
const dewAfterSunrise = Duration(hours: 2);

/// Temporale (codici WMO 95–99): niente tratto Pioggia, la raccolta è sospesa (blocco 3).
bool isStorm(WeatherNow w) => w.weatherCode >= 95;

bool _rainCode(int code) => (code >= 51 && code <= 67) || (code >= 80 && code <= 82);

List<Trait> weatherTraits(WeatherNow w, double latitude, double longitude) {
  final fog = w.weatherCode == 45 || w.weatherCode == 48 || (w.visibility != null && w.visibility! < fogMaxVisibility);
  final rain = !isStorm(w) && (w.precipitation > 0 || _rainCode(w.weatherCode));
  return [
    if (w.isDay && w.cloudCover <= sunMaxCloud && !rain && !fog) Trait.sun,
    if (rain) Trait.rain,
    if (fog) Trait.fog,
    if (_dew(w, latitude, longitude)) Trait.dew,
    if (w.temperature <= 0) Trait.frost,
  ];
}

bool _dew(WeatherNow w, double latitude, double longitude) {
  if (w.temperature <= 0 || w.pastHours.isEmpty) return false;
  final sun = sunTimes(w.time, latitude, longitude);
  if (sun == null || w.time.isBefore(sun.firstLight) || !w.time.isBefore(sun.sunrise.add(dewAfterSunrise))) {
    return false;
  }
  final night = w.pastHours.where((h) => h.time.isBefore(sun.sunrise)).toList();
  if (night.isEmpty) return false;
  final closest = night.map((h) => h.temperature - h.dewPoint).reduce((a, b) => a < b ? a : b);
  final cloud = night.map((h) => h.cloudCover).reduce((a, b) => a + b) / night.length;
  final wind = night.map((h) => h.windSpeed).reduce((a, b) => a + b) / night.length;
  return closest <= dewSpread && cloud <= dewMaxCloud && wind <= dewMaxWind;
}
