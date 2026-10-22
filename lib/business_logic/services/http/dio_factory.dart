import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:dio/dio.dart';
import 'package:druid_app/business_logic/models/app_config.dart';

/// Unico punto di creazione dei client HTTP: timeout, log e (in futuro) autenticazione verso il server.
Dio createDio(AppConfig config, {String? baseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  if (config.logHttp) {
    dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
  }
  return dio;
}

/// Converte una chiamata Dio in `Validation`: errori di rete, HTTP e di parsing diventano `Fail`
/// con un messaggio leggibile, così controller e UI gestiscono un solo tipo di risultato.
extension DioResponseValidation<T> on Future<Response<T>> {
  Future<Validation<R>> toValidation<R>(R Function(T? data) parse) => then(
    (response) => Try(() => parse(response.data)),
  ).catchError((Object error) => (error is DioException ? error.toFail() : _unknown(error)).toInvalid<R>());
}

extension DioExceptionToFail on DioException {
  Fail toFail() {
    final status = response?.statusCode;
    final message = switch (type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => 'Tempo scaduto',
      DioExceptionType.connectionError => 'Connessione assente',
      DioExceptionType.badResponse => 'Risposta HTTP $status',
      DioExceptionType.cancel => 'Richiesta annullata',
      _ => 'Errore di rete',
    };
    return Fail.withException(this, message: message);
  }
}

Fail _unknown(Object error) => error is Exception
    ? Fail.withException(error)
    : Fail.withError(error is Error ? error : StateError(error.toString()));
