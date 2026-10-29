import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/rules/field/station_state.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  final catalog = smallCatalog();
  const lat = 44.4830, lon = 11.3530;
  final morning = DateTime(2027, 2, 14, 9);

  Station station(String id, {String sci = 'Malva sylvestris', double dLat = 0, double confidence = 0.7}) => Station(
    id: id,
    speciesSci: sci,
    kind: StationKind.zone,
    latitude: lat + dLat,
    longitude: lon,
    accuracy: 5,
    confidence: confidence,
    createdAt: morning.subtract(const Duration(days: 10)),
  );
  EssenceDrawn draw(Station s, DateTime at) =>
      EssenceDrawn(speciesSci: s.speciesSci, simulated: false, vis: 10, stationId: s.id, occurredAt: at);
  GameState play(List<GameEvent> events) => GameState.replay(events);

  test('il grado della Stazione è quello della specie; fuori catalogo come una Comune', () {
    final grade = catalog.speciesBySci('Malva sylvestris')!.grade;
    expect(gradeOf(station('a'), catalog), grade);
    expect(gradeOf(station('b', sci: 'Anthurium scherzerianum'), catalog), Grade.common);
  });

  test('una raccolta: esaurita oggi, in rigenerazione domani se serve, poi pronta', () {
    final malva = station('a');
    final grade = gradeOf(malva, catalog);
    final state = play([StationCreated(station: malva), draw(malva, morning)]);
    expect(statusOf(malva, catalog, GameState.replay([StationCreated(station: malva)]), morning), StationStatus.ready);
    expect(statusOf(malva, catalog, state, morning.add(const Duration(hours: 2))), StationStatus.exhausted);
    final back = readyAt(malva, catalog, state, morning)!;
    expect(back, morning.add(regrowthByGrade[grade]!));
    expect(statusOf(malva, catalog, state, back), StationStatus.ready);
    if (regrowthByGrade[grade]! > const Duration(hours: 24)) {
      expect(statusOf(malva, catalog, state, morning.add(const Duration(hours: 25))), StationStatus.regrowing);
    }
  });

  test('una Comune attinta alle 9 torna pronta alle 5 del giorno dopo; una Rara dopo 3 giorni', () {
    expect(regrowthByGrade[Grade.common], const Duration(hours: 20));
    expect(regrowthByGrade[Grade.rare], const Duration(days: 3));
  });

  test('le Stazioni qui, dalla più vicina', () {
    final near = station('near', dLat: 0.00005);
    final far = station('far', sci: 'Fagus sylvatica', dLat: 0.00015);
    final away = station('away', sci: 'Helleborus viridis', dLat: 0.01);
    final state = play([
      for (final s in [far, away, near]) StationCreated(station: s),
    ]);
    expect(stationsHere(state, lat, lon).map((s) => s.id), ['near', 'far']);
  });

  test('isolamento: curva morbida tra 60 % e 115 %; una Stazione sola è isolata', () {
    expect(isolationFactor(50), 0.6);
    expect(isolationFactor(225), closeTo(0.8, 1e-9));
    expect(isolationFactor(550), closeTo(1.0, 1e-9));
    expect(isolationFactor(400), inInclusiveRange(0.8, 1.0));
    expect(isolationFactor(5000), 1.15);
    final alone = station('a');
    expect(isolationOf(alone, play([StationCreated(station: alone)])), 1.15);
    final neighbour = station('b', sci: 'Fagus sylvatica', dLat: 0.0005); // circa 55 m
    expect(isolationOf(alone, play([StationCreated(station: alone), StationCreated(station: neighbour)])), 0.6);
  });

  test('forza: piena dal 40 %, sotto in proporzione, mai meno del 25 %', () {
    expect(strengthOf(station('a', confidence: 0.8)), 1);
    expect(strengthOf(station('a', confidence: 0.3)), closeTo(0.75, 1e-9));
    expect(strengthOf(station('a', confidence: 0.05)), minimumStrength);
  });

  test('Vis di una raccolta: anello, forza, isolamento, Ospite, scatto sospetto', () {
    final s = station('a');
    final state = play([StationCreated(station: s)]);
    expect(
      visOfDraw(ring: 1, station: s, state: state),
      12,
      reason: '10 × 1,15 isolata',
    );
    expect(visOfDraw(ring: 0.5, station: s, state: state), 6);
    expect(
      visOfDraw(ring: 0, station: s, state: state),
      3,
      reason: "l'anello conta almeno il 30 %",
    );
    expect(visOfDraw(ring: 1, station: s, state: state, suspicious: true), 6);
    final guest = Station(
      id: 'g',
      speciesSci: 'Ocimum basilicum',
      kind: StationKind.guest,
      latitude: lat,
      longitude: lon,
      accuracy: 5,
      confidence: 0.8,
      createdAt: morning,
    );
    expect(
      visOfDraw(
        ring: 1,
        station: guest,
        state: play([StationCreated(station: guest)]),
      ),
      3,
    );
  });

  test("l'Essenza ricorda la Stazione: andata e ritorno dal database", () {
    final event = draw(station('a'), morning);
    final decoded =
        GameEvent.decode(type: event.type, payload: event.encodePayload(), occurredAt: morning) as EssenceDrawn;
    expect(decoded.stationId, 'a');
    expect(GameState.replay([decoded]).lastStationDraws, {'a': morning});
  });
}
