import 'package:druid_app/business_logic/interfaces/i_location_sampler.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_store.dart';
import 'package:druid_app/business_logic/interfaces/i_plant_identifier.dart';
import 'package:druid_app/business_logic/interfaces/i_weather_service.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/location_fix.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/rules/field/capture.dart';
import 'package:druid_app/business_logic/rules/field/station_state.dart';
import 'package:druid_app/business_logic/rules/field/stations.dart';
import 'package:druid_app/business_logic/rules/field/suspension.dart';
import 'package:druid_app/business_logic/rules/harvest.dart';
import 'package:druid_app/business_logic/services/location/quick_fix.dart';
import 'package:druid_app/business_logic/rules/tutorial.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:get/get.dart';

enum CapturePhase {
  /// Prima dello scatto.
  idle,

  /// Si cerca la posizione: sei a una tua Stazione? (blocco 3)
  locating,

  /// Sei alla tua Stazione (o a più Stazioni): si Attinge da lì, senza Pl@ntNet, o "È un'altra pianta".
  atStation,

  /// L'Essenza attinta alla Stazione.
  drawn,

  /// Manca la chiave di Pl@ntNet.
  noKey,

  /// Oggi è già nata una stazione nuova: si torna domani (lo si dice prima di chiamare Pl@ntNet).
  limitReached,
  shooting,

  /// "Che pianta pensi che sia?"
  guessing,
  identifying,

  /// I candidati: si conferma (o si sceglie se Pl@ntNet è indeciso).
  review,
  saving,
  done,

  /// Errore di rete o di Pl@ntNet: si può riprovare con le stesse foto.
  failed,

  /// Chi gioca ha chiuso la fotocamera senza scattare.
  cancelled,
}

/// Che ne è della stazione dopo lo scatto.
enum StationOutcome { created, existing, noPosition, limitReached }

/// Com'è andata: la pianta, l'ipotesi, i PE, la stazione.
class CaptureResult {
  final CaptureChoice choice;
  final GuessResult guess;
  final int xp;
  final StationOutcome station;
  final bool firstEncounter;

  /// La foto è la prima di una specie del catalogo: prende il posto di quella dell'Erbario, con il timbro.
  final bool firstPhoto;

  /// La foto ha dato subito un'Essenza: alla nascita della Stazione (un gesto solo, blocco 3) o, nel tutorial, anche
  /// senza Stazione.
  final bool essence;

  const CaptureResult({
    required this.choice,
    required this.guess,
    required this.xp,
    required this.station,
    required this.firstEncounter,
    this.firstPhoto = false,
    this.essence = false,
  });

  String get speciesSci => choice.species?.sci ?? choice.candidate.scientificName;
}

/// Il flusso della foto (step 3 del Campo): fotocamera dell'app (tre foto, Vis, tratti, posizione), ipotesi, Pl@ntNet
/// (prima la flora regionale, poi quella del mondo), scelta, incontro, stazione e PE. Della sessione resta solo la foto
/// della pianta intera di una stazione nuova (la tua foto con il timbro, step 4): le altre si cancellano con [discardPhotos].
class CaptureController extends GetxController {
  final ProgressController _progress;
  final IPhotoSource _camera;
  final IPlantIdentifier _identifier;
  final Catalog? Function() _catalog;
  final AppConfig _config;
  final IPhotoStore _photos;

  /// La posizione prima del mirino e il meteo per la raccolta sospesa (blocco 3): senza, solo il flusso della foto.
  final ILocationSampler? _location;
  final IWeatherService? _weather;

  CaptureController(
    this._progress,
    this._camera,
    this._identifier,
    this._catalog,
    this._config,
    this._photos, {
    ILocationSampler? location,
    IWeatherService? weather,
  }) : _location = location,
       _weather = weather;

  /// Le tue Stazioni qui, dalla più vicina.
  List<Station> here = const [];

  /// La raccolta è sospesa qui (temporale, grandine…).
  Suspension? suspension;

  /// L'Essenza attinta alla Stazione: quale Stazione, quante Vis.
  ({Station station, int vis})? drawn;

  /// La foto salvata nella stazione nuova: alla chiusura non si cancella.
  String? _kept;

  CapturePhase phase = CapturePhase.idle;
  TakenPhoto? photo;
  String? guess;
  CaptureReview? review;
  int selected = 0;
  CaptureResult? result;
  String? error;

  void _go(CapturePhase next) {
    phase = next;
    update();
  }

  /// Prima dove sei: alla tua Stazione si Attinge senza Pl@ntNet; altrove (o senza posizione) il flusso della foto.
  Future<void> start() async {
    if (_location case final location?) {
      _go(CapturePhase.locating);
      final fix = await quickFix(location);
      if (fix != null) {
        here = stationsHere(_progress.state, fix.latitude, fix.longitude);
        if (here.isNotEmpty) {
          suspension = await _suspensionAt(fix.latitude, fix.longitude);
          return _go(CapturePhase.atStation);
        }
      }
    }
    await _photoFlow();
  }

  /// "È un'altra pianta": il flusso della foto anche vicino a una tua Stazione.
  Future<void> otherPlant() => _photoFlow();

  Future<Suspension?> _suspensionAt(double latitude, double longitude) async {
    final forecast = await _weather?.forecast(latitude, longitude);
    return forecast?.fold((_) => null, (f) => suspensionAt(f, _progress.now));
  }

  /// Lo stato di una Stazione adesso (per la pagina).
  StationStatus statusOf(Station station) =>
      _catalog() == null ? StationStatus.ready : stationStatus(station, _catalog()!, _progress.state, _progress.now);

  DateTime? readyAtOf(Station station) =>
      _catalog() == null ? null : readyAt(station, _catalog()!, _progress.state, _progress.now);

  /// Si Attinge dalla Stazione: uno scatto solo, la Vis del mirino, niente Pl@ntNet.
  Future<void> drawAt(Station station) async {
    if (suspension != null || statusOf(station) != StationStatus.ready) return;
    _go(CapturePhase.shooting);
    final taken = (await _camera.takePhoto(single: true)).fold((_) => TakenPhoto.cancelled, (taken) => taken);
    if (taken.photos.isEmpty) return _go(CapturePhase.atStation);
    // La foto non resta: serve solo al gesto (la tua foto con il timbro è quella della prima Stazione).
    photo = taken;
    final vis = _visOf(station, taken);
    final ok = await _progress.drawAtStation(station, vis: vis, traits: [for (final t in taken.traits) t.name]);
    if (!ok) return _go(CapturePhase.atStation);
    drawn = (station: station, vis: _progress.state.essences.last.vis);
    _go(CapturePhase.drawn);
  }

  int _visOf(Station station, TakenPhoto taken) => visOfDraw(
    ring: taken.visGathered ?? 1,
    station: station,
    state: _progress.state,
    suspicious: taken.verified == false,
  );

  Future<void> _photoFlow() async {
    if (_config.plantNetApiKey.isEmpty) return _go(CapturePhase.noKey);
    // Durante il tutorial niente limite prima dello scatto: le aromatiche non contano per "una Stazione al giorno".
    final tutorial = tutorialStatus(_progress.state) == TutorialStatus.inProgress;
    if (!tutorial && !canCreateStation(_progress.state, _progress.now)) return _go(CapturePhase.limitReached);
    _go(CapturePhase.shooting);
    final taken = (await _camera.takePhoto()).fold((_) => TakenPhoto.cancelled, (taken) => taken);
    if (taken.photos.isEmpty) return _go(CapturePhase.cancelled);
    photo = taken;
    _go(CapturePhase.guessing);
  }

  /// L'ipotesi (null = "Non lo so"), poi Pl@ntNet.
  Future<void> submitGuess(String? value) async {
    guess = value?.trim().isEmpty ?? true ? null : value!.trim();
    await identify();
  }

  /// Prima la flora regionale; se non trova niente, quella del mondo (Ospiti).
  Future<void> identify() async {
    final taken = photo, catalog = _catalog();
    if (taken == null || catalog == null) return;
    _go(CapturePhase.identifying);
    final regional = await _identifier.identify(taken.photos, flora: PlantFlora.regional);
    final regionalResult = regional.fold((f) => null, (r) => r);
    if (regionalResult == null) return _fail(regional.fold((f) => f.map((x) => x.message).join('; '), (_) => ''));
    PlantIdentification? world;
    if (regionalResult.candidates.isEmpty) {
      final worldResponse = await _identifier.identify(taken.photos);
      world = worldResponse.fold((f) => null, (r) => r);
      if (world == null) return _fail(worldResponse.fold((f) => f.map((x) => x.message).join('; '), (_) => ''));
    }
    review = reviewCapture(regional: regionalResult, world: world, catalog: catalog, guess: guess);
    selected = review!.selected;
    _go(CapturePhase.review);
  }

  void _fail(String message) {
    error = message;
    _go(CapturePhase.failed);
  }

  void select(int index) {
    selected = index;
    update();
  }

  /// Conferma la pianta: incontro (la prima volta), stazione (nuova o la stessa) e PE.
  Future<void> confirm() async {
    final choices = review?.choices ?? const [];
    final taken = photo;
    if (choices.isEmpty || taken == null) return;
    _go(CapturePhase.saving);
    final choice = choices[selected];
    final state = _progress.state, now = _progress.now;
    final sci = choice.species?.sci ?? choice.candidate.scientificName;
    final guessResult = guessResultOf(guess, choice);
    final xp = captureXp(state, choice, guessResult);
    final first = !state.hasEncountered(sci);
    final hadPhoto = firstPhotoOf(state, sci) != null;
    final position = taken.position;
    // Regola del tutorial (capitolo 03): un'aromatica fa nascere la Stazione anche in casa, fuori dal limite del
    // giorno, e la foto dà subito l'Essenza.
    final tutorialRule =
        tutorialStatus(state) == TutorialStatus.inProgress && tutorialSpecies.contains(choice.species?.sci);

    final StationOutcome station;
    if (position == null) {
      station = StationOutcome.noPosition;
    } else if (sameStation(state, sci, position.latitude, position.longitude) != null) {
      station = StationOutcome.existing;
    } else if (!tutorialRule && !canCreateStation(state, now)) {
      station = StationOutcome.limitReached;
    } else {
      station = StationOutcome.created;
    }

    if (first) await _progress.encounter(sci, method: EncounterMethod.photo);
    if (station == StationOutcome.created) {
      await _progress.record(
        StationCreated(
          station: Station(
            // Univoco anche per due Stazioni nate nello stesso istante: lo stato di una Stazione va per id.
            id: '${now.microsecondsSinceEpoch}-${state.stations.length}',
            speciesSci: sci,
            kind: choice.kind,
            latitude: position!.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            confidence: choice.candidate.score,
            createdAt: now,
            photo: _keep(taken.path),
            traits: taken.traits,
            tutorial: tutorialRule,
            commonName: choice.species == null && choice.candidate.commonNames.isNotEmpty
                ? choice.candidate.commonNames.first
                : null,
            family: choice.species == null ? choice.candidate.family : null,
          ),
        ),
      );
    }
    if (xp > 0) await _progress.record(XpGranted(xp: xp, reason: 'capture', occurredAt: now));
    final essence = await _firstEssence(sci, station, position, taken, tutorialRule: tutorialRule);
    result = CaptureResult(
      choice: choice,
      guess: guessResult,
      xp: xp,
      station: station,
      firstEncounter: first,
      firstPhoto: station == StationOutcome.created && _kept != null && choice.species != null && !hadPhoto,
      essence: essence,
    );
    _go(CapturePhase.done);
  }

  /// Un gesto solo (capitolo 05): la foto che fa nascere la Stazione dà anche la prima Essenza, con la Vis del mirino;
  /// una foto alla tua Stazione pronta Attinge da lì. Nel tutorial anche senza Stazione (niente posizione). Niente
  /// Essenza con la raccolta sospesa.
  Future<bool> _firstEssence(
    String sci,
    StationOutcome outcome,
    LocationFix? position,
    TakenPhoto taken, {
    required bool tutorialRule,
  }) async {
    final traits = [for (final t in taken.traits) t.name];
    final state = _progress.state;
    final station = position == null
        ? null
        : switch (outcome) {
            StationOutcome.created => state.stations.last,
            StationOutcome.existing => sameStation(state, sci, position.latitude, position.longitude),
            _ => null,
          };
    if (station == null) return tutorialRule && await _progress.drawFromPhoto(sci, traits: traits);
    if (statusOf(station) != StationStatus.ready) return false;
    if (await _suspensionAt(station.latitude, station.longitude) != null) return false;
    // Nel tutorial la prima Essenza ha la Vis piena: le aromatiche di cucina stanno vicine (isolamento) e il basilico è
    // un'Ospite, ma la Comune si deve poter preparare.
    final vis = tutorialRule ? visPerDraw : _visOf(station, taken);
    return _progress.drawAtStation(station, vis: vis, traits: traits);
  }

  String? _keep(String? path) {
    _kept = path;
    return path == null ? null : _photos.relative(path);
  }

  /// Alla chiusura della pagina: cancella le foto della sessione tranne quella della stazione nuova.
  Future<void> discardPhotos() async {
    final leftovers = [
      for (final p in photo?.photos ?? const <PlantPhoto>[])
        if (p.path != _kept) p.path,
    ];
    if (leftovers.isNotEmpty) await _photos.delete(leftovers);
  }
}
