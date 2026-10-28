import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/business_logic/rules/field/identification.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  final catalog = smallCatalog();

  PlantCandidate candidate(String sci, double score, {int? gbifKey}) =>
      PlantCandidate(scientificName: sci, commonNames: const [], score: score, gbifKey: gbifKey);

  group('specie del catalogo', () {
    test('per chiave GBIF, anche se Pl@ntNet usa un sinonimo', () {
      expect(
        catalogSpeciesOf(candidate('Helleborus occidentalis', 0.9, gbifKey: 3033108), catalog)?.sci,
        'Helleborus viridis',
      );
    });

    test('per genere e specie del nome, senza sottospecie', () {
      expect(catalogSpeciesOf(candidate('Malva sylvestris subsp. mauritiana', 0.9), catalog)?.sci, 'Malva sylvestris');
      expect(catalogSpeciesOf(candidate('Fagus sylvatica', 0.9, gbifKey: 1), catalog)?.sci, 'Fagus sylvatica');
    });

    test('fuori catalogo', () {
      expect(catalogSpeciesOf(candidate('Hedera helix', 0.9), catalog), isNull);
      expect(catalogSpeciesOf(candidate('Malva neglecta', 0.9), catalog), isNull);
    });

    test('nome binomiale: minuscolo, senza ibrido, sottospecie e varietà', () {
      expect(binomial('Mentha × piperita'), 'mentha piperita');
      expect(binomial('Helleborus  viridis var. x'), 'helleborus viridis');
    });
  });

  group('revisione di una foto', () {
    test('i primi 3 candidati, con la specie del catalogo dove c\'è', () {
      final review = reviewIdentification(
        PlantIdentification(
          candidates: [
            candidate('Helleborus viridis', 0.62),
            candidate('Helleborus foetidus', 0.2),
            candidate('Malva sylvestris', 0.1),
            candidate('Fagus sylvatica', 0.05),
          ],
        ),
        catalog,
      );
      expect(review.confident, isTrue);
      expect(review.choices.map((c) => c.candidate.scientificName), [
        'Helleborus viridis',
        'Helleborus foetidus',
        'Malva sylvestris',
      ]);
      expect(review.choices.map((c) => c.inCatalog), [true, false, true]);
    });

    test('sotto la soglia Pl@ntNet non è sicuro', () {
      final review = reviewIdentification(
        PlantIdentification(candidates: [candidate('Helleborus viridis', minimumScore - 0.01)]),
        catalog,
      );
      expect(review.confident, isFalse);
      expect(review.empty, isFalse);
    });

    test('nessuna specie riconosciuta', () {
      final review = reviewIdentification(PlantIdentification.none, catalog);
      expect(review.empty, isTrue);
      expect(review.confident, isFalse);
    });
  });
}
