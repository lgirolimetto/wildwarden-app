import 'package:druid_app/business_logic/interfaces/i_weather_service.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/models/weather_forecast.dart';
import 'package:druid_app/business_logic/rules/field/suspension.dart';
import 'package:druid_app/business_logic/services/weather/open_meteo_service.dart';
import 'package:get/get.dart';

/// Le previsioni delle celle delle tue Stazioni, per l'avviso "al tuo arrivo la raccolta potrebbe essere sospesa"
/// (capitolo 02). Una richiesta per cella; se il meteo non risponde, nessun avviso.
class StationsController extends GetxController {
  final IWeatherService _weather;

  StationsController(this._weather);

  final _forecasts = <String, WeatherForecast>{};

  Future<void> load(List<Station> stations) async {
    final cells = <String, Station>{for (final s in stations) forecastCell(s.latitude, s.longitude): s};
    for (final MapEntry(key: cell, value: s) in cells.entries) {
      (await _weather.forecast(s.latitude, s.longitude)).fold((_) {}, (f) => _forecasts[cell] = f);
    }
    update();
  }

  /// La raccolta è sospesa adesso alla Stazione.
  Suspension? suspendedAt(Station station, DateTime now) {
    final forecast = _forecasts[forecastCell(station.latitude, station.longitude)];
    return forecast == null ? null : suspensionAt(forecast, now);
  }

  /// La sospensione prevista nelle prossime ore (non quella in corso): l'avviso prima di partire.
  Suspension? upcomingAt(Station station, DateTime now) {
    final forecast = _forecasts[forecastCell(station.latitude, station.longitude)];
    if (forecast == null || suspensionAt(forecast, now) != null) return null;
    return upcomingSuspension(forecast, now);
  }
}
