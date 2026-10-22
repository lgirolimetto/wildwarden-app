import 'package:dio/dio.dart';
import 'package:druid_app/business_logic/services/http/dio_factory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../../helpers/test_app.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;

  setUp(() {
    dio = createDio(testConfig, baseUrl: 'https://example.test');
    adapter = DioAdapter(dio: dio);
  });

  test('risposta 200: il parse produce un Valid', () async {
    adapter.onGet('/meteo', (server) => server.reply(200, {'temperature': 12.5}));

    final result = await dio.get<Map<String, dynamic>>('/meteo').toValidation((data) => data!['temperature'] as double);

    expect(result.fold((_) => null, (t) => t), 12.5);
  });

  test('risposta 500: Fail con messaggio leggibile', () async {
    adapter.onGet('/meteo', (server) => server.reply(500, {'error': 'boom'}));

    final result = await dio.get<Map<String, dynamic>>('/meteo').toValidation((data) => data);

    expect(result.isValid, isFalse);
    result.fold((failures) => expect(failures.single.message, 'Risposta HTTP 500'), (_) => fail('atteso Fail'));
  });

  test('errore nel parse: Fail, non eccezione', () async {
    adapter.onGet('/meteo', (server) => server.reply(200, {'altro': 1}));

    final result = await dio.get<Map<String, dynamic>>('/meteo').toValidation((data) => data!['temperature'] as double);

    expect(result.isValid, isFalse);
  });
}
