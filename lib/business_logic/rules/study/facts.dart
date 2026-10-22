import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';

/// Livello di studio più alto raggiungibile con le domande. Il livello 4 (maestria) richiede ripassi e campo.
const maxStudyLevel = 3;

/// Tipi di fatto che si possono imparare su una specie, con il livello a cui appartengono.
///
/// ⚠️ Il nome di ogni valore finisce negli id salvati nel database (`Fact.id`): non si rinomina mai.
enum FactKind {
  appearance(1),
  name(1),
  family(2),
  relatives(2),
  season(3),
  altitude(3);

  const FactKind(this.level);

  final int level;
}

/// Qualcosa da imparare su una specie. Il fatto resta fisso; le domande che lo verificano cambiano forma.
class Fact {
  final Species species;
  final FactKind kind;

  const Fact(this.species, this.kind);

  String get id => idOf(species.sci, kind);

  int get level => kind.level;

  static String idOf(String speciesSci, FactKind kind) => '$speciesSci|${kind.name}';

  static ({String speciesSci, FactKind kind}) parseId(String id) {
    final separator = id.lastIndexOf('|');
    return (speciesSci: id.substring(0, separator), kind: FactKind.values.byName(id.substring(separator + 1)));
  }

  @override
  bool operator ==(Object other) => other is Fact && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Fact($id)';
}

/// Fatti verificabili per una specie: un fatto esiste solo se i dati sono abbastanza netti da farne una domanda
/// onesta (es. niente domanda sulla stagione se nessuna stagione prevale).
List<Fact> factsOf(Species species, Catalog catalog) => [
  if (species.images.isNotEmpty) Fact(species, FactKind.appearance),
  Fact(species, FactKind.name),
  Fact(species, FactKind.family),
  if (catalog.relativesOf(species).isNotEmpty) Fact(species, FactKind.relatives),
  if (species.dominantSeason != null) Fact(species, FactKind.season),
  if (species.dominantBand != null && species.elevationSamples >= 20) Fact(species, FactKind.altitude),
];

List<Fact> factsAtLevel(Species species, Catalog catalog, int level) =>
    factsOf(species, catalog).where((f) => f.level == level).toList();
