import 'package:druid_app/business_logic/models/location_fix.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/controllers/field_test/field_test_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LocationFix fix(int ms, double accuracy) => LocationFix(
    elapsed: Duration(milliseconds: ms),
    latitude: 44.5,
    longitude: 11.3,
    accuracy: accuracy,
  );

  FieldTestRecord record({String expected = 'elleboro', Duration? photoTime = const Duration(seconds: 8)}) =>
      FieldTestRecord(
        at: DateTime(2026, 10, 28, 15),
        expected: expected,
        place: 'ombra, Giardini Margherita',
        photoTime: photoTime,
        photoKb: 412,
        identifyTime: const Duration(milliseconds: 2300),
        outcome: 'ok',
        candidates: const [
          PlantCandidate(scientificName: 'Helleborus foetidus', commonNames: ['Elleboro puzzolente'], score: 0.4),
          PlantCandidate(scientificName: 'Helleborus viridis', commonNames: ['Elleboro verde'], score: 0.3),
          PlantCandidate(scientificName: 'Hedera helix', commonNames: [], score: 0.1),
        ],
        remainingRequests: 480,
        locationOutcome: 'ok',
        fixes: [fix(2500, 40), fix(4000, 18), fix(9000, 9), fix(12000, 6), fix(19000, 4)],
      );

  test('precisione migliore entro un tempo: null prima della prima posizione', () {
    final r = record();
    expect(r.firstFix, const Duration(milliseconds: 2500));
    expect(r.accuracyWithin(const Duration(seconds: 2)), isNull);
    expect(r.accuracyWithin(const Duration(seconds: 5)), 18);
    expect(r.accuracyWithin(const Duration(seconds: 10)), 9);
    expect(r.accuracyWithin(const Duration(seconds: 20)), 4);
  });

  test('posizioni durante la foto e dopo il ritorno dalla fotocamera', () {
    final r = record();
    expect(r.fixesDuringPhoto, 2);
    expect(r.firstFixAfterPhoto, const Duration(seconds: 1));
    expect(r.accuracyAfterPhoto, 6); // 19 s è oltre 8 + 10 s
  });

  test('la pianta attesa si riconosce da un pezzo del nome scientifico o comune', () {
    expect(record(expected: 'elleboro verde').matchesWithin(1), isFalse);
    expect(record(expected: 'elleboro verde').matchesWithin(3), isTrue);
    expect(record(expected: 'Helleborus foetidus').matchesWithin(1), isTrue);
    expect(record(expected: ' ').matchesWithin(3), isNull);
  });

  test('riga del CSV: stesse colonne dell\'intestazione, virgolette dove servono', () {
    final row = record(expected: 'elleboro verde').toCsvRow();
    expect(row, contains('"ombra, Giardini Margherita"'));
    expect(row, contains('Helleborus foetidus,0.400'));
    expect(row, contains(',false,true,480,ok,2.5,18,9,4,2,1.0,6,5'));
    final columns = FieldTestRecord.header.split(',').length;
    expect(row.replaceAll('"ombra, Giardini Margherita"', 'x').split(',').length, columns);
  });

  test('foto annullata: niente tempi della foto né posizioni dopo', () {
    final r = record(photoTime: null);
    expect(r.fixesDuringPhoto, 0);
    expect(r.firstFixAfterPhoto, isNull);
    expect(r.toCsvRow().replaceAll('"ombra, Giardini Margherita"', 'x').split(',')[3], '');
  });
}
