// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'druid_database.dart';

// ignore_for_file: type=lint
class $GameEventRecordsTable extends GameEventRecords with TableInfo<$GameEventRecordsTable, GameEventRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameEventRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, payload, occurredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_event_records';
  @override
  VerificationContext validateIntegrity(Insertable<GameEventRecord> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta, payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(_occurredAtMeta, occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta));
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameEventRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameEventRecord(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      payload: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      occurredAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
    );
  }

  @override
  $GameEventRecordsTable createAlias(String alias) {
    return $GameEventRecordsTable(attachedDatabase, alias);
  }
}

class GameEventRecord extends DataClass implements Insertable<GameEventRecord> {
  final int id;

  /// `GameEvent.type`: identificatore stabile, mai rinominato.
  final String type;

  /// Dati dell'evento in JSON.
  final String payload;
  final DateTime occurredAt;
  const GameEventRecord({required this.id, required this.type, required this.payload, required this.occurredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['payload'] = Variable<String>(payload);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  GameEventRecordsCompanion toCompanion(bool nullToAbsent) {
    return GameEventRecordsCompanion(
      id: Value(id),
      type: Value(type),
      payload: Value(payload),
      occurredAt: Value(occurredAt),
    );
  }

  factory GameEventRecord.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameEventRecord(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      payload: serializer.fromJson<String>(json['payload']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'payload': serializer.toJson<String>(payload),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  GameEventRecord copyWith({int? id, String? type, String? payload, DateTime? occurredAt}) => GameEventRecord(
    id: id ?? this.id,
    type: type ?? this.type,
    payload: payload ?? this.payload,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  GameEventRecord copyWithCompanion(GameEventRecordsCompanion data) {
    return GameEventRecord(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      payload: data.payload.present ? data.payload.value : this.payload,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameEventRecord(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, payload, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameEventRecord &&
          other.id == this.id &&
          other.type == this.type &&
          other.payload == this.payload &&
          other.occurredAt == this.occurredAt);
}

class GameEventRecordsCompanion extends UpdateCompanion<GameEventRecord> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> payload;
  final Value<DateTime> occurredAt;
  const GameEventRecordsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.payload = const Value.absent(),
    this.occurredAt = const Value.absent(),
  });
  GameEventRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String payload,
    required DateTime occurredAt,
  }) : type = Value(type),
       payload = Value(payload),
       occurredAt = Value(occurredAt);
  static Insertable<GameEventRecord> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? payload,
    Expression<DateTime>? occurredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (payload != null) 'payload': payload,
      if (occurredAt != null) 'occurred_at': occurredAt,
    });
  }

  GameEventRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? payload,
    Value<DateTime>? occurredAt,
  }) {
    return GameEventRecordsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameEventRecordsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$DruidDatabase extends GeneratedDatabase {
  _$DruidDatabase(QueryExecutor e) : super(e);
  $DruidDatabaseManager get managers => $DruidDatabaseManager(this);
  late final $GameEventRecordsTable gameEventRecords = $GameEventRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [gameEventRecords];
}

typedef $$GameEventRecordsTableCreateCompanionBuilder =
    GameEventRecordsCompanion Function({
      Value<int> id,
      required String type,
      required String payload,
      required DateTime occurredAt,
    });
typedef $$GameEventRecordsTableUpdateCompanionBuilder =
    GameEventRecordsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> payload,
      Value<DateTime> occurredAt,
    });

class $$GameEventRecordsTableFilterComposer extends Composer<_$DruidDatabase, $GameEventRecordsTable> {
  $$GameEventRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnFilters(column));
}

class $$GameEventRecordsTableOrderingComposer extends Composer<_$DruidDatabase, $GameEventRecordsTable> {
  $$GameEventRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnOrderings(column));
}

class $$GameEventRecordsTableAnnotationComposer extends Composer<_$DruidDatabase, $GameEventRecordsTable> {
  $$GameEventRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type => $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payload => $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => column);
}

class $$GameEventRecordsTableTableManager
    extends
        RootTableManager<
          _$DruidDatabase,
          $GameEventRecordsTable,
          GameEventRecord,
          $$GameEventRecordsTableFilterComposer,
          $$GameEventRecordsTableOrderingComposer,
          $$GameEventRecordsTableAnnotationComposer,
          $$GameEventRecordsTableCreateCompanionBuilder,
          $$GameEventRecordsTableUpdateCompanionBuilder,
          (GameEventRecord, BaseReferences<_$DruidDatabase, $GameEventRecordsTable, GameEventRecord>),
          GameEventRecord,
          PrefetchHooks Function()
        > {
  $$GameEventRecordsTableTableManager(_$DruidDatabase db, $GameEventRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$GameEventRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$GameEventRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$GameEventRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
              }) => GameEventRecordsCompanion(id: id, type: type, payload: payload, occurredAt: occurredAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String payload,
                required DateTime occurredAt,
              }) => GameEventRecordsCompanion.insert(id: id, type: type, payload: payload, occurredAt: occurredAt),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameEventRecordsTable, GameEventRecord>(table),
                  BaseReferences<_$DruidDatabase, $GameEventRecordsTable, GameEventRecord>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameEventRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$DruidDatabase,
      $GameEventRecordsTable,
      GameEventRecord,
      $$GameEventRecordsTableFilterComposer,
      $$GameEventRecordsTableOrderingComposer,
      $$GameEventRecordsTableAnnotationComposer,
      $$GameEventRecordsTableCreateCompanionBuilder,
      $$GameEventRecordsTableUpdateCompanionBuilder,
      (GameEventRecord, BaseReferences<_$DruidDatabase, $GameEventRecordsTable, GameEventRecord>),
      GameEventRecord,
      PrefetchHooks Function()
    >;

class $DruidDatabaseManager {
  final _$DruidDatabase _db;
  $DruidDatabaseManager(this._db);
  $$GameEventRecordsTableTableManager get gameEventRecords =>
      $$GameEventRecordsTableTableManager(_db, _db.gameEventRecords);
}
