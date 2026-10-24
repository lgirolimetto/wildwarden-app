import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/harvest.dart';
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

  test('ricetta imparata: andata e ritorno dal database e nello stato', () {
    final event = RecipeLearned(recipeId: 'pozione-prova-comune', origin: RecipeOrigin.study, occurredAt: feb);
    final decoded =
        GameEvent.decode(type: event.type, payload: event.encodePayload(), occurredAt: feb) as RecipeLearned;
    expect(decoded.recipeId, 'pozione-prova-comune');
    expect(decoded.origin, RecipeOrigin.study);
    expect(GameState.replay([event]).learnedRecipes, {'pozione-prova-comune'});
  });

  group('PE virtuali, incasso e Vis', () {
    const elleboro = 'Helleborus viridis';
    AnswerGiven answer(int xp, DateTime at) =>
        AnswerGiven(factId: '$elleboro|family', correct: true, mode: AnswerMode.learning, xp: xp, occurredAt: at);
    EssenceDrawn draw(DateTime at, {int vis = 10, int xp = 10}) =>
        EssenceDrawn(speciesSci: elleboro, simulated: true, vis: vis, xp: xp, occurredAt: at);

    test('lo studio di una specie mai attinta dà PE virtuali: non contano per la carriera', () {
      final state = GameState.replay([
        answer(10, feb),
        LevelPassed(speciesSci: elleboro, level: 1, xp: 20, occurredAt: feb),
      ]);
      expect(state.pendingXp, {elleboro: 30});
      expect(state.xpToCash, 30);
      expect(state.xp, 0);
    });

    test('la prima essenza incassa i PE virtuali della specie, più i PE della raccolta', () {
      final state = GameState.replay([met(elleboro, feb), answer(10, feb), answer(10, feb), draw(mar)]);
      expect(state.pendingXp, isEmpty);
      expect(state.xp, 20 + 10);
      expect(state.balance, state.xp);
      expect(state.vis[elleboro], 10);
    });

    test('dopo l\'incasso lo studio di quella specie dà PE reali', () {
      final state = GameState.replay([met(elleboro, feb), draw(feb), answer(10, mar)]);
      expect(state.xp, 10 + 10);
      expect(state.xpToCash, 0);
    });

    test('le desiderata trovate danno PE reali', () {
      final state = GameState.replay([DesiderataFulfilled(speciesSci: elleboro, xp: 15, occurredAt: feb)]);
      expect(state.xp, 15);
    });

    test('le Vis si sommano a ogni raccolta e si ricorda l\'ultima', () {
      final state = GameState.replay([met(elleboro, feb), draw(feb), draw(mar, vis: 7)]);
      expect(state.vis[elleboro], 17);
      expect(state.lastDraws[elleboro], mar);
    });

    test('un evento salvato prima dello step 4 (senza vis né xp) si rilegge con zero', () {
      final event =
          GameEvent.decode(
                type: EssenceDrawn.typeId,
                payload: '{"species":"$elleboro","trait":null,"simulated":true}',
                occurredAt: feb,
              )
              as EssenceDrawn;
      expect(event.vis, 0);
      expect(event.xp, 0);
    });
  });

  group('più tratti per essenza', () {
    const elleboro = 'Helleborus viridis';
    EssenceDrawn decode(String payload) =>
        GameEvent.decode(type: EssenceDrawn.typeId, payload: payload, occurredAt: feb) as EssenceDrawn;

    test('un\'essenza salva e rilegge tutti i suoi tratti', () {
      final event = EssenceDrawn(
        speciesSci: elleboro,
        traits: const ['rain', 'dusk', 'moon'],
        simulated: true,
        occurredAt: feb,
      );
      expect(decode(event.encodePayload()).traits, ['rain', 'dusk', 'moon']);
    });

    test('un evento salvato con un tratto solo si rilegge come lista di un elemento', () {
      expect(decode('{"species":"$elleboro","trait":"frost","simulated":true}').traits, ['frost']);
    });

    test('un evento salvato senza tratto si rilegge come lista vuota', () {
      expect(decode('{"species":"$elleboro","trait":null,"simulated":true}').traits, isEmpty);
    });

    test('lo stato ricorda i tratti di ogni essenza', () {
      final state = GameState.replay([
        met(elleboro, feb),
        EssenceDrawn(speciesSci: elleboro, traits: const ['rain', 'dusk'], simulated: true, occurredAt: feb),
        EssenceDrawn(speciesSci: elleboro, simulated: true, occurredAt: mar),
      ]);
      expect(state.draws[elleboro], [
        ['rain', 'dusk'],
        <String>[],
      ]);
    });
  });

  group('una raccolta al giorno', () {
    const elleboro = 'Helleborus viridis';
    final morning = DateTime(2027, 2, 14, 9), evening = DateTime(2027, 2, 14, 21), tomorrow = DateTime(2027, 2, 15, 8);

    test('serve l\'incontro (una stazione) e dopo una raccolta la specie è esaurita fino a domani', () {
      expect(canDraw(GameState.empty, elleboro, morning), isFalse);
      var state = GameState.replay([met(elleboro, morning)]);
      expect(canDraw(state, elleboro, morning), isTrue);

      state = state.apply(EssenceDrawn(speciesSci: elleboro, simulated: true, occurredAt: morning));
      expect(canDraw(state, elleboro, evening), isFalse);
      expect(isExhausted(state, elleboro, evening), isTrue);
      expect(canDraw(state, elleboro, tomorrow), isTrue);
      expect(isExhausted(state, elleboro, tomorrow), isFalse);
    });
  });
}
