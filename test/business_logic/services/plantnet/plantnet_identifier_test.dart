import 'dart:io';

import 'package:dio/dio.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/business_logic/services/http/dio_factory.dart';
import 'package:druid_app/business_logic/services/plantnet/plantnet_identifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../../../helpers/test_app.dart';

void main() {
  const config = AppConfig(flavor: 'test', plantNetApiKey: 'chiave', logHttp: false, showDebugTools: true);
  const route = '/v2/identify/all';
  late Dio dio;
  late DioAdapter adapter;
  late PlantNetIdentifier identifier;
  late File photo;

  setUp(() async {
    dio = createDio(config, baseUrl: PlantNetIdentifier.baseUrl);
    adapter = DioAdapter(dio: dio);
    identifier = PlantNetIdentifier(config, dio: dio);
    photo = File('${(await Directory.systemTemp.createTemp('plantnet')).path}/foto.jpg')..writeAsBytesSync([1, 2, 3]);
  });

  void reply(int status, Object body) => adapter.onPost(
    route,
    (server) => server.reply(status, body),
    data: Matchers.any,
    queryParameters: {'api-key': 'chiave', 'lang': 'it', 'nb-results': 5, 'include-related-images': false},
  );

  test('risposta 200: candidati dal più probabile, nomi comuni e identificazioni rimaste', () async {
    reply(200, {
      'results': [
        {
          'score': 0.12,
          'species': {'scientificNameWithoutAuthor': 'Helleborus foetidus', 'commonNames': <String>[]},
        },
        {
          'score': 0.81,
          'species': {
            'scientificNameWithoutAuthor': 'Helleborus viridis',
            'commonNames': ['Elleboro verde'],
            'family': {'scientificNameWithoutAuthor': 'Ranunculaceae'},
          },
          'gbif': {'id': '3033108'},
        },
      ],
      'remainingIdentificationRequests': 497,
    });

    final result = (await identifier.identify([
      PlantPhoto(photo.path, PlantOrgan.whole),
    ])).fold((_) => fail('atteso Valid'), (r) => r);

    expect(result.candidates.map((c) => c.scientificName), ['Helleborus viridis', 'Helleborus foetidus']);
    expect(result.candidates.first.commonNames, ['Elleboro verde']);
    expect(result.candidates.first.score, 0.81);
    expect(result.candidates.first.gbifKey, 3033108);
    expect(result.candidates.first.family, 'Ranunculaceae');
    expect(result.candidates.last.gbifKey, isNull);
    expect(result.remainingRequests, 497);
  });

  test('404 di Pl@ntNet: nessuna specie riconosciuta, non un errore', () async {
    reply(404, {'statusCode': 404, 'error': 'Not Found', 'message': 'Species not found'});

    final result = (await identifier.identify([
      PlantPhoto(photo.path, PlantOrgan.whole),
    ])).fold((_) => fail('atteso Valid'), (r) => r);

    expect(result.candidates, isEmpty);
  });

  test('errore del server: Fail con messaggio leggibile', () async {
    reply(500, {'error': 'boom'});

    final result = await identifier.identify([PlantPhoto(photo.path, PlantOrgan.whole)]);

    result.fold((failures) => expect(failures.single.message, 'Risposta HTTP 500'), (_) => fail('atteso Fail'));
  });

  test('senza chiave non chiama Pl@ntNet', () async {
    final result = await PlantNetIdentifier(testConfig, dio: dio).identify([PlantPhoto(photo.path, PlantOrgan.whole)]);

    result.fold((failures) => expect(failures.single.message, 'Chiave Pl@ntNet assente'), (_) => fail('atteso Fail'));
  });

  test('più foto della stessa pianta in una richiesta, ognuna con la sua parte', () async {
    FormData? sent;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          sent = options.data as FormData;
          handler.next(options);
        },
      ),
    );
    reply(200, {'results': <Object>[]});

    await identifier.identify([
      PlantPhoto(photo.path, PlantOrgan.whole),
      PlantPhoto(photo.path, PlantOrgan.leaf),
      PlantPhoto(photo.path, PlantOrgan.flower),
    ]);

    expect(sent!.files.map((f) => f.key), ['images', 'images', 'images']);
    expect(sent!.fields.map((f) => f.value), ['auto', 'leaf', 'flower']);
  });
}
