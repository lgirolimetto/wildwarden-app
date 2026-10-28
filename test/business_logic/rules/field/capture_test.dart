import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/rules/field/capture.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  final catalog = smallCatalog();

  PlantCandidate c(String sci, double score, {List<String> names = const []}) =>
      PlantCandidate(scientificName: sci, commonNames: names, score: score);
  PlantIdentification id(List<PlantCandidate> candidates) => PlantIdentification(candidates: candidates);

  group('revisione', () {
    test('prima la flora regionale: pianta della mappa o Scoperta', () {
      final review = reviewCapture(
        regional: id([c('Helleborus viridis', 0.62), c('Helleborus foetidus', 0.1)]),
        catalog: catalog,
      );
      expect(review.worldOnly, isFalse);
      expect(review.choices.map((x) => x.kind), [StationKind.zone, StationKind.discovery]);
      expect(review.choices.first.species?.sci, 'Helleborus viridis');
      expect((review.selected, review.needsChoice), (0, false));
    });

    test('niente nella flora regionale: si allarga al mondo e sono Ospiti', () {
      final review = reviewCapture(
        regional: PlantIdentification.none,
        world: id([
          c('Anthurium scherzerianum', 0.68, names: ['Anturio']),
        ]),
        catalog: catalog,
      );
      expect(review.worldOnly, isTrue);
      expect(review.choices.single.kind, StationKind.guest);
    });

    test('niente da nessuna parte', () {
      expect(reviewCapture(regional: PlantIdentification.none, catalog: catalog).empty, isTrue);
    });

    test('due candidati contesi: sceglie chi gioca, a meno che l\'ipotesi non sciolga', () {
      final regional = id([c('Euonymus fortunei', 0.45), c('Euonymus japonicus', 0.41)]);
      final open = reviewCapture(regional: regional, catalog: catalog);
      expect(open.needsChoice, isTrue);

      final solved = reviewCapture(regional: regional, catalog: catalog, guess: 'euonymus japonicus');
      expect((solved.selected, solved.needsChoice), (1, false));
    });

    test('l\'ipotesi sceglie solo tra i candidati con un punteggio minimo', () {
      final review = reviewCapture(
        regional: id([c('Salvia rosmarinus', 0.6), c('Salvia officinalis', 0.02)]),
        catalog: catalog,
        guess: 'Salvia officinalis',
      );
      expect(review.choices, hasLength(1), reason: 'sotto il 5 % non si propone');
      expect(review.selected, 0);
    });
  });

  group('ipotesi', () {
    final elleboro = reviewCapture(regional: id([c('Helleborus viridis', 0.7)]), catalog: catalog).choices.first;

    test('giusta per nome scientifico o comune, anche senza sottospecie', () {
      expect(guessResultOf('Helleborus viridis', elleboro), GuessResult.exact);
      expect(guessResultOf('elleboro verde', elleboro), GuessResult.exact);
      expect(guessResultOf('helleborus viridis subsp. occidentalis', elleboro), GuessResult.exact);
    });

    test('genere giusto, sbagliata, non data', () {
      expect(guessResultOf('Helleborus foetidus', elleboro), GuessResult.genus);
      expect(guessResultOf('malva', elleboro), GuessResult.wrong);
      expect(guessResultOf(null, elleboro), GuessResult.none);
      expect(guessResultOf('  ', elleboro), GuessResult.none);
    });
  });

  group('PE dello scatto', () {
    final elleboro = reviewCapture(regional: id([c('Helleborus viridis', 0.7)]), catalog: catalog).choices.first;
    final anturio = reviewCapture(
      regional: PlantIdentification.none,
      world: id([c('Anthurium scherzerianum', 0.7)]),
      catalog: catalog,
    ).choices.first;

    test('ipotesi giusta 20, genere 5, prima Ospite 10 in più', () {
      expect(captureXp(GameState.empty, elleboro, GuessResult.exact), guessExactXp);
      expect(captureXp(GameState.empty, elleboro, GuessResult.genus), guessGenusXp);
      expect(captureXp(GameState.empty, elleboro, GuessResult.none), 0);
      expect(captureXp(GameState.empty, anturio, GuessResult.none), guestDiscoveryXp);
      expect(captureXp(GameState.empty, anturio, GuessResult.exact), guessExactXp + guestDiscoveryXp);
    });

    test('solo la prima volta che si trova la specie', () {
      final met = GameState.replay([
        SpeciesEncountered(speciesSci: 'Helleborus viridis', method: EncounterMethod.photo, occurredAt: DateTime(2026)),
      ]);
      expect(captureXp(met, elleboro, GuessResult.exact), 0);
    });
  });
}
