import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

SpeciesEncountered met(String sci, DateTime at) =>
    SpeciesEncountered(speciesSci: sci, method: EncounterMethod.simulated, occurredAt: at);

void main() {
  final feb = DateTime(2027, 2, 14), mar = DateTime(2027, 3, 1);

  test('stato vuoto senza eventi', () {
    expect(GameState.replay([]).encounteredCount, 0);
  });

  test('ogni incontro aggiunge la specie', () {
    final state = GameState.replay([met('Eranthis hyemalis', feb), met('Helleborus viridis', mar)]);

    expect(state.encounteredCount, 2);
    expect(state.hasEncountered('Helleborus viridis'), isTrue);
    expect(state.hasEncountered('Fagus sylvatica'), isFalse);
  });

  test('incontrare di nuovo una specie non cambia la data del primo incontro', () {
    final state = GameState.replay([met('Eranthis hyemalis', feb), met('Eranthis hyemalis', mar)]);

    expect(state.encounteredCount, 1);
    expect(state.firstEncounters['Eranthis hyemalis'], feb);
  });

  test('rileggere gli stessi eventi dà lo stesso stato', () {
    final events = [met('Eranthis hyemalis', feb), met('Helleborus viridis', mar)];

    expect(GameState.replay(events).firstEncounters, GameState.replay(events).firstEncounters);
  });

  group('GameEvent: formato salvato', () {
    test('andata e ritorno dal database', () {
      final original = SpeciesEncountered(
        speciesSci: 'Fagus sylvatica',
        method: EncounterMethod.guide,
        occurredAt: feb,
      );

      final decoded = GameEvent.decode(type: original.type, payload: original.encodePayload(), occurredAt: feb);

      expect(decoded, isA<SpeciesEncountered>());
      decoded as SpeciesEncountered;
      expect(decoded.speciesSci, 'Fagus sylvatica');
      expect(decoded.method, EncounterMethod.guide);
    });

    test('il tipo salvato non cambia (rinominarlo renderebbe illeggibili i dati già salvati)', () {
      expect(SpeciesEncountered.typeId, 'species_encountered');
    });

    test('un tipo sconosciuto viene rifiutato', () {
      expect(() => GameEvent.decode(type: 'boh', payload: '{}', occurredAt: feb), throwsFormatException);
    });
  });
}
