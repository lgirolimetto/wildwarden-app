/// La previsione oraria di un posto, da Open-Meteo: quanto serve per sapere se la raccolta è sospesa (capitolo 02,
/// "Con il temporale la raccolta è sospesa").
class WeatherForecast {
  /// Quando è stata chiesta (per la cache).
  final DateTime fetchedAt;

  /// Le ore, dalla più vecchia: qualche ora passata e le prossime.
  final List<ForecastHour> hours;

  const WeatherForecast({required this.fetchedAt, required this.hours});

  /// Risposta di `api.open-meteo.com/v1/forecast` con `timezone=GMT` (orari in UTC).
  factory WeatherForecast.fromOpenMeteo(Map<String, dynamic> json, DateTime fetchedAt) {
    final hourly = json['hourly'] as Map<String, dynamic>;
    final times = (hourly['time'] as List).cast<String>();
    double number(String key, int i) => ((hourly[key] as List?)?[i] as num?)?.toDouble() ?? 0;
    return WeatherForecast(
      fetchedAt: fetchedAt,
      hours: [
        for (var i = 0; i < times.length; i++)
          ForecastHour(
            time: DateTime.parse('${times[i]}Z'),
            weatherCode: number('weather_code', i).toInt(),
            windGusts: number('wind_gusts_10m', i),
            snowfall: number('snowfall', i),
          ),
      ],
    );
  }
}

/// Un'ora della previsione, da [time] all'ora dopo.
class ForecastHour {
  final DateTime time;

  /// Codice WMO (95–99 temporale; 96 e 99 con grandine; 75 e 86 neve forte).
  final int weatherCode;

  /// Raffiche a 10 m, km/h.
  final double windGusts;

  /// Neve nell'ora, cm.
  final double snowfall;

  const ForecastHour({required this.time, required this.weatherCode, this.windGusts = 0, this.snowfall = 0});
}
