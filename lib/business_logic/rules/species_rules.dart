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

  /// Specie protetta nella zona, secondo le liste ufficiali (Direttiva Habitat, leggi regionali).
  bool get isProtected => protection.isNotEmpty;
}

/// Quanto è comune una specie nella zona, rispetto alle altre del catalogo (che sono già le più osservate).
enum Commonness { veryCommon, common, uncommon, rare }

/// Quartile della specie per numero di osservazioni nel catalogo: il primo quarto è "molto comune".
Commonness commonnessOf(Species species, Catalog catalog) {
  final ranked = catalog.species.map((s) => s.observations).toList()..sort((a, b) => b.compareTo(a));
  final rank = ranked.indexOf(species.observations);
  return Commonness.values[(rank * Commonness.values.length / ranked.length).floor()];
}

/// Quanta luce ama una specie, dall'indicatore EIVE (0-10).
enum LightPreference { shade, halfShade, sun }

/// Che terreno preferisce una specie, dall'indicatore di umidità EIVE (0-10).
enum MoisturePreference { dry, fresh, moist }

/// Soglie scelte sulla distribuzione delle specie di Bologna (luce 2,8-7,8; umidità 2,3-4,6): tre gruppi
/// abbastanza equilibrati e con un senso per chi cammina (sottobosco, margini, prati assolati).
LightPreference? lightPreferenceOf(Species s) => switch (s.traits.light) {
  null => null,
  < 4.5 => LightPreference.shade,
  < 6.5 => LightPreference.halfShade,
  _ => LightPreference.sun,
};

MoisturePreference? moisturePreferenceOf(Species s) => switch (s.traits.moisture) {
  null => null,
  < 3.5 => MoisturePreference.dry,
  < 5 => MoisturePreference.fresh,
  _ => MoisturePreference.moist,
};
