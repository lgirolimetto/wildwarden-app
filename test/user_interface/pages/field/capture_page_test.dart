import 'dart:io';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/interfaces/i_plant_identifier.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/location_fix.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../helpers/test_app.dart';

class _Camera implements IPhotoSource {
  final String path;
  _Camera(this.path);

  @override
  Future<Validation<TakenPhoto>> takePhoto() async => Valid(
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
    await scrollAndTap(tester, find.byKey(const ValueKey('open-capture')));
    await tester.pumpAndSettle();

    expect(find.text('Che pianta pensi che sia?'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('capture-guess')), 'Helleborus viridis');
    await tester.tap(find.byKey(const ValueKey('capture-guess-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Pl@ntNet pensa che sia:'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('capture-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Ci hai preso!'), findsOneWidget);
    expect(find.text('È nata una nuova stazione.'), findsOneWidget);
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
    await scrollAndTap(tester, find.byKey(const ValueKey('open-capture')));
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
    await scrollAndTap(tester, find.byKey(const ValueKey('open-capture')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Manca la chiave di Pl@ntNet'), findsOneWidget);
  });
}
