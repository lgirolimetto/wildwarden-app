import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/localized_text.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/study/review_schedule.dart';

/// Curiosità su una specie. Quelle ricavate dai dati sono solo dati: il testo lo compone la UI.
sealed class FunFact {
  final Species species;

  /// Livello di studio della specie da cui la curiosità diventa disponibile.
  final int level;

  /// Chiave stabile dentro la specie: finisce nell'id salvato nel database.
  final String key;

  const FunFact(this.species, this.level, this.key);

  String get id => '${species.sci}#$key';
}

/// Scritta a mano (storia, etimologia, tradizioni). `verified == false` finché non è controllata su una fonte.
class CuratedFunFactItem extends FunFact {
  final LocalizedText text;
  final bool verified;
  final List<SourceRef> sources;

  const CuratedFunFactItem(
    super.species,
    super.level,
    super.key, {
    required this.text,
    required this.verified,
    this.sources = const [],
  });
}

class ObservationRankFact extends FunFact {
  final int rank;

  const ObservationRankFact(Species species, this.rank) : super(species, 0, 'rank');
}

class HighAltitudeFact extends FunFact {
  final int medianMeters;

  const HighAltitudeFact(Species species, this.medianMeters) : super(species, 3, 'high');
}

class LowlandFact extends FunFact {
  final int medianMeters;

  const LowlandFact(Species species, this.medianMeters) : super(species, 3, 'low');
}

class PeakMonthFact extends FunFact {
  /// 1-12.
  final int month;

  const PeakMonthFact(Species species, this.month) : super(species, 3, 'peak');
}

/// Tutte le curiosità di una specie, in ordine di livello.
List<FunFact> funFactsOf(Species species, Catalog catalog) {
  final byObservations = catalog.species.toList()..sort((a, b) => b.observations.compareTo(a.observations));
  final byAltitude = catalog.species.where((s) => s.elevationMedian != null).toList()
    ..sort((a, b) => b.elevationMedian!.compareTo(a.elevationMedian!));
  final altitudeRank = byAltitude.indexWhere((s) => s.sci == species.sci);
  final values = species.monthsRelative;

  final curated = catalog.funFacts[species.sci] ?? const [];
  return [
    ObservationRankFact(species, byObservations.indexWhere((s) => s.sci == species.sci) + 1),
    for (var i = 0; i < curated.length; i++)
      CuratedFunFactItem(
        species,
        curated[i].level,
        'c$i',
        text: curated[i].text,
        verified: curated[i].verified,
        sources: curated[i].sources,
      ),
    if (altitudeRank >= 0 && altitudeRank < 5) HighAltitudeFact(species, species.elevationMedian!.round()),
    if (altitudeRank >= 5 && altitudeRank >= byAltitude.length - 5)
      LowlandFact(species, species.elevationMedian!.round()),
    PeakMonthFact(species, values.indexOf(values.reduce(max)) + 1),
  ]..sort((a, b) => a.level.compareTo(b.level));
}

/// Curiosità disponibili: specie incontrata e livello sufficiente.
List<FunFact> availableFunFacts(Catalog catalog, GameState state) => [
  for (final species in catalog.species)
    if (state.hasEncountered(species.sci))
      ...funFactsOf(species, catalog).where((f) => state.levelOf(species.sci) >= f.level),
];

/// Curiosità da consegnare oggi, `null` se è già stata consegnata o non ce ne sono di nuove.
/// La scelta è casuale ma stabile nella giornata (seme = data), così riaprire l'app non la cambia.
FunFact? funFactToRevealToday(Catalog catalog, GameState state, DateTime now) {
  final today = startOfDay(now);
  if (state.revealedFunFacts.values.any((day) => startOfDay(day) == today)) return null;
  final fresh = availableFunFacts(catalog, state).where((f) => !state.revealedFunFacts.containsKey(f.id)).toList();
  if (fresh.isEmpty) return null;
  final seed = today.year * 10000 + today.month * 100 + today.day;
  return fresh[Random(seed).nextInt(fresh.length)];
}

/// Curiosità consegnata oggi, se c'è.
FunFact? funFactOfToday(Catalog catalog, GameState state, DateTime now) {
  final today = startOfDay(now);
  final id = state.revealedFunFacts.entries.where((e) => startOfDay(e.value) == today).map((e) => e.key).firstOrNull;
  if (id == null) return null;
  final sci = id.substring(0, id.lastIndexOf('#'));
  final species = catalog.speciesBySci(sci);
  return species == null ? null : funFactsOf(species, catalog).where((f) => f.id == id).firstOrNull;
}
