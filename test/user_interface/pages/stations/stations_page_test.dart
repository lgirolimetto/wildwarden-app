import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/models/weather_forecast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

void main() {
  tearDown(Get.reset);
  // L'orologio finto dei test: 14 febbraio 2027 alle 9.
  final now = DateTime(2027, 2, 14, 9);

  Station station(String id, String sci, {double lat = 44.48}) => Station(
    id: id,
    speciesSci: sci,
    kind: StationKind.zone,
    latitude: lat,
    longitude: 11.35,
    accuracy: 5,
    confidence: 0.7,
    createdAt: DateTime(2027, 2, 1),
  );
  List<GameEvent> events() {
    final malva = station('m', 'Malva sylvestris'), faggio = station('f', 'Fagus sylvatica', lat: 44.2);
    return [
      for (final s in [malva, faggio]) ...[
        SpeciesEncountered(speciesSci: s.speciesSci, method: EncounterMethod.photo, occurredAt: DateTime(2027, 2, 1)),
        StationCreated(station: s),
      ],
      EssenceDrawn(
        speciesSci: 'Malva sylvestris',
        simulated: false,
        vis: 8,
        stationId: 'm',
        occurredAt: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }

  testWidgets('in Home quante sono pronte; la pagina: prima le pronte, lo stato e il temporale in arrivo', (
    tester,
  ) async {
    final storm = WeatherForecast(
      fetchedAt: now,
      hours: [ForecastHour(time: now.add(const Duration(hours: 3)), weatherCode: 95)],
    );
    registerTestDependencies(
      events: events(),
      weatherService: FakeWeatherService(next: storm),
    );
    await pumpDruidApp(tester);

    await scrollTo(tester, find.byKey(const ValueKey('home-stations')));
    expect(find.text('1 pronte su 2'), findsWidgets);
    await scrollAndTap(tester, find.byKey(const ValueKey('home-stations')));

    expect(find.text('Le tue Stazioni'), findsWidgets);
    final cards = tester.widgetList<Widget>(find.byWidgetPredicate((w) => '${w.key}'.contains('station-card-')));
    expect(cards.map((w) => '${w.key}'), [contains('station-card-f'), contains('station-card-m')]);
    expect(find.text('Pronta'), findsOneWidget);
    expect(find.textContaining('Esaurita: torna pronta'), findsOneWidget);
    expect(find.byKey(const ValueKey('station-storm-f')), findsOneWidget);
  });

  testWidgets('senza Stazioni la Home non mostra la sezione', (tester) async {
    registerTestDependencies();
    await pumpDruidApp(tester);
    expect(find.byKey(const ValueKey('home-stations'), skipOffstage: false), findsNothing);
  });
}
