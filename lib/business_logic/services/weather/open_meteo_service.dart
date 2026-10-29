import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:dio/dio.dart';
import 'package:druid_app/business_logic/interfaces/i_clock.dart';
import 'package:druid_app/business_logic/interfaces/i_weather_service.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/weather_now.dart';
import 'package:druid_app/business_logic/services/http/dio_factory.dart';

/// Open-Meteo (gratuito, senza chiave, per uso non commerciale): il tempo di adesso e le ultime 10 ore. Una risposta
/// vale 15 minuti per una cella di circa 5 km.
class OpenMeteoService implements IWeatherService {
  static const baseUrl = 'https://api.open-meteo.com';
  static const cacheFor = Duration(minutes: 15);

  final Dio _dio;
  final IClock _clock;
  final _cache = <String, ({DateTime at, WeatherNow weather})>{};

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
}
