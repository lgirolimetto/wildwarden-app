import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/business_logic/rules/study/xp_rules.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late InMemoryGameEventStore store;
  late FakeClock clock;
  late Catalog catalog;
  late ProgressController controller;

  setUp(() async {
    store = InMemoryGameEventStore();
    clock = FakeClock();
    catalog = smallCatalog();
    controller = ProgressController(store, clock, catalog: () => catalog);
    await controller.load();
  });

  test('all\'avvio ricostruisce lo stato dagli eventi salvati', () async {
    store.events.add(
      SpeciesEncountered(speciesSci: 'Fagus sylvatica', method: EncounterMethod.photo, occurredAt: clock.now()),
    );

    await controller.load();

    expect(controller.state.encounteredCount, 1);
  });

  test('un incontro viene salvato con l\'ora dell\'orologio e aggiorna lo stato', () async {
    await controller.encounter('Eranthis hyemalis', method: EncounterMethod.simulated);

    expect(controller.state.encounteredCount, 1);
    expect(store.events.single.occurredAt, clock.now());
  });

  test('se il salvataggio fallisce lo stato non cambia', () async {
    store.failAppendWith = 'disco pieno';

    final result = await controller.encounter('Eranthis hyemalis', method: EncounterMethod.simulated);

    expect(result.isValid, isFalse);
    expect(controller.state.encounteredCount, 0);
  });

  test('incontrare una desiderata compie la missione e dà PE', () async {
    await controller.toggleDesiderata('Eranthis hyemalis');
    await controller.encounter('Eranthis hyemalis', method: EncounterMethod.simulated);

    expect(controller.state.desiderata, isEmpty);
    expect(controller.state.fulfilledDesiderata, {'Eranthis hyemalis'});
    expect(controller.state.xp, XpRules.desiderataFulfilled);
  });

  test('attingere simulato salva tutti i tratti scelti', () async {
    await controller.encounter('Helleborus viridis', method: EncounterMethod.simulated);

    expect(await controller.drawSimulated('Helleborus viridis', traits: ['rain', 'dusk']), isTrue);

    expect(store.events.whereType<EssenceDrawn>().single.traits, ['rain', 'dusk']);
    expect(controller.state.draws['Helleborus viridis'], [
      ['rain', 'dusk'],
    ]);
  });

  test('non si possono avere più di 3 desiderata', () async {
    for (final sci in ['Eranthis hyemalis', 'Helleborus viridis', 'Malva sylvestris']) {
      expect(await controller.toggleDesiderata(sci), isTrue);
    }
    expect(await controller.toggleDesiderata('Fagus sylvatica'), isFalse);
    expect(controller.state.desiderata, hasLength(3));
  });

  test('curiosità del giorno: una sola per giorno', () async {
    await controller.encounter('Eranthis hyemalis', method: EncounterMethod.simulated);

    await controller.revealTodayFunFact();
    await controller.revealTodayFunFact();

    expect(store.events.whereType<FunFactRevealed>(), hasLength(1));
  });

  test('la nota uguale alla precedente non crea un nuovo evento', () async {
    await controller.saveNote('Eranthis hyemalis', 'sotto i noccioli');
    await controller.saveNote('Eranthis hyemalis', 'sotto i noccioli');

    expect(store.events.whereType<NoteSaved>(), hasLength(1));
    expect(controller.state.notes['Eranthis hyemalis'], 'sotto i noccioli');
  });

  test('simulare un Ricettario: Tavole di più piante e la prima Mitica, una volta sola', () async {
    final added = await controller.simulateRecipeBook();

    final learned = store.events.whereType<RecipeLearned>().toList();
    expect(added, learned.length);
    expect(learned.map((e) => e.recipeId), contains('lanterna-santa-lucia'));
    expect(collectedPages(catalog, controller.state), hasLength(4), reason: 'il catalogo di prova ha 4 piante');
    expect(collectedPages(catalog, controller.state).where((p) => p.complete), isNotEmpty);

    expect(await controller.simulateRecipeBook(), 0, reason: 'le Tavole già imparate non si ripetono');
  });

  test('simulare una Dispensa: Essenze di più piante nei giorni scorsi, con i tratti d\'elezione', () async {
    final drawn = await controller.simulatePantry();

    expect(controller.state.essences, hasLength(drawn));
    expect(controller.state.vis.keys, hasLength(4), reason: 'il catalogo di prova ha 4 piante');
    expect(controller.state.essences.every((e) => e.drawnAt.isBefore(clock.now())), isTrue);
    expect(controller.state.essences.any((e) => e.traits.isNotEmpty), isTrue);
  });

  test('azzerare cancella tutti i progressi', () async {
    await controller.encounter('Eranthis hyemalis', method: EncounterMethod.simulated);

    await controller.resetAll();

    expect(controller.state.encounteredCount, 0);
    expect(store.events, isEmpty);
  });
}
