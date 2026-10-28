import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/interfaces/i_plant_identifier.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/rules/field/capture.dart';
import 'package:druid_app/business_logic/rules/field/stations.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:get/get.dart';

enum CapturePhase {
  /// Prima dello scatto.
  idle,

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

  const CaptureResult({
    required this.choice,
    required this.guess,
    required this.xp,
    required this.station,
    required this.firstEncounter,
  });

  String get speciesSci => choice.species?.sci ?? choice.candidate.scientificName;
}

/// Il flusso della foto (step 3 del Campo): fotocamera dell'app (tre foto, Vis, tratti, posizione), ipotesi, Pl@ntNet
/// (prima la flora regionale, poi quella del mondo), scelta, incontro, stazione e PE.
class CaptureController extends GetxController {
  final ProgressController _progress;
  final IPhotoSource _camera;
  final IPlantIdentifier _identifier;
  final Catalog? Function() _catalog;
  final AppConfig _config;

  CaptureController(this._progress, this._camera, this._identifier, this._catalog, this._config);

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

  Future<void> start() async {
    if (_config.plantNetApiKey.isEmpty) return _go(CapturePhase.noKey);
    if (!canCreateStation(_progress.state, _progress.now)) return _go(CapturePhase.limitReached);
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
    final position = taken.position;

    final StationOutcome station;
    if (position == null) {
      station = StationOutcome.noPosition;
    } else if (sameStation(state, sci, position.latitude, position.longitude) != null) {
      station = StationOutcome.existing;
    } else if (!canCreateStation(state, now)) {
      station = StationOutcome.limitReached;
    } else {
      station = StationOutcome.created;
    }

    if (first) await _progress.encounter(sci, method: EncounterMethod.photo);
    if (station == StationOutcome.created) {
      await _progress.record(
        StationCreated(
          station: Station(
            id: '${now.microsecondsSinceEpoch}',
            speciesSci: sci,
            kind: choice.kind,
            latitude: position!.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            confidence: choice.candidate.score,
            createdAt: now,
            commonName: choice.species == null && choice.candidate.commonNames.isNotEmpty
                ? choice.candidate.commonNames.first
                : null,
            family: choice.species == null ? choice.candidate.family : null,
          ),
        ),
      );
    }
    if (xp > 0) await _progress.record(XpGranted(xp: xp, reason: 'capture', occurredAt: now));
    result = CaptureResult(choice: choice, guess: guessResult, xp: xp, station: station, firstEncounter: first);
    _go(CapturePhase.done);
  }
}
