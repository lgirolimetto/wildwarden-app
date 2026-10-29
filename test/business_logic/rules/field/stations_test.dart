import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/rules/field/stations.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Giardini Margherita, Bologna: 0,0001° di latitudine ≈ 11 m.
  const lat = 44.4830, lon = 11.3530;
  final morning = DateTime(2026, 10, 29, 9);

  Station station(
    String sci, {
    double latitude = lat,
    double longitude = lon,
    DateTime? at,
    StationKind kind = StationKind.zone,
    String? photo,
  }) => Station(
    id: '${sci.hashCode}-${(at ?? morning).millisecondsSinceEpoch}',
    speciesSci: sci,
    kind: kind,
    latitude: latitude,
    longitude: longitude,
    accuracy: 5,
    confidence: 0.6,
    createdAt: at ?? morning,
    photo: photo,
  );

  GameState with_(List<Station> stations) => GameState.replay([for (final s in stations) StationCreated(station: s)]);

  test('distanza: 0,0001° di latitudine sono circa 11 metri', () {
    expect(distanceMeters(lat, lon, lat + 0.0001, lon), closeTo(11.1, 0.1));
    expect(distanceMeters(lat, lon, lat, lon), 0);
  });

  test('pianta della mappa, Scoperta o Ospite', () {
    expect(stationKindOf(inCatalog: true, inRegionalFlora: true), StationKind.zone);
    expect(stationKindOf(inCatalog: false, inRegionalFlora: true), StationKind.discovery);
    expect(stationKindOf(inCatalog: false, inRegionalFlora: false), StationKind.guest);
  });

  test('la stessa specie entro 20 metri è la stessa stazione; più lontano o un\'altra specie no', () {
    final state = with_([station('Helleborus viridis')]);
    expect(sameStation(state, 'Helleborus viridis', lat + 0.0001, lon)?.speciesSci, 'Helleborus viridis');
    expect(sameStation(state, 'Helleborus viridis', lat + 0.0003, lon), isNull);
    expect(sameStation(state, 'Malva sylvestris', lat, lon), isNull);
  });

  test('una stazione nuova al giorno: domani si può di nuovo', () {
    final state = with_([station('Helleborus viridis')]);
    expect(canCreateStation(GameState.empty, morning), isTrue);
    expect(canCreateStation(state, morning.add(const Duration(hours: 8))), isFalse);
    expect(canCreateStation(state, morning.add(const Duration(days: 1))), isTrue);
  });

  test('le stazioni vicine a un punto (per il depauperamento)', () {
    final state = with_([
      station('Helleborus viridis'),
      station('Malva sylvestris', latitude: lat + 0.0005),
      station('Fagus sylvatica', latitude: lat + 0.01),
    ]);
    expect(stationsWithin(state, lat, lon, 150).map((s) => s.speciesSci), ['Helleborus viridis', 'Malva sylvestris']);
  });

  test('evento della stazione: andata e ritorno dal database, tipo stabile, anche per un\'Ospite', () {
    final guest = Station(
      id: 'a1',
      speciesSci: 'Anthurium scherzerianum',
      kind: StationKind.guest,
      latitude: lat,
      longitude: lon,
      accuracy: 4.5,
      confidence: 0.68,
      createdAt: morning,
      commonName: 'Anturio',
      family: 'Araceae',
    );
    final event = StationCreated(station: guest);
    final decoded =
        GameEvent.decode(type: event.type, payload: event.encodePayload(), occurredAt: morning) as StationCreated;
    expect(StationCreated.typeId, 'station_created');
    expect(decoded.station.kind, StationKind.guest);
    expect((decoded.station.latitude, decoded.station.accuracy, decoded.station.confidence), (lat, 4.5, 0.68));
    expect((decoded.station.commonName, decoded.station.family), ('Anturio', 'Araceae'));
    expect(GameState.replay([decoded]).stations.single.id, 'a1');
  });

  test('la tua foto: quella della prima Stazione che ne ha una; le Stazioni dalla più vecchia', () {
    final later = morning.add(const Duration(days: 2));
    final state = with_([
      station('Helleborus viridis', at: later, photo: 'photos/2.jpg', latitude: lat + 0.01),
      station('Helleborus viridis'),
      station(
        'Helleborus viridis',
        at: morning.add(const Duration(days: 5)),
        photo: 'photos/3.jpg',
        latitude: lat + 0.02,
      ),
    ]);
    expect(stationsOf(state, 'Helleborus viridis').map((s) => s.createdAt), [
      morning,
      later,
      morning.add(const Duration(days: 5)),
    ]);
    expect(firstPhotoOf(state, 'Helleborus viridis')!.photo, 'photos/2.jpg');
    expect(firstPhotoOf(state, 'Malva sylvestris'), isNull);
  });

  test('evento della stazione con la foto e i tratti; quelli di prima ne sono senza', () {
    final withPhoto = Station(
      id: 'b2',
      speciesSci: 'Helleborus viridis',
      kind: StationKind.zone,
      latitude: lat,
      longitude: lon,
      accuracy: 4,
      confidence: 0.7,
      createdAt: morning,
      photo: 'photos/1.jpg',
      traits: const [Trait.dawn, Trait.moon],
    );
    final event = StationCreated(station: withPhoto);
    final decoded =
        GameEvent.decode(type: event.type, payload: event.encodePayload(), occurredAt: morning) as StationCreated;
    expect(decoded.station.photo, 'photos/1.jpg');
    expect(decoded.station.traits, [Trait.dawn, Trait.moon]);

    final old = StationCreated(station: station('Helleborus viridis'));
    final decodedOld =
        GameEvent.decode(type: old.type, payload: old.encodePayload(), occurredAt: morning) as StationCreated;
    expect(decodedOld.station.photo, isNull);
    expect(decodedOld.station.traits, isEmpty);
  });
}
