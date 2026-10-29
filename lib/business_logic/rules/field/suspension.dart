import 'package:druid_app/business_logic/models/weather_forecast.dart';

/// Raccolta sospesa col temporale e con i fenomeni atmosferici intensi (capitolo 02, 🔵 2026-10-26): si guarda la
/// previsione oraria della cella della Stazione e si sospende da un'ora prima a un'ora dopo la finestra prevista, così
/// nessuno corre ad Attingere prima del temporale o appena finito. Non consuma la raccolta del giorno.

/// Raffiche da cui la raccolta è sospesa, km/h.
const severeGusts = 60.0;

/// Neve forte in un'ora, cm.
const heavySnowfall = 2.0;

/// Margine prima e dopo le ore di tempo intenso.
const suspensionMargin = Duration(hours: 1);

enum SevereWeather { storm, hail, wind, snow }

/// Il fenomeno intenso dell'ora, se c'è (il più grave).
SevereWeather? severeOf(ForecastHour hour) {
  if (hour.weatherCode == 96 || hour.weatherCode == 99) return SevereWeather.hail;
  if (hour.weatherCode >= 95) return SevereWeather.storm;
  if (hour.windGusts >= severeGusts) return SevereWeather.wind;
  if (hour.weatherCode == 75 || hour.weatherCode == 86 || hour.snowfall >= heavySnowfall) return SevereWeather.snow;
  return null;
}

/// La raccolta è sospesa: per che cosa e fino a quando.
class Suspension {
  final SevereWeather reason;
  final DateTime until;

  const Suspension(this.reason, this.until);
}

/// Le finestre di tempo intenso, con il margine: ore intense consecutive diventano una finestra sola.
List<(DateTime from, DateTime to, SevereWeather reason)> _windows(WeatherForecast forecast) {
  final out = <(DateTime, DateTime, SevereWeather)>[];
  for (final hour in forecast.hours) {
    final reason = severeOf(hour);
    if (reason == null) continue;
    final from = hour.time.subtract(suspensionMargin);
    final to = hour.time.add(const Duration(hours: 1)).add(suspensionMargin);
    if (out.isNotEmpty && !from.isAfter(out.last.$2)) {
      out[out.length - 1] = (out.last.$1, to, out.last.$3);
    } else {
      out.add((from, to, reason));
    }
  }
  return out;
}

/// La sospensione in corso a [now], se c'è.
Suspension? suspensionAt(WeatherForecast forecast, DateTime now) {
  for (final (from, to, reason) in _windows(forecast)) {
    if (!now.isBefore(from) && now.isBefore(to)) return Suspension(reason, to);
  }
  return null;
}

/// La prossima sospensione entro [within] da [now] (per l'avviso nella pagina delle Stazioni): "al tuo arrivo la
/// raccolta potrebbe essere sospesa".
Suspension? upcomingSuspension(WeatherForecast forecast, DateTime now, {Duration within = const Duration(hours: 6)}) {
  for (final (from, to, reason) in _windows(forecast)) {
    if (!to.isAfter(now)) continue;
    if (!from.isAfter(now.add(within))) return Suspension(reason, to);
  }
  return null;
}
