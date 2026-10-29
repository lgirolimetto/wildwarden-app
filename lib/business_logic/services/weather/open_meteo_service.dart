import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:dio/dio.dart';
import 'package:druid_app/business_logic/interfaces/i_clock.dart';
import 'package:druid_app/business_logic/interfaces/i_weather_service.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/weather_forecast.dart';
import 'package:druid_app/business_logic/models/weather_now.dart';
import 'package:druid_app/business_logic/services/http/dio_factory.dart';

/// Open-Meteo (gratuito, senza chiave, per uso non commerciale): il tempo di adesso e le ultime 10 ore. Una risposta
/// vale 15 minuti per una cella di circa 5 km.
class OpenMeteoService implements IWeatherService {
  static const baseUrl = 'https://api.open-meteo.com';
  static const cacheFor = Duration(minutes: 15);

  /// La previsione oraria vale un'ora per una cella di 0,1° (circa 10 km): capitolo 05, meteo con cache per area e
  /// ora.
  static const forecastCacheFor = Duration(hours: 1);

  final Dio _dio;
  final IClock _clock;
  final _cache = <String, ({DateTime at, WeatherNow weather})>{};
  final _forecasts = <String, WeatherForecast>{};

  OpenMeteoService(AppConfig config, this._clock, {Dio? dio}) : _dio = dio ?? createDio(config, baseUrl: baseUrl);

  @override
  Future<Validation<WeatherNow>> now(double latitude, double longitude) async {
    // Celle di 0,05° (circa 5 km): il meteo non cambia da un passo all'altro.
    final cell = '${(latitude * 20).round()}:${(longitude * 20).round()}';
    final cached = _cache[cell];
    if (cached != null && _clock.now().difference(cached.at) < cacheFor) return Valid(cached.weather);
    final result = await _dio
        .get<Map<String, dynamic>>(
          '/v1/forecast',
          queryParameters: {
            'latitude': latitude.toStringAsFixed(3),
            'longitude': longitude.toStringAsFixed(3),
            'current':
                'temperature_2m,dew_point_2m,precipitation,weather_code,cloud_cover,wind_speed_10m,visibility,is_day',
            'hourly': 'temperature_2m,dew_point_2m,cloud_cover,wind_speed_10m',
            'past_hours': 10,
            'forecast_hours': 1,
            'timezone': 'GMT',
          },
        )
        .toValidation((data) => WeatherNow.fromOpenMeteo(data!));
    result.fold((_) {}, (weather) => _cache[cell] = (at: _clock.now(), weather: weather));
    return result;
  }

  @override
  Future<Validation<WeatherForecast>> forecast(double latitude, double longitude) async {
    final cell = forecastCell(latitude, longitude);
    final cached = _forecasts[cell];
    if (cached != null && _clock.now().difference(cached.fetchedAt) < forecastCacheFor) return Valid(cached);
    final now = _clock.now();
    final result = await _dio
        .get<Map<String, dynamic>>(
          '/v1/forecast',
          queryParameters: {
            // Il centro della cella: la stessa richiesta per tutte le Stazioni della cella.
            'latitude': ((latitude * 10).round() / 10).toStringAsFixed(1),
            'longitude': ((longitude * 10).round() / 10).toStringAsFixed(1),
            'hourly': 'weather_code,wind_gusts_10m,snowfall',
            'past_hours': 2,
            'forecast_hours': 12,
            'timezone': 'GMT',
          },
        )
        .toValidation((data) => WeatherForecast.fromOpenMeteo(data!, now));
    result.fold((_) {}, (forecast) => _forecasts[cell] = forecast);
    return result;
  }
}

/// La cella meteo di 0,1° di un punto: la stessa per le Stazioni vicine (capitolo 02, "solo nei dintorni del
/// temporale").
String forecastCell(double latitude, double longitude) => '${(latitude * 10).round()}:${(longitude * 10).round()}';
