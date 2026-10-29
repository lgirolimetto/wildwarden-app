import 'package:dio/dio.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/services/http/dio_factory.dart';
import 'package:druid_app/business_logic/services/weather/open_meteo_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../../../helpers/fakes.dart';

void main() {
  const config = AppConfig(flavor: 'test', plantNetApiKey: '', logHttp: false, showDebugTools: true);
  late Dio dio;
  late DioAdapter adapter;
  late FakeClock clock;
  late OpenMeteoService service;
  var calls = 0;

  setUp(() {
    dio = createDio(config, baseUrl: OpenMeteoService.baseUrl);
    adapter = DioAdapter(dio: dio);
    clock = FakeClock(DateTime.utc(2027, 6, 14, 12));
    service = OpenMeteoService(config, clock, dio: dio);
    calls = 0;
    // Le richieste che arrivano davvero alla rete (finta): la risposta dell'adapter si prepara una volta sola.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls++;
          handler.next(options);
        },
      ),
    );
    adapter.onGet(
      '/v1/forecast',
      (server) => server.reply(200, {
        'hourly': {
          'time': ['2027-06-14T12:00', '2027-06-14T13:00'],
          'weather_code': [1, 96],
          'wind_gusts_10m': [20.5, 70.1],
          'snowfall': [0, 0],
        },
      }),
      queryParameters: {
        'latitude': '44.5',
        'longitude': '11.4',
        'hourly': 'weather_code,wind_gusts_10m,snowfall',
        'past_hours': 2,
        'forecast_hours': 12,
        'timezone': 'GMT',
      },
    );
  });

  test('previsione oraria in UTC, con codici, raffiche e neve', () async {
    final result = await service.forecast(44.483, 11.353);
    final forecast = result.fold((f) => fail('$f'), (f) => f);
    expect(forecast.hours.map((h) => h.time), [DateTime.utc(2027, 6, 14, 12), DateTime.utc(2027, 6, 14, 13)]);
    expect(forecast.hours.last.weatherCode, 96);
    expect(forecast.hours.last.windGusts, 70.1);
  });

  test("cache per cella e ora: due Stazioni vicine, una richiesta; dopo un'ora si richiede", () async {
    await service.forecast(44.483, 11.353);
    await service.forecast(44.47, 11.36);
    expect(calls, 1);
    clock.advance(const Duration(hours: 1));
    await service.forecast(44.483, 11.353);
    expect(calls, 2);
  });
}
