import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'druid_database.g.dart';

/// Registro append-only degli eventi di gioco.
class GameEventRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `GameEvent.type`: identificatore stabile, mai rinominato.
  TextColumn get type => text()();

  /// Dati dell'evento in JSON.
  TextColumn get payload => text()();
  DateTimeColumn get occurredAt => dateTime()();
}

/// Database locale. Dopo ogni modifica alle tabelle:
/// `dart run build_runner build` e una migrazione in [migration] con `schemaVersion` incrementata.
@DriftDatabase(tables: [GameEventRecords])
class DruidDatabase extends _$DruidDatabase {
  DruidDatabase(super.executor);

  factory DruidDatabase.onDevice() => DruidDatabase(driftDatabase(name: 'druid'));

  @override
  int get schemaVersion => 1;
}
