import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';

/// Livello di studio più alto raggiungibile con le domande. Il livello 4 (maestria) richiede ripassi e campo.
const maxStudyLevel = 3;

/// Tipi di fatto che si possono imparare su una specie, con il livello a cui appartengono: 1 riconoscerla,
/// 2 la sua famiglia, 3 lei e noi (decisioni nel capitolo 03, "Domande che fanno imparare").
///
/// ⚠️ Il nome di ogni valore finisce negli id salvati nel database (`Fact.id`): non si rinomina né si toglie mai.
/// Un fatto che non si chiede più resta con `level == null` ("ritirato").
enum FactKind {
  appearance(1),

  /// Ritirato: il nome comune è nel titolo della sessione e nell'erbario, chiederlo è banale.
  name(null),
  family(2),
  relatives(2),

  /// Ritirato: la stagione è già un filtro ("In stagione adesso").
  season(null),
  altitude(3),
  scientificName(1),
  order(2),
  toxicity(3),
  commonness(3);

  const FactKind(this.level);

  /// `null` se il fatto è ritirato.
  final int? level;

  bool get retired => level == null;
}

/// Qualcosa da imparare su una specie. Il fatto resta fisso; le domande che lo verificano cambiano forma.
class Fact {
  final Species species;
  final FactKind kind;

  const Fact(this.species, this.kind);

  String get id => idOf(species.sci, kind);

  int? get level => kind.level;

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
  Fact(species, FactKind.scientificName),
  Fact(species, FactKind.family),
  if (species.order != null) Fact(species, FactKind.order),
  if (catalog.relativesOf(species).isNotEmpty) Fact(species, FactKind.relatives),
  if (species.dominantBand != null && species.elevationSamples >= 20) Fact(species, FactKind.altitude),
  // Solo dove il dato c'è: una specie senza avviso non è per forza innocua, quindi non si chiede "è tossica?" a
  // chi non ha il dato.
  if (catalog.safety.containsKey(species.sci)) Fact(species, FactKind.toxicity),
  Fact(species, FactKind.commonness),
];

List<Fact> factsAtLevel(Species species, Catalog catalog, int level) =>
    factsOf(species, catalog).where((f) => f.level == level).toList();
