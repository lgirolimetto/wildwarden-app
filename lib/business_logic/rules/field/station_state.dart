import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/rules/field/stations.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/harvest.dart';
import 'package:druid_app/business_logic/rules/recipes/potion_effects.dart';

/// Lo stato di una Stazione e la Vis di una raccolta (blocco 3, capitolo 02: "Stazioni, Vis e uso delle pozioni",
/// "Anti-farming e bilanciamento"). Numeri 🟡: si tarano con il simulatore e con i dati del campo.

/// Dopo una raccolta la Stazione torna pronta dopo questo tempo, secondo il grado della specie (🟢 2026-10-29: solo per
/// grado nel prototipo). Ospiti e Scoperte come le Comuni.
const regrowthByGrade = {
  Grade.common: Duration(hours: 20),
  Grade.uncommon: Duration(hours: 36),
  Grade.rare: Duration(days: 3),
  Grade.mythic: Duration(days: 5),
};

/// Il grado di una Stazione: quello della specie nel catalogo (la rarità locale arriva con le Zone come mappe).
Grade gradeOf(Station station, Catalog catalog) => catalog.speciesBySci(station.speciesSci)?.grade ?? Grade.common;

enum StationStatus {
  ready,

  /// Attinta oggi: torna pronta più avanti.
  exhausted,

  /// Attinta in un giorno passato, non ancora rigenerata (le Rare ci mettono giorni).
  regrowing,
}

/// Quando la Stazione torna pronta; null se è pronta da sempre (mai attinta). La Ricrescita accorcia l'attesa nella
/// stessa proporzione in cui accorcia il giorno.
DateTime? readyAt(Station station, Catalog catalog, GameState state, DateTime now) {
  final last = state.lastStationDraws[station.id];
  if (last == null) return null;
  var wait = regrowthByGrade[gradeOf(station, catalog)]!;
  final regrowth = activeEffects(state, now)[PotionEffect.regrowth];
  if (regrowth != null) wait = wait * (regrowthWait(regrowth).inMinutes / Duration.minutesPerDay);
  return last.add(wait);
}

StationStatus statusOf(Station station, Catalog catalog, GameState state, DateTime now) {
  final ready = readyAt(station, catalog, state, now);
  if (ready == null || !now.isBefore(ready)) return StationStatus.ready;
  final last = state.lastStationDraws[station.id]!;
  final sameDay = last.year == now.year && last.month == now.month && last.day == now.day;
  return sameDay ? StationStatus.exhausted : StationStatus.regrowing;
}

/// Le tue Stazioni entro [sameStationMeters] da un punto, dalla più vicina: "Sei alla tua Stazione".
List<Station> stationsHere(GameState state, double latitude, double longitude) =>
    [...stationsWithin(state, latitude, longitude, sameStationMeters)]..sort(
      (a, b) => distanceMeters(
        latitude,
        longitude,
        a.latitude,
        a.longitude,
      ).compareTo(distanceMeters(latitude, longitude, b.latitude, b.longitude)),
    );

/// Isolamento (🔵 capitolo 02): la distanza media dalle tue 5 Stazioni più vicine dà la produttività, con una curva
/// morbida tra i punti della tabella (< 150 m 60 %, 150–300 m 80 %, 300–800 m 100 %, > 800 m 115 %). Una Stazione
/// sola è isolata.
double isolationOf(Station station, GameState state) {
  final distances = [
    for (final other in state.stations)
      if (other.id != station.id) distanceMeters(station.latitude, station.longitude, other.latitude, other.longitude),
  ]..sort();
  if (distances.isEmpty) return isolationCurve.last.$2;
  final nearest = distances.take(5);
  return isolationFactor(nearest.reduce((a, b) => a + b) / nearest.length);
}

/// I punti della curva: il centro di ogni fascia della tabella.
const isolationCurve = [(75.0, 0.6), (225.0, 0.8), (550.0, 1.0), (1100.0, 1.15)];

double isolationFactor(double meanMeters) {
  if (meanMeters <= isolationCurve.first.$1) return isolationCurve.first.$2;
  for (var i = 1; i < isolationCurve.length; i++) {
    final (x0, y0) = isolationCurve[i - 1];
    final (x1, y1) = isolationCurve[i];
    if (meanMeters <= x1) return y0 + (y1 - y0) * (meanMeters - x0) / (x1 - x0);
  }
  return isolationCurve.last.$2;
}

/// Forza della Stazione dal riconoscimento (🟢 capitolo 02, numeri ⏳ dai dati del campo): piena dal 40 %, sotto in
/// proporzione, mai meno del 25 %.
const fullStrengthFrom = 0.4;
const minimumStrength = 0.25;

double strengthOf(Station station) => max(minimumStrength, min(1, station.confidence / fullStrengthFrom));

/// L'anello del mirino conta almeno così: chi scatta subito raccoglie comunque qualcosa.
const minimumRing = 0.3;

/// Un'Ospite qui ha molta meno Vis; uno scatto sospetto (telefono quasi fermo) la metà.
const guestVis = 0.3;
const suspiciousVis = 0.5;

/// La Vis di una raccolta: la base per l'anello del mirino, la forza della Stazione, l'isolamento, e meno per le Ospiti e
/// per gli scatti sospetti. Arrotondata, almeno 1.
int visOfDraw({required double ring, required Station station, required GameState state, bool suspicious = false}) {
  final vis =
      visPerDraw *
      max(minimumRing, min(1, ring)) *
      strengthOf(station) *
      isolationOf(station, state) *
      (station.kind == StationKind.guest ? guestVis : 1) *
      (suspicious ? suspiciousVis : 1);
  return max(1, vis.round());
}
