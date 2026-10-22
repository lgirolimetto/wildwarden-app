import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
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

  test('azzerare cancella tutti i progressi', () async {
    await controller.encounter('Eranthis hyemalis', method: EncounterMethod.simulated);

    await controller.resetAll();

    expect(controller.state.encounteredCount, 0);
    expect(store.events, isEmpty);
  });
}
