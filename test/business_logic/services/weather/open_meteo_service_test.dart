import 'package:dio/dio.dart';
import 'package:druid_app/business_logic/services/http/dio_factory.dart';
import 'package:druid_app/business_logic/services/weather/open_meteo_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late FakeClock clock;
  late OpenMeteoService service;
  var calls = 0;

  setUp(() {
    dio = createDio(testConfig, baseUrl: OpenMeteoService.baseUrl);
    adapter = DioAdapter(dio: dio);
    clock = FakeClock(DateTime(2026, 10, 28, 12));
    service = OpenMeteoService(testConfig, clock, dio: dio);
    calls = 0;
    // Le richieste che arrivano davvero alla rete (quelle servite dalla cache no).
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls++;
          handler.next(options);
        },
      ),
    );
    adapter.onGet('/v1/forecast', (server) {
      server.reply(200, {
        'current': {
          'time': '2026-10-28T11:00',
          'temperature_2m': 14.2,
          'dew_point_2m': 8.1,
          'precipitation': 0.0,
          'weather_code': 1,
          'cloud_cover': 12,
          'wind_speed_10m': 6.5,
          'visibility': 24140.0,
          'is_day': 1,
        },
        'hourly': {
          'time': ['2026-10-28T10:00', '2026-10-28T11:00', '2026-10-28T12:00'],
          'temperature_2m': [12.0, 14.2, 15.0],
          'dew_point_2m': [8.0, 8.1, 8.3],
          'cloud_cover': [20, 12, 10],
          'wind_speed_10m': [5.0, 6.5, 7.0],
        },
      });
    });
  });

  test('il tempo di adesso, con le ore passate (non quelle future), in UTC', () async {
    final weather = (await service.now(44.49, 11.34)).fold((_) => fail('atteso Valid'), (w) => w);
    expect(weather.time, DateTime.utc(2026, 10, 28, 11));
    expect(weather.temperature, 14.2);
    expect(weather.isDay, isTrue);
    expect(weather.visibility, 24140);
    expect(weather.pastHours.map((h) => h.time.hour), [10, 11]);
  });

  test('una risposta vale 15 minuti nella stessa cella, poi si richiede', () async {
    await service.now(44.49, 11.34);
    await service.now(44.491, 11.341);
    expect(calls, 1);
    clock.current = clock.current.add(const Duration(minutes: 16));
    await service.now(44.49, 11.34);
    expect(calls, 2);
  });
}
