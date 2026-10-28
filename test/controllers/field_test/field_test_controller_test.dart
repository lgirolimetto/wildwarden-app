import 'dart:io';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_location_sampler.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/interfaces/i_plant_identifier.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/controllers/field_test/field_test_controller.dart';
import 'package:druid_app/controllers/field_test/field_test_record.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

class _Camera implements IPhotoSource {
  final TakenPhoto result;
  _Camera(this.result);

  @override
  Future<Validation<TakenPhoto>> takePhoto() async => Valid(result);
}

class _Identifier implements IPlantIdentifier {
  int calls = 0;

  @override
  Future<Validation<PlantIdentification>> identify(String photoPath) async {
    calls++;
    return Valid(
      const PlantIdentification(
        candidates: [
          PlantCandidate(scientificName: 'Helleborus viridis', commonNames: ['Elleboro verde'], score: 0.8),
        ],
        remainingRequests: 499,
      ),
    );
  }
}

class _Location implements ILocationSampler {
  final bool allowed;
  bool stopped = false;
  _Location({this.allowed = true});

  @override
  Future<Validation<LocationRecording>> start() async {
    if (!allowed) return Fail.withError(StateError('negato'), message: 'Permesso della posizione negato').toInvalid();
    return Valid(LocationRecording(() async => stopped = true)..add(latitude: 44.5, longitude: 11.3, accuracy: 12));
  }
}

void main() {
  late String photo;
  late _Identifier identifier;
  late InMemoryFieldTestLog log;

  setUp(() async {
    photo = '${(await Directory.systemTemp.createTemp('campo')).path}/foto.jpg';
    File(photo).writeAsBytesSync(List.filled(3000, 0));
    identifier = _Identifier();
    log = InMemoryFieldTestLog();
  });

  FieldTestController controller(_Camera camera, _Location location, {_Camera? system}) => FieldTestController(
    camera,
    identifier,
    location,
    log,
    FakeClock(DateTime(2026, 10, 28, 15)),
    systemCamera: system,
    minimumWindow: Duration.zero,
    afterPhoto: Duration.zero,
  )..onInit();

  test('una prova: foto, Pl@ntNet e posizioni in una riga del CSV', () async {
    final location = _Location();
    final c = controller(_Camera(TakenPhoto(photo)), location);

    await c.run(expected: 'elleboro', place: 'sole');

    expect(identifier.calls, 1);
    expect(location.stopped, isTrue);
    expect(c.running, isFalse);
    expect(c.rows, 1);
    expect(log.header, FieldTestRecord.header);
    final last = c.last!;
    expect(last.outcome, 'ok');
    expect(last.photoKb, 2);
    expect(last.matchesWithin(1), isTrue);
    expect(last.remainingRequests, 499);
    expect(last.fixes.single.accuracy, 12);
  });

  test('foto annullata: niente Pl@ntNet, la prova si salva lo stesso con il GPS', () async {
    final c = controller(_Camera(TakenPhoto.cancelled), _Location());

    await c.run(expected: '', place: '');

    expect(identifier.calls, 0);
    expect(c.last!.outcome, 'annullata');
    expect(c.last!.fixes, hasLength(1));
    expect(c.rows, 1);
  });

  test('posizione negata: si misura solo la foto e il CSV dice perché', () async {
    final c = controller(_Camera(TakenPhoto(photo)), _Location(allowed: false));

    await c.run(expected: 'elleboro', place: '');

    expect(c.last!.locationOutcome, 'Permesso della posizione negato');
    expect(c.last!.fixes, isEmpty);
    expect(c.last!.outcome, 'ok');
  });

  test('cancellare le prove svuota il registro', () async {
    final c = controller(_Camera(TakenPhoto(photo)), _Location());
    await c.run(expected: '', place: '');

    await c.clearLog();

    expect(c.rows, 0);
    expect(c.last, isNull);
  });

  test('fotocamera dell\'app o di sistema, e le misure dello streaming nel CSV', () async {
    const diagnostics = CameraDiagnostics(
      receivedPerSecond: 30,
      analyzedPerSecond: 9.5,
      analysisMs: 3.2,
      captureMs: 410,
      resizeMs: 880,
      zoom: 2,
      flash: 'auto',
    );
    final app = _Camera(TakenPhoto(photo, diagnostics: diagnostics, visFull: true));
    final system = _Camera(TakenPhoto(photo));
    final c = controller(app, _Location(), system: system);

    await c.run(expected: '', place: '');
    expect(c.last!.systemCamera, isFalse);
    expect(c.last!.toCsvRow(), endsWith(',app,30.0,9.5,3.2,410,880,2.0,auto,piena,Elleboro verde'));

    c.setSystemCamera(true);
    await c.run(expected: '', place: '');
    expect(c.last!.systemCamera, isTrue);
    expect(c.last!.toCsvRow(), endsWith(',sistema,,,,,,,,,Elleboro verde'));
  });

  test('senza fotocamera di sistema l\'interruttore resta spento', () {
    final c = controller(_Camera(TakenPhoto(photo)), _Location());
    c.setSystemCamera(true);
    expect(c.useSystemCamera, isFalse);
  });
}
