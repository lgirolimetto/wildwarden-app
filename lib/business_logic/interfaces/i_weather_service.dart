import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/models/weather_forecast.dart';
import 'package:druid_app/business_logic/models/weather_now.dart';

/// Il tempo di adesso in un posto. Oggi Open-Meteo chiamato dall'app con una cache breve; nel blocco 7 la cache è
/// condivisa sul server (capitolo 05: meteo con cache per area e ora).
abstract interface class IWeatherService {
  Future<Validation<WeatherNow>> now(double latitude, double longitude);

  /// La previsione oraria (qualche ora passata e le prossime 12): per la raccolta sospesa col temporale.
  Future<Validation<WeatherForecast>> forecast(double latitude, double longitude);
}
