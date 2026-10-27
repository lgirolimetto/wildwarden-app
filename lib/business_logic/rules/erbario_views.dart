import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/models/species_traits.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';

/// Stato di una specie per il giocatore, come criterio di una vista dell'erbario.
///
/// ⚠️ Il nome di ogni valore è salvato nelle viste dell'utente: non si rinomina.
enum SpeciesStatus { met, toFind, desiderata, studying }

/// Filtro di una vista dell'erbario: una specie passa se soddisfa **tutti** i criteri impostati; dentro un criterio
/// basta uno dei valori scelti (es. collina **o** montagna). Un criterio vuoto non filtra.
class ErbarioFilter {
  final Set<SpeciesStatus> statuses;
  final bool inSeason;
  final Set<AltitudeBand> bands;
  final Set<GrowthForm> forms;
  final bool protectedOnly;
  final Set<String> families;

  const ErbarioFilter({
    this.statuses = const {},
    this.inSeason = false,
    this.bands = const {},
    this.forms = const {},
    this.protectedOnly = false,
    this.families = const {},
  });

  static const all = ErbarioFilter();

  bool get isEmpty =>
      statuses.isEmpty && !inSeason && bands.isEmpty && forms.isEmpty && !protectedOnly && families.isEmpty;

  bool matches(Species species, GameState state, DateTime now) {
    if (statuses.isNotEmpty && !statuses.any((s) => _hasStatus(s, species, state))) return false;
    if (inSeason && !species.bestMonths.contains(now.month)) return false;
    if (bands.isNotEmpty && !bands.contains(species.topBand)) return false;
    if (forms.isNotEmpty && !forms.contains(species.traits.growthForm)) return false;
    if (protectedOnly && !species.isProtected) return false;
    if (families.isNotEmpty && !families.contains(species.family)) return false;
    return true;
  }

  static bool _hasStatus(SpeciesStatus status, Species species, GameState state) => switch (status) {
    SpeciesStatus.met => state.hasEncountered(species.sci),
    SpeciesStatus.toFind => !state.hasEncountered(species.sci),
    SpeciesStatus.desiderata => state.desiderata.contains(species.sci),
    SpeciesStatus.studying => speciesInStudy(state).contains(species.sci),
  };

  ErbarioFilter copyWith({
    Set<SpeciesStatus>? statuses,
    bool? inSeason,
    Set<AltitudeBand>? bands,
    Set<GrowthForm>? forms,
    bool? protectedOnly,
    Set<String>? families,
  }) => ErbarioFilter(
    statuses: statuses ?? this.statuses,
    inSeason: inSeason ?? this.inSeason,
    bands: bands ?? this.bands,
    forms: forms ?? this.forms,
    protectedOnly: protectedOnly ?? this.protectedOnly,
    families: families ?? this.families,
  );

  Map<String, dynamic> toJson() => {
    if (statuses.isNotEmpty) 'statuses': [for (final s in statuses) s.name],
    if (inSeason) 'inSeason': true,
    if (bands.isNotEmpty) 'bands': [for (final b in bands) b.name],
    if (forms.isNotEmpty) 'forms': [for (final f in forms) f.name],
    if (protectedOnly) 'protectedOnly': true,
    if (families.isNotEmpty) 'families': families.toList(),
  };

  /// Valori sconosciuti (es. salvati da una versione futura) si ignorano.
  factory ErbarioFilter.fromJson(Map<String, dynamic> json) {
    Set<T> parse<T extends Enum>(String key, List<T> values) => {
      for (final id in (json[key] as List?) ?? const []) ?values.asNameMap()[id],
    };
    return ErbarioFilter(
      statuses: parse('statuses', SpeciesStatus.values),
      inSeason: json['inSeason'] as bool? ?? false,
      bands: parse('bands', AltitudeBand.values),
      forms: parse('forms', GrowthForm.values),
      protectedOnly: json['protectedOnly'] as bool? ?? false,
      families: {...?(json['families'] as List?)?.cast<String>()},
    );
  }
}

/// Le viste già pronte: chi non vuole configurare niente ha comunque un erbario utile.
enum BuiltInView {
  all(ErbarioFilter.all),
  met(ErbarioFilter(statuses: {SpeciesStatus.met})),
  inSeason(ErbarioFilter(inSeason: true)),
  desiderata(ErbarioFilter(statuses: {SpeciesStatus.desiderata})),
  protectedSpecies(ErbarioFilter(protectedOnly: true));

  const BuiltInView(this.filter);

  final ErbarioFilter filter;
}

/// Una vista salvata dall'utente: un nome e un filtro.
class SavedView {
  final String id;
  final String name;
  final ErbarioFilter filter;

  const SavedView({required this.id, required this.name, required this.filter});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'filter': filter.toJson()};

  factory SavedView.fromJson(Map<String, dynamic> json) => SavedView(
    id: json['id'] as String,
    name: json['name'] as String,
    filter: ErbarioFilter.fromJson(json['filter'] as Map<String, dynamic>),
  );
}
