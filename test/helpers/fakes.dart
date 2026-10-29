import 'dart:convert';
import 'dart:io';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_catalog_repository.dart';
import 'package:druid_app/business_logic/interfaces/i_clock.dart';
import 'package:druid_app/business_logic/interfaces/i_field_test_log.dart';
import 'package:druid_app/business_logic/interfaces/i_game_event_store.dart';
import 'package:druid_app/business_logic/interfaces/i_link_opener.dart';
import 'package:druid_app/business_logic/interfaces/i_location_sampler.dart';
import 'package:druid_app/business_logic/interfaces/i_permissions.dart';
import 'package:druid_app/business_logic/interfaces/i_weather_service.dart';
import 'package:druid_app/business_logic/models/weather_forecast.dart';
import 'package:druid_app/business_logic/models/weather_now.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_store.dart';
import 'package:druid_app/business_logic/interfaces/i_preferences.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:flutter/material.dart';

/// Catalogo ridotto a 4 specie: elleboro verde, malva, piè di gallo, faggio.
/// Con [kitchen] anche le aromatiche del tutorial, dal catalogo vero dell'app.
Catalog smallCatalog({Map<String, List<String>> protection = const {}, bool kitchen = false}) {
  final json = jsonDecode(File('test/fixtures/catalog_small.json').readAsStringSync()) as Map<String, dynamic>;
  // Nel catalogo ridotto nessuna specie è protetta: i test che servono la proteggono qui.
  for (final species in (json['species'] as List).cast<Map<String, dynamic>>()) {
    if (protection.containsKey(species['sci'])) species['protection'] = protection[species['sci']];
  }
  return Catalog.fromJson(
    json,
    kitchen: kitchen
        ? jsonDecode(File('assets/content/kitchen/catalog.json').readAsStringSync()) as Map<String, dynamic>
        : null,
  );
}

class InMemoryPreferences implements IPreferences {
  final Map<String, String> values;

  InMemoryPreferences([Map<String, String>? initial]) : values = {...?initial};

  @override
  String? getString(String key) => values[key];

  @override
  Future<void> setString(String key, String value) async => values[key] = value;
}

class FakeCatalogRepository implements ICatalogRepository {
  Validation<Catalog> result;
  int calls = 0;

  FakeCatalogRepository(this.result);

  @override
  Future<Validation<Catalog>> loadCatalog() async {
    calls++;
    return result;
  }
}

/// Immagini finte: nei test non si va in rete.
class FakeImageFactory implements RemoteImageFactory {
  const FakeImageFactory();

  @override
  Widget build(BuildContext context, String url, {BoxFit fit = BoxFit.cover}) =>
      ColoredBox(key: ValueKey('image:$url'), color: Colors.grey);

  @override
  Widget buildFile(BuildContext context, String path, {BoxFit fit = BoxFit.cover}) =>
      ColoredBox(key: ValueKey('photo:$path'), color: Colors.green);
}

/// Foto di chi gioca in memoria: i percorsi restano quelli e le cancellazioni si contano.
class FakePhotoStore implements IPhotoStore {
  final deleted = <String>[];

  @override
  String relative(String path) => path;

  @override
  String absolute(String relative) => relative;

  @override
  Future<void> delete(Iterable<String> paths) async => deleted.addAll(paths);
}

class InMemoryGameEventStore implements IGameEventStore {
  final List<GameEvent> events;

  /// Se valorizzato, `append` fallisce: serve a provare il comportamento in caso di errore del database.
  Object? failAppendWith;

  InMemoryGameEventStore([List<GameEvent>? initial]) : events = [...?initial];

  @override
  Future<Validation<List<GameEvent>>> loadAll() async => Valid(List.unmodifiable(events));

  @override
  Future<Validation<GameEvent>> append(GameEvent event) async {
    if (failAppendWith != null) return StateError('$failAppendWith').toInvalid();
    events.add(event);
    return Valid(event);
  }

  @override
  Future<Validation<int>> clear() async {
    final count = events.length;
    events.clear();
    return Valid(count);
  }
}

/// Orologio fermo, spostabile a mano.
class FakeClock implements IClock {
  DateTime current;

  FakeClock([DateTime? start]) : current = start ?? DateTime(2027, 2, 14, 9);

  @override
  DateTime now() => current;

  void advance(Duration duration) => current = current.add(duration);
}

/// Registro delle prove sul campo in memoria.
class InMemoryFieldTestLog implements IFieldTestLog {
  final rows = <String>[];
  String? header;

  @override
  Future<String> location() async => '/prova_sul_campo.csv';

  @override
  Future<void> append(String header, String row) async {
    this.header ??= header;
    rows.add(row);
  }

  @override
  Future<String> readAll() async => rows.isEmpty ? '' : '$header\n${rows.join('\n')}\n';

  @override
  Future<void> clear() async => rows.clear();
}

/// Permessi finti: rispondono come si chiede e contano le richieste.
class FakePermissions implements IPermissions {
  PermissionOutcome camera;
  PermissionOutcome location;
  final requests = <String>[];

  FakePermissions({this.camera = PermissionOutcome.granted, this.location = PermissionOutcome.granted});

  @override
  Future<Validation<PermissionOutcome>> requestCamera() async {
    requests.add('camera');
    return Valid(camera);
  }

  @override
  Future<Validation<PermissionOutcome>> requestLocation() async {
    requests.add('location');
    return Valid(location);
  }

  @override
  Future<Validation<bool>> openAppSettings() async {
    requests.add('settings');
    return Valid(true);
  }
}

/// Link finti: si contano, non si apre niente.
class FakeLinkOpener implements ILinkOpener {
  final opened = <String>[];

  @override
  Future<Validation<bool>> open(String url) async {
    opened.add(url);
    return Valid(true);
  }
}

/// Meteo finto: sereno, senza previsioni di temporale, salvo quella che il test sceglie.
class FakeWeatherService implements IWeatherService {
  WeatherForecast? next;
  final forecasts = <(double, double)>[];

  FakeWeatherService({this.next});

  @override
  Future<Validation<WeatherNow>> now(double latitude, double longitude) async => Valid(
    WeatherNow(
      time: DateTime.utc(2027, 2, 14, 9),
      temperature: 10,
      dewPoint: 2,
      precipitation: 0,
      weatherCode: 0,
      cloudCover: 10,
      windSpeed: 5,
      isDay: true,
    ),
  );

  @override
  Future<Validation<WeatherForecast>> forecast(double latitude, double longitude) async {
    forecasts.add((latitude, longitude));
    return Valid(next ?? WeatherForecast(fetchedAt: DateTime.utc(2027, 2, 14), hours: const []));
  }
}

/// GPS finto: spento (nessuna posizione), oppure una posizione subito.
class FakeLocationSampler implements ILocationSampler {
  ({double latitude, double longitude, double accuracy})? at;

  FakeLocationSampler({this.at});

  @override
  Future<Validation<LocationRecording>> start() async {
    final here = at;
    if (here == null) return Fail.withError(StateError('GPS spento'), message: 'GPS spento').toInvalid();
    return Valid(
      LocationRecording(() async {})..add(latitude: here.latitude, longitude: here.longitude, accuracy: here.accuracy),
    );
  }
}
