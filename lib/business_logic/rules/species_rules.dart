import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:druid_app/business_logic/models/species.dart';

/// Quota di osservazioni oltre la quale una stagione si considera "dominante".
const dominantSeasonShare = 0.40;

/// Quota di osservazioni oltre la quale una fascia di quota si considera "dominante".
const dominantBandShare = 0.55;

/// Indizio per una specie non ancora trovata. È solo dato: il testo lo compone la UI nella lingua dell'utente.
class SpeciesHint {
  final String family;
  final Season? season;
  final AltitudeBand? band;

  const SpeciesHint({required this.family, this.season, this.band});

  @override
  bool operator ==(Object other) =>
      other is SpeciesHint && other.family == family && other.season == season && other.band == band;

  @override
  int get hashCode => Object.hash(family, season, band);

  @override
  String toString() => 'SpeciesHint($family, $season, $band)';
}

extension SpeciesRules on Species {
  AltitudeBand get topBand => bandShare.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

  /// Stagione di picco, solo se abbastanza netta da essere un'informazione utile.
  Season? get dominantSeason => (seasonShare[peakSeason] ?? 0) >= dominantSeasonShare ? peakSeason : null;

  /// Fascia di quota prevalente, solo se abbastanza netta.
  AltitudeBand? get dominantBand => (bandShare[topBand] ?? 0) >= dominantBandShare ? topBand : null;

  /// I mesi (1-12) in cui la specie si osserva di più, in ordine di calendario: più utili di un lungo elenco.
  List<int> topMonths([int count = 3]) {
    final byWeight = List.generate(12, (i) => i + 1)
      ..sort((a, b) => monthsRelative[b - 1].compareTo(monthsRelative[a - 1]));
    return byWeight.take(count).toList()..sort();
  }

  SpeciesHint get hint => SpeciesHint(family: family, season: dominantSeason, band: dominantBand);

  /// Specie protetta. Provvisorio: il catalogo non ha ancora il dato (tappa B, step 5), quindi valgono le orchidee
  /// spontanee, protette in molte regioni.
  bool get isProtected => family == 'Orchidaceae';
}

/// Quanto è comune una specie nella zona, rispetto alle altre del catalogo (che sono già le più osservate).
enum Commonness { veryCommon, common, uncommon, rare }

/// Quartile della specie per numero di osservazioni nel catalogo: il primo quarto è "molto comune".
Commonness commonnessOf(Species species, Catalog catalog) {
  final ranked = catalog.species.map((s) => s.observations).toList()..sort((a, b) => b.compareTo(a));
  final rank = ranked.indexOf(species.observations);
  return Commonness.values[(rank * Commonness.values.length / ranked.length).floor()];
}
