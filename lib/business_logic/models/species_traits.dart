/// Forma di crescita (da WCVP).
enum GrowthForm { tree, shrub, herb, climber }

/// Ciclo vitale delle erbe (da WCVP); le legnose sono tutte perenni e non lo hanno.
enum LifeCycle { annual, biennial, perennial }

/// Come viaggiano i semi (sindromi di dispersione di EuDiS). [nearby]: nessun aiuto, cadono vicino alla pianta.
enum SeedDispersal { eatenByAnimals, stuckToAnimals, hoardedByAnimals, ants, wind, water, launched, nearby }

/// Tratti di una specie per lo studio, da banche dati aperte (CC BY 4.0): WCVP (Kew), EIVE 1.0, EuDiS. Ogni campo
/// può mancare: il fatto corrispondente semplicemente non si chiede.
class SpeciesTraits {
  final GrowthForm? growthForm;
  final LifeCycle? lifeCycle;

  /// `true` se in Italia è stata introdotta dall'uomo, `false` se è autoctona; `null` se non si sa.
  final bool? introducedInItaly;

  /// Indicatori ecologici EIVE (0-10): luce, umidità e nutrienti del suolo.
  final double? light;
  final double? moisture;
  final double? nutrients;
  final Set<SeedDispersal> dispersal;

  const SpeciesTraits({
    this.growthForm,
    this.lifeCycle,
    this.introducedInItaly,
    this.light,
    this.moisture,
    this.nutrients,
    this.dispersal = const {},
  });

  static const none = SpeciesTraits();

  factory SpeciesTraits.fromJson(Map<String, dynamic> json) {
    final ecology = (json['ecology'] as Map<String, dynamic>?) ?? const {};
    return SpeciesTraits(
      growthForm: GrowthForm.values.asNameMap()[json['growthForm']],
      lifeCycle: LifeCycle.values.asNameMap()[json['lifeCycle']],
      introducedInItaly: json['introducedInItaly'] as bool?,
      light: (ecology['light'] as num?)?.toDouble(),
      moisture: (ecology['moisture'] as num?)?.toDouble(),
      nutrients: (ecology['nutrients'] as num?)?.toDouble(),
      dispersal: {for (final id in (json['dispersal'] as List?) ?? const []) ?SeedDispersal.values.asNameMap()[id]},
    );
  }
}
