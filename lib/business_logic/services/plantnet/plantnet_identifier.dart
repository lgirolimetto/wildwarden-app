import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:dio/dio.dart';
import 'package:druid_app/business_logic/interfaces/i_plant_identifier.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/business_logic/services/http/dio_factory.dart';

/// Pl@ntNet (API v2, progetto "all"): una foto, organo riconosciuto in automatico.
///
/// ⚠️ La chiave viaggia dentro l'app: va bene solo sul telefono dello sviluppatore (vedi [AppConfig.plantNetApiKey]).
class PlantNetIdentifier implements IPlantIdentifier {
  static const baseUrl = 'https://my-api.plantnet.org';

  final Dio _dio;
  final String _apiKey;
  final String _language;

  PlantNetIdentifier(AppConfig config, {Dio? dio, String language = 'it'})
    : _dio = dio ?? createDio(config, baseUrl: baseUrl),
      _apiKey = config.plantNetApiKey,
      _language = language;

  @override
  Future<Validation<PlantIdentification>> identify(String photoPath) async {
    if (_apiKey.isEmpty) {
      return Fail.withError(StateError('PLANTNET_API_KEY'), message: 'Chiave Pl@ntNet assente').toInvalid();
    }
    return _dio
        .post<Map<String, dynamic>>(
          '/v2/identify/all',
          queryParameters: {'api-key': _apiKey, 'lang': _language, 'nb-results': 5, 'include-related-images': false},
          data: FormData.fromMap({
            'images': await MultipartFile.fromFile(photoPath, filename: 'pianta.jpg'),
            'organs': 'auto',
          }),
          // 404 = nessuna specie riconosciuta: non è un errore.
          options: Options(validateStatus: (status) => status == 200 || status == 404),
        )
        .toValidation(
          (data) => data?['results'] == null ? PlantIdentification.none : PlantIdentification.fromJson(data!),
        );
  }
}
