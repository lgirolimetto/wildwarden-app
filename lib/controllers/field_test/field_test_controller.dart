import 'dart:io';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_clock.dart';
import 'package:druid_app/business_logic/interfaces/i_field_test_log.dart';
import 'package:druid_app/business_logic/interfaces/i_location_sampler.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/interfaces/i_plant_identifier.dart';
import 'package:druid_app/business_logic/models/location_fix.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/controllers/field_test/field_test_record.dart';
import 'package:get/get.dart';

enum FieldTestPhase { idle, photo, identifying, locating }

/// Pagina "Prova sul campo" (step 0 del blocco 2, solo in sviluppo): misura foto, Pl@ntNet e GPS su piante vere e
/// salva ogni prova in una riga del CSV.
class FieldTestController extends GetxController {
  final IPhotoSource _camera;
  final IPlantIdentifier _identifier;
  final ILocationSampler _location;
  final IFieldTestLog _log;
  final IClock _clock;

  /// Durata della raccolta delle posizioni: almeno [minimumWindow] dal tocco e [afterPhoto] dopo la foto (corte nei
  /// test).
  final Duration minimumWindow;
  final Duration afterPhoto;

  FieldTestController(
    this._camera,
    this._identifier,
    this._location,
    this._log,
    this._clock, {
    this.minimumWindow = FieldTestRecord.minimumWindow,
    this.afterPhoto = FieldTestRecord.afterPhoto,
  });

  FieldTestPhase phase = FieldTestPhase.idle;
  FieldTestRecord? last;
  String? logPath;
  int rows = 0;

  bool get running => phase != FieldTestPhase.idle;

  @override
  void onInit() {
    super.onInit();
    _refreshLog();
  }

  Future<void> _refreshLog() async {
    logPath = await _log.location();
    final content = await _log.readAll();
    rows = content.isEmpty ? 0 : content.trim().split('\n').length - 1;
    update();
  }

  void _phase(FieldTestPhase value) {
    phase = value;
    update();
  }

  Future<void> run({required String expected, required String place}) async {
    if (running) return;
    final at = _clock.now();
    _phase(FieldTestPhase.photo);

    final recording = await _location.start();
    final watch = Stopwatch()..start();
    final photo = await _camera.takePhoto();
    final photoTime = watch.elapsed;

    var outcome = 'annullata';
    int? photoKb;
    Duration? identifyTime;
    var identification = PlantIdentification.none;
    final path = photo.fold((_) => null, (taken) => taken.path);
    if (!photo.isValid) {
      outcome = _message(photo);
    } else if (path != null) {
      photoKb = File(path).lengthSync() ~/ 1024;
      _phase(FieldTestPhase.identifying);
      final started = watch.elapsed;
      final result = await _identifier.identify(path);
      identifyTime = watch.elapsed - started;
      result.fold((_) => outcome = _message(result), (value) {
        identification = value;
        outcome = value.candidates.isEmpty ? 'nessuna' : 'ok';
      });
    }

    _phase(FieldTestPhase.locating);
    var fixes = const <LocationFix>[];
    if (recording.isValid) {
      final end = path != null ? photoTime + afterPhoto : Duration.zero;
      final until = end > minimumWindow ? end : minimumWindow;
      if (watch.elapsed < until) await Future<void>.delayed(until - watch.elapsed);
      fixes = await recording.fold((_) async => const <LocationFix>[], (r) => r.stop());
    }

    final record = FieldTestRecord(
      at: at,
      expected: expected,
      place: place,
      photoTime: path == null ? null : photoTime,
      photoKb: photoKb,
      identifyTime: identifyTime,
      outcome: outcome,
      candidates: identification.candidates,
      remainingRequests: identification.remainingRequests,
      locationOutcome: recording.isValid ? 'ok' : _message(recording),
      fixes: fixes,
    );
    await _log.append(FieldTestRecord.header, record.toCsvRow());
    last = record;
    phase = FieldTestPhase.idle;
    await _refreshLog();
  }

  Future<String> csv() => _log.readAll();

  Future<void> clearLog() async {
    await _log.clear();
    last = null;
    await _refreshLog();
  }

  static String _message(Validation<Object?> failed) => failed.fold(
    (failures) => failures.map((f) => f.message.isEmpty ? f.toString() : f.message).join('; '),
    (_) => '',
  );
}
