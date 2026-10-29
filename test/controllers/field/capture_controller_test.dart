import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/interfaces/i_plant_identifier.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/location_fix.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/rules/field/capture.dart';
import 'package:druid_app/business_logic/rules/field/stations.dart';
import 'package:druid_app/business_logic/rules/tutorial.dart';
import 'package:druid_app/user_interface/pages/laboratory/ready_view.dart';
import 'package:druid_app/controllers/field/capture_controller.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

class _Camera implements IPhotoSource {
  TakenPhoto photo;
  _Camera(this.photo);

  @override
  Future<Validation<TakenPhoto>> takePhoto() async => Valid(photo);
}

class _Identifier implements IPlantIdentifier {
  final Map<PlantFlora, Validation<PlantIdentification>> answers;
  final calls = <PlantFlora>[];
  _Identifier(this.answers);

  @override
  Future<Validation<PlantIdentification>> identify(
    List<PlantPhoto> photos, {
    PlantFlora flora = PlantFlora.world,
  }) async {
    calls.add(flora);
    return answers[flora] ?? Valid(PlantIdentification.none);
  }
}

void main() {
  const config = AppConfig(flavor: 'test', plantNetApiKey: 'chiave', logHttp: false, showDebugTools: true);
  const here = LocationFix(elapsed: Duration.zero, latitude: 44.483, longitude: 11.353, accuracy: 4);
  const shot = TakenPhoto(
    photos: [PlantPhoto('/foto.jpg', PlantOrgan.whole), PlantPhoto('/foglia.jpg', PlantOrgan.leaf)],
    traits: [Trait.dawn, Trait.waxingMoon],
    position: here,
  );
  late InMemoryGameEventStore store;
  late FakeClock clock;
  late ProgressController progress;
  late FakePhotoStore photos;

  setUp(() async {
    photos = FakePhotoStore();
    store = InMemoryGameEventStore();
    clock = FakeClock(DateTime(2026, 10, 29, 10));
    progress = ProgressController(store, clock, catalog: smallCatalog);
    await progress.load();
  });

  PlantIdentification id(String sci, double score, {String? name, String? family}) => PlantIdentification(
    candidates: [
      PlantCandidate(scientificName: sci, commonNames: [?name], score: score, family: family),
    ],
  );

  CaptureController capture({
    TakenPhoto? photo,
    Map<PlantFlora, Validation<PlantIdentification>> answers = const {},
    AppConfig settings = config,
    Catalog? Function() catalog = smallCatalog,
  }) => CaptureController(progress, _Camera(photo ?? shot), _Identifier(answers), catalog, settings, photos);

  test('senza chiave non si apre la fotocamera', () async {
    final c = capture(
      settings: const AppConfig(flavor: 't', plantNetApiKey: '', logHttp: false, showDebugTools: true),
    );
    await c.start();
    expect(c.phase, CapturePhase.noKey);
  });

  test('una stazione nuova al giorno: lo si dice prima di Pl@ntNet', () async {
    final c = capture(answers: {PlantFlora.regional: Valid(id('Helleborus viridis', 0.7))});
    await c.start();
    await c.submitGuess(null);
    await c.confirm();
    expect(c.result!.station, StationOutcome.created);

    final again = capture();
    await again.start();
    expect(again.phase, CapturePhase.limitReached);
  });

  test('fotocamera chiusa senza scattare', () async {
    final c = capture(photo: TakenPhoto.cancelled);
    await c.start();
    expect(c.phase, CapturePhase.cancelled);
  });

  test('pianta della mappa con l\'ipotesi giusta: incontro, stazione, PE bonus', () async {
    final c = capture(answers: {PlantFlora.regional: Valid(id('Helleborus viridis', 0.7))});
    await c.start();
    expect(c.phase, CapturePhase.guessing);
    await c.submitGuess('elleboro verde');
    expect(c.phase, CapturePhase.review);
    await c.confirm();

    final result = c.result!;
    expect(result.guess, GuessResult.exact);
    expect(result.xp, guessExactXp);
    expect(result.firstEncounter, isTrue);
    final state = progress.state;
    expect(state.hasEncountered('Helleborus viridis'), isTrue);
    expect(state.stations.single.kind, StationKind.zone);
    expect(state.stations.single.confidence, 0.7);
    expect(state.xp, guessExactXp);
  });

  test('niente nella flora regionale: si chiede al mondo, è un\'Ospite con la sua famiglia', () async {
    final identifier = {
      PlantFlora.regional: Valid(PlantIdentification.none),
      PlantFlora.world: Valid(id('Anthurium scherzerianum', 0.68, name: 'Anturio', family: 'Araceae')),
    };
    final c = capture(answers: identifier);
    await c.start();
    await c.submitGuess(null);
    expect(c.review!.worldOnly, isTrue);
    await c.confirm();

    final station = progress.state.stations.single;
    expect((station.kind, station.commonName, station.family), (StationKind.guest, 'Anturio', 'Araceae'));
    expect(c.result!.xp, guestDiscoveryXp);
  });

  test('stessa specie entro 20 metri: è la stessa stazione, niente PE la seconda volta', () async {
    final answers = {PlantFlora.regional: Valid(id('Helleborus viridis', 0.7))};
    final first = capture(answers: answers);
    await first.start();
    await first.submitGuess('Helleborus viridis');
    await first.confirm();

    clock.current = clock.current.add(const Duration(days: 1));
    final second = capture(answers: answers);
    await second.start();
    await second.submitGuess('Helleborus viridis');
    await second.confirm();
    expect(second.result!.station, StationOutcome.existing);
    expect(second.result!.xp, 0);
    expect(progress.state.stations, hasLength(1));
  });

  test('senza posizione l\'incontro vale, la stazione no', () async {
    final c = capture(
      photo: const TakenPhoto(photos: [PlantPhoto('/foto.jpg', PlantOrgan.whole)]),
      answers: {PlantFlora.regional: Valid(id('Malva sylvestris', 0.8))},
    );
    await c.start();
    await c.submitGuess(null);
    await c.confirm();
    expect(c.result!.station, StationOutcome.noPosition);
    expect(progress.state.hasEncountered('Malva sylvestris'), isTrue);
    expect(progress.state.stations, isEmpty);
  });

  test('errore di Pl@ntNet: si può riprovare con le stesse foto', () async {
    final answers = <PlantFlora, Validation<PlantIdentification>>{
      PlantFlora.regional: Fail.withError(StateError('rete'), message: 'Connessione assente').toInvalid(),
    };
    final c = capture(answers: answers);
    await c.start();
    await c.submitGuess(null);
    expect((c.phase, c.error), (CapturePhase.failed, 'Connessione assente'));

    answers[PlantFlora.regional] = Valid(id('Malva sylvestris', 0.8));
    await c.identify();
    expect(c.phase, CapturePhase.review);
  });

  group('la tua foto con il timbro', () {
    test('la Stazione nuova tiene la foto della pianta intera e i tratti; le altre foto si cancellano', () async {
      final c = capture(answers: {PlantFlora.regional: Valid(id('Helleborus viridis', 0.7))});
      await c.start();
      await c.submitGuess(null);
      await c.confirm();

      final station = progress.state.stations.single;
      expect(station.photo, '/foto.jpg');
      expect(station.traits, [Trait.dawn, Trait.waxingMoon]);
      expect(firstPhotoOf(progress.state, 'Helleborus viridis'), station);
      expect(c.result!.firstPhoto, isTrue);

      await c.discardPhotos();
      expect(photos.deleted, ['/foglia.jpg']);
    });

    test('senza Stazione nuova non resta nessuna foto', () async {
      final c = capture(
        photo: const TakenPhoto(photos: [PlantPhoto('/foto.jpg', PlantOrgan.whole)]),
        answers: {PlantFlora.regional: Valid(id('Helleborus viridis', 0.7))},
      );
      await c.start();
      await c.submitGuess(null);
      await c.confirm();

      expect(c.result!.station, StationOutcome.noPosition);
      expect(c.result!.firstPhoto, isFalse);
      await c.discardPhotos();
      expect(photos.deleted, ['/foto.jpg']);
    });

    test('chiusa prima della conferma: si cancellano tutte', () async {
      final c = capture(answers: {PlantFlora.regional: Valid(id('Helleborus viridis', 0.7))});
      await c.start();
      await c.discardPhotos();
      expect(photos.deleted, ['/foto.jpg', '/foglia.jpg']);
    });

    test('la seconda Stazione della specie non cambia la foto', () async {
      final first = capture(answers: {PlantFlora.regional: Valid(id('Helleborus viridis', 0.7))});
      await first.start();
      await first.submitGuess(null);
      await first.confirm();

      clock.advance(const Duration(days: 1));
      const far = LocationFix(elapsed: Duration.zero, latitude: 44.49, longitude: 11.36, accuracy: 6);
      final second = capture(
        photo: const TakenPhoto(photos: [PlantPhoto('/altra.jpg', PlantOrgan.whole)], position: far),
        answers: {PlantFlora.regional: Valid(id('Helleborus viridis', 0.7))},
      );
      await second.start();
      await second.submitGuess(null);
      await second.confirm();

      expect(progress.state.stations, hasLength(2));
      expect(second.result!.firstPhoto, isFalse);
      expect(firstPhotoOf(progress.state, 'Helleborus viridis')!.photo, '/foto.jpg');
    });
  });

  group('regola del tutorial', () {
    Catalog withKitchen() => smallCatalog(kitchen: true);

    setUp(() async {
      progress = ProgressController(store, clock, catalog: withKitchen);
      await progress.load();
      await progress.markOnboarding(OnboardingMark.tutorialStarted);
    });

    Future<CaptureController> shoot(PlantIdentification regional, {PlantIdentification? world, LocationFix? at}) async {
      final c = capture(
        catalog: withKitchen,
        photo: TakenPhoto(
          photos: const [PlantPhoto('/foto.jpg', PlantOrgan.whole)],
          traits: const [Trait.dawn],
          position: at ?? here,
        ),
        answers: {PlantFlora.regional: Valid(regional), PlantFlora.world: Valid(world ?? PlantIdentification.none)},
      );
      await c.start();
      await c.submitGuess(null);
      await c.confirm();
      return c;
    }

    test("il rosmarino (anche con il vecchio nome): Incontro, Stazione in casa e subito l'Essenza", () async {
      final c = await shoot(id('Rosmarinus officinalis', 0.8));

      expect(c.result!.choice.species?.sci, 'Salvia rosmarinus');
      expect(c.result!.essence, isTrue);
      final state = progress.state;
      expect(state.stations.single.tutorial, isTrue);
      expect(state.essences.single.speciesSci, 'Salvia rosmarinus');
      expect(state.essences.single.traits, ['dawn']);
      expect(canCreateStation(state, clock.now()), isTrue, reason: 'le Stazioni del tutorial non contano');
      expect(currentTutorialStep(state), TutorialStep.study);
    });

    test("il basilico è un'Ospite anche se il catalogo lo conosce, e dà la sua Essenza", () async {
      final c = await shoot(PlantIdentification.none, world: id('Ocimum basilicum', 0.7, name: 'Basilico'));

      expect(c.result!.choice.kind, StationKind.guest);
      expect(c.result!.essence, isTrue);
      expect(progress.state.essences.single.speciesSci, 'Ocimum basilicum');
    });

    test('durante il tutorial il limite del giorno non ferma la fotocamera', () async {
      await shoot(id('Salvia officinalis', 0.8));
      final second = capture(catalog: withKitchen);
      await second.start();
      expect(second.phase, CapturePhase.guessing);
    });

    test('una pianta della Zona durante il tutorial segue le regole normali: niente Essenza', () async {
      final c = await shoot(id('Helleborus viridis', 0.7));
      expect(c.result!.essence, isFalse);
      expect(progress.state.stations.single.tutorial, isFalse);
      expect(progress.state.essences, isEmpty);
    });

    test('due aromatiche e il Livello 1 della prima: la Comune è pronta da preparare', () async {
      await shoot(id('Salvia rosmarinus', 0.8));
      await progress.record(LevelPassed(speciesSci: 'Salvia rosmarinus', level: 1, xp: 20, occurredAt: clock.now()));
      const kitchen = LocationFix(elapsed: Duration.zero, latitude: 44.4831, longitude: 11.3531, accuracy: 8);
      await shoot(PlantIdentification.none, world: id('Ocimum basilicum', 0.7), at: kitchen);

      final state = progress.state;
      expect(currentTutorialStep(state), TutorialStep.brew);
      final ready = readyRecipes(withKitchen(), state, clock.now()).where((r) => r.ready);
      expect(ready.map((r) => r.brewable.id), hasLength(1));
    });
  });
}
