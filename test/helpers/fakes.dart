import 'dart:convert';
import 'dart:io';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_catalog_repository.dart';
import 'package:druid_app/business_logic/interfaces/i_clock.dart';
import 'package:druid_app/business_logic/interfaces/i_game_event_store.dart';
import 'package:druid_app/business_logic/interfaces/i_preferences.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:flutter/material.dart';

/// Catalogo ridotto a 4 specie: elleboro verde, malva, piè di gallo, faggio.
Catalog smallCatalog() =>
    Catalog.fromJson(jsonDecode(File('test/fixtures/catalog_small.json').readAsStringSync()) as Map<String, dynamic>);

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
