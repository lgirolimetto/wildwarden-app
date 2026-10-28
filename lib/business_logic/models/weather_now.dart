/// Il tempo di adesso in un posto, da Open-Meteo, con le ore della notte appena passata (per la Rugiada).
class WeatherNow {
  final DateTime time;

  /// °C.
  final double temperature;
  final double dewPoint;

  /// mm nell'ultima ora.
  final double precipitation;

  /// Codice WMO del tempo (0 sereno, 45/48 nebbia, 51–67 pioviggine e pioggia, 80–82 rovesci, 95–99 temporale…).
  final int weatherCode;

  /// Copertura nuvolosa, 0–100 %.
  final double cloudCover;

  /// km/h a 10 m.
  final double windSpeed;

  /// Metri; null se Open-Meteo non la dà.
  final double? visibility;
  final bool isDay;

  /// Le ore appena passate (la notte, se è mattina), dalla più vecchia.
  final List<WeatherHour> pastHours;

  const WeatherNow({
    required this.time,
    required this.temperature,
    required this.dewPoint,
    required this.precipitation,
    required this.weatherCode,
    required this.cloudCover,
    required this.windSpeed,
    required this.isDay,
    this.visibility,
    this.pastHours = const [],
  });

  /// Risposta di `api.open-meteo.com/v1/forecast` con `timezone=GMT` (orari in UTC).
  factory WeatherNow.fromOpenMeteo(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    DateTime utc(String time) => DateTime.parse('${time}Z');
    double number(Object? value) => (value as num?)?.toDouble() ?? 0;
    final time = utc(current['time'] as String);
    final hourly = json['hourly'] as Map<String, dynamic>?;
    final hours = <WeatherHour>[];
    if (hourly != null) {
      final times = (hourly['time'] as List).cast<String>();
      for (var i = 0; i < times.length; i++) {
        final at = utc(times[i]);
        if (at.isAfter(time)) continue;
        hours.add(
          WeatherHour(
            time: at,
            temperature: number((hourly['temperature_2m'] as List)[i]),
            dewPoint: number((hourly['dew_point_2m'] as List)[i]),
            cloudCover: number((hourly['cloud_cover'] as List)[i]),
            windSpeed: number((hourly['wind_speed_10m'] as List)[i]),
          ),
        );
      }
    }
    return WeatherNow(
      time: time,
      temperature: number(current['temperature_2m']),
      dewPoint: number(current['dew_point_2m']),
      precipitation: number(current['precipitation']),
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      cloudCover: number(current['cloud_cover']),
      windSpeed: number(current['wind_speed_10m']),
      visibility: (current['visibility'] as num?)?.toDouble(),
      isDay: (current['is_day'] as num?) == 1,
      pastHours: hours,
    );
  }
}

/// Un'ora passata: quanto basta per dire se la notte è stata fresca e serena.
class WeatherHour {
  final DateTime time;
  final double temperature;
  final double dewPoint;
  final double cloudCover;
  final double windSpeed;

  const WeatherHour({
    required this.time,
    required this.temperature,
    required this.dewPoint,
    required this.cloudCover,
    required this.windSpeed,
  });
}
