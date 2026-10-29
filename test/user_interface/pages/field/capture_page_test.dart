import 'dart:io';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/interfaces/i_plant_identifier.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/location_fix.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

class _Camera implements IPhotoSource {
  final String path;
  _Camera(this.path);

  @override
  Future<Validation<TakenPhoto>> takePhoto({bool single = false}) async => Valid(
    TakenPhoto(
      photos: [PlantPhoto(path, PlantOrgan.whole)],
      position: const LocationFix(elapsed: Duration.zero, latitude: 44.48, longitude: 11.35, accuracy: 5),
    ),
  );
}

class _Identifier implements IPlantIdentifier {
  final PlantIdentification regional;
  final PlantIdentification world;
  _Identifier({required this.regional, this.world = PlantIdentification.none});

  @override
  Future<Validation<PlantIdentification>> identify(
    List<PlantPhoto> photos, {
    PlantFlora flora = PlantFlora.world,
  }) async => Valid(flora == PlantFlora.regional ? regional : world);
}

void main() {
  const config = AppConfig(flavor: 'test', plantNetApiKey: 'chiave', logHttp: false, showDebugTools: true);
  late String photo;

  setUp(() {
    photo = '${Directory.systemTemp.createTempSync('cattura').path}/foto.jpg';
    File(photo).writeAsBytesSync([0]);
  });
  tearDown(Get.reset);

  testWidgets('dalla Home: foto, ipotesi giusta, la pianta della mappa, nuova stazione e PE bonus', (tester) async {
    registerTestDependencies(
      config: config,
      photoSource: _Camera(photo),
      plantIdentifier: _Identifier(
        regional: const PlantIdentification(
          candidates: [PlantCandidate(scientificName: 'Helleborus viridis', commonNames: [], score: 0.7)],
        ),
      ),
    );
    await pumpDruidApp(tester);
    await tester.tap(find.byKey(const ValueKey('nav-action')));
    await tester.pumpAndSettle();

    expect(find.text('Che pianta pensi che sia?'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('capture-guess')), 'Helleborus viridis');
    await tester.tap(find.byKey(const ValueKey('capture-guess-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Pl@ntNet pensa che sia:'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('capture-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Ci hai preso!'), findsOneWidget);
    expect(find.text('È nata una nuova Stazione.'), findsOneWidget);
    expect(find.byKey(const ValueKey('capture-first-photo')), findsOneWidget);
    expect(find.text('+20 PE'), findsOneWidget);
    final state = Get.find<ProgressController>().state;
    expect(state.hasEncountered('Helleborus viridis'), isTrue);
    expect(state.stations, hasLength(1));
  });

  testWidgets('un\'Ospite: dalla flora del mondo, con il suo segno e la spinta di PE', (tester) async {
    registerTestDependencies(
      config: config,
      photoSource: _Camera(photo),
      plantIdentifier: _Identifier(
        regional: PlantIdentification.none,
        world: const PlantIdentification(
          candidates: [
            PlantCandidate(
              scientificName: 'Ocimum basilicum',
              commonNames: ['Basilico'],
              score: 0.8,
              family: 'Lamiaceae',
            ),
          ],
        ),
      ),
    );
    await pumpDruidApp(tester);
    await tester.tap(find.byKey(const ValueKey('nav-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('capture-guess-skip')));
    await tester.pumpAndSettle();
    expect(find.text('Ospite'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('capture-confirm')));
    await tester.pumpAndSettle();

    expect(find.textContaining('è un\'Ospite'), findsOneWidget);
    expect(find.text('+10 PE'), findsOneWidget);
  });

  testWidgets('senza chiave Pl@ntNet l\'app lo dice', (tester) async {
    registerTestDependencies(photoSource: _Camera(photo));
    await pumpDruidApp(tester);
    await tester.tap(find.byKey(const ValueKey('nav-action')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Manca la chiave di Pl@ntNet'), findsOneWidget);
  });

  testWidgets('tutorial, il basilico: Ospite, da dove viene e la prima Essenza', (tester) async {
    registerTestDependencies(
      config: config,
      catalog: Valid(smallCatalog(kitchen: true)),
      events: [OnboardingMarked(mark: OnboardingMark.tutorialStarted, occurredAt: DateTime(2027, 2, 14))],
      photoSource: _Camera(photo),
      plantIdentifier: _Identifier(
        regional: PlantIdentification.none,
        world: const PlantIdentification(
          candidates: [
            PlantCandidate(scientificName: 'Ocimum basilicum', commonNames: ['Basilico'], score: 0.8),
          ],
        ),
      ),
    );
    await pumpDruidApp(tester);
    await tester.tap(find.byKey(const ValueKey('nav-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('capture-guess-skip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('capture-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Ospite'), findsOneWidget);
    expect(find.byKey(const ValueKey('capture-origin')), findsOneWidget);
    await scrollTo(tester, find.byKey(const ValueKey('capture-essence')));
    expect(find.byKey(const ValueKey('capture-essence')), findsOneWidget);
    expect(Get.find<ProgressController>().state.essences, hasLength(1));
  });

  testWidgets('alla tua Stazione: "Sei alla tua Stazione", Attingi e l\'Essenza, senza Pl@ntNet', (tester) async {
    final station = Station(
      id: 's1',
      speciesSci: 'Helleborus viridis',
      kind: StationKind.zone,
      latitude: 44.48,
      longitude: 11.35,
      accuracy: 5,
      confidence: 0.7,
      createdAt: DateTime(2027, 2, 10),
    );
    registerTestDependencies(
      events: [
        SpeciesEncountered(
          speciesSci: station.speciesSci,
          method: EncounterMethod.photo,
          occurredAt: DateTime(2027, 2, 10),
        ),
        StationCreated(station: station),
      ],
      photoSource: _Camera(photo),
      locationSampler: FakeLocationSampler(at: (latitude: 44.48001, longitude: 11.35, accuracy: 5)),
    );
    await pumpDruidApp(tester);
    await tester.tap(find.byKey(const ValueKey('nav-action')));
    await tester.pumpAndSettle();

    expect(find.text('Sei alla tua Stazione'), findsOneWidget);
    expect(find.text('Pronta'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('draw-s1')));
    await tester.pumpAndSettle();

    expect(find.text("Hai Attinto un'Essenza"), findsOneWidget);
    expect(find.byKey(const ValueKey('drawn-vis')), findsOneWidget);
    expect(Get.find<ProgressController>().state.lastStationDraws.keys, ['s1']);
  });
}
