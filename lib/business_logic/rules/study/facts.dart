import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';

/// Livello di studio più alto raggiungibile con le domande. Il livello 4 (maestria) richiede ripassi e campo.
const maxStudyLevel = 3;

/// Tipi di fatto che si possono imparare su una specie, con il livello a cui appartengono: 1 riconoscerla,
/// 2 famiglia e vita, 3 il suo ambiente (decisioni nel capitolo 03, "Domande che fanno imparare").
///
/// I fatti vengono solo da dati strutturati e automatici: GBIF (foto, tassonomia, quote, osservazioni), WCVP
/// (forma, ciclo, origine), EIVE (luce, umidità), EuDiS (semi).
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

  /// Ritirato: la tossicità non è un tema dello studio (decisione del 2026-10-23).
  toxicity(null),
  commonness(3),
  growthForm(1),
  lifeCycle(2),
  seedDispersal(2),
  origin(3),
  light(3),
  moisture(3);

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
List<Fact> factsOf(Species species, Catalog catalog) {
  final traits = species.traits;
  return [
    if (species.images.isNotEmpty) Fact(species, FactKind.appearance),
    Fact(species, FactKind.scientificName),
    if (traits.growthForm != null) Fact(species, FactKind.growthForm),
    Fact(species, FactKind.family),
    if (species.order != null) Fact(species, FactKind.order),
    if (catalog.relativesOf(species).isNotEmpty) Fact(species, FactKind.relatives),
    if (traits.lifeCycle != null) Fact(species, FactKind.lifeCycle),
    if (traits.dispersal.isNotEmpty) Fact(species, FactKind.seedDispersal),
    if (species.dominantBand != null && species.elevationSamples >= 20) Fact(species, FactKind.altitude),
    Fact(species, FactKind.commonness),
    if (traits.introducedInItaly != null) Fact(species, FactKind.origin),
    if (traits.light != null) Fact(species, FactKind.light),
    if (traits.moisture != null) Fact(species, FactKind.moisture),
  ];
}

List<Fact> factsAtLevel(Species species, Catalog catalog, int level) =>
    factsOf(species, catalog).where((f) => f.level == level).toList();
