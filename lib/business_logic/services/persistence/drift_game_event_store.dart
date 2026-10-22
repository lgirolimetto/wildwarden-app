import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:drift/drift.dart';
import 'package:druid_app/business_logic/interfaces/i_game_event_store.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/services/persistence/druid_database.dart';

class DriftGameEventStore implements IGameEventStore {
  final DruidDatabase _db;

  DriftGameEventStore(this._db);

  @override
  Future<Validation<List<GameEvent>>> loadAll() =>
      (_db.select(_db.gameEventRecords)..orderBy([(e) => OrderingTerm.asc(e.id)])).get().tryCatch().bind(
        (rows) => Try(
          () => [
            for (final row in rows) GameEvent.decode(type: row.type, payload: row.payload, occurredAt: row.occurredAt),
          ],
        ),
      );

  @override
  Future<Validation<GameEvent>> append(GameEvent event) => _db
      .into(_db.gameEventRecords)
      .insert(
        GameEventRecordsCompanion.insert(
          type: event.type,
          payload: event.encodePayload(),
          occurredAt: event.occurredAt,
        ),
      )
      .then((_) => event)
      .tryCatch();

  @override
  Future<Validation<int>> clear() => _db.delete(_db.gameEventRecords).go().tryCatch();
}
