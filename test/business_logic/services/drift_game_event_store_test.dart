import 'package:drift/native.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/services/persistence/drift_game_event_store.dart';
import 'package:druid_app/business_logic/services/persistence/druid_database.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test sul vero database SQLite (in memoria), non su un finto.
void main() {
  late DruidDatabase db;
  late DriftGameEventStore store;

  setUp(() {
    db = DruidDatabase(NativeDatabase.memory());
    store = DriftGameEventStore(db);
  });

  tearDown(() => db.close());

  SpeciesEncountered met(String sci, int day) =>
      SpeciesEncountered(speciesSci: sci, method: EncounterMethod.simulated, occurredAt: DateTime(2027, 2, day, 9));

  test('database vuoto: nessun evento', () async {
    final result = await store.loadAll();
    expect(result.fold((_) => null, (events) => events), isEmpty);
  });

  test('salva e rilegge gli eventi nell\'ordine di inserimento', () async {
    await store.append(met('Eranthis hyemalis', 14));
    await store.append(met('Helleborus viridis', 10));

    final events = (await store.loadAll()).fold((_) => <GameEvent>[], (e) => e);

    expect(events.map((e) => (e as SpeciesEncountered).speciesSci), ['Eranthis hyemalis', 'Helleborus viridis']);
    expect(events.first.occurredAt, DateTime(2027, 2, 14, 9));
  });

  test('una riga con tipo sconosciuto diventa un Fail, non un crash', () async {
    await db
        .into(db.gameEventRecords)
        .insert(
          GameEventRecordsCompanion.insert(type: 'futuro_sconosciuto', payload: '{}', occurredAt: DateTime(2027)),
        );

    final result = await store.loadAll();

    expect(result.isValid, isFalse);
  });

  test('un errore SQL diventa un Fail, non un\'eccezione', () async {
    await db.customStatement('DROP TABLE game_event_records');

    final result = await store.append(met('Eranthis hyemalis', 14));

    expect(result.isValid, isFalse);
  });
}
