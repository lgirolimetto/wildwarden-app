import 'dart:math';

import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';

/// Regole delle stazioni (blocco 2): quando nasce una stazione nuova e quando è la stessa.

/// Una foto della stessa specie entro questa distanza da una tua stazione è la stessa stazione. Provvisoria: il GPS
/// all'aperto sta a 3–6 m dopo pochi secondi (prova sul terrazzo, `prompts/app/feat_campo/STEP0.md`).
const sameStationMeters = 20.0;

/// Nuove stazioni al giorno (🟢 capitolo 02, anti-farming: una nuova identificazione al giorno nel free tier).
const newStationsPerDay = 1;

/// Distanza in metri tra due punti (formula dell'emisenoverso): più che precisa per qualche centinaio di metri.
double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371000.0;
  double rad(double deg) => deg * pi / 180;
  final dLat = rad(lat2 - lat1), dLon = rad(lon2 - lon1);
  final a = pow(sin(dLat / 2), 2) + cos(rad(lat1)) * cos(rad(lat2)) * pow(sin(dLon / 2), 2);
  return 2 * earthRadius * asin(sqrt(a));
}

/// Che pianta è rispetto alla mappa del posto: nella mappa, Scoperta (spontanea ma non nella mappa) o Ospite (Pl@ntNet
/// la trova solo nella flora del mondo).
StationKind stationKindOf({required bool inCatalog, required bool inRegionalFlora}) => inCatalog
    ? StationKind.zone
    : inRegionalFlora
    ? StationKind.discovery
    : StationKind.guest;

/// La tua stazione di [speciesSci] più vicina entro [sameStationMeters], se c'è: una foto lì non crea una stazione nuova.
Station? sameStation(GameState state, String speciesSci, double latitude, double longitude) {
  Station? closest;
  var best = sameStationMeters;
  for (final station in state.stations.where((s) => s.speciesSci == speciesSci)) {
    final d = distanceMeters(latitude, longitude, station.latitude, station.longitude);
    if (d <= best) {
      best = d;
      closest = station;
    }
  }
  return closest;
}

/// Stazioni nuove già create oggi (quelle del tutorial non contano).
int stationsCreatedOn(GameState state, DateTime day) => state.stations
    .where(
      (s) =>
          !s.tutorial && s.createdAt.year == day.year && s.createdAt.month == day.month && s.createdAt.day == day.day,
    )
    .length;

/// Si può creare una stazione nuova oggi? Da chiedere **prima** di chiamare Pl@ntNet, per non sprecare un'identificazione.
bool canCreateStation(GameState state, DateTime now) => stationsCreatedOn(state, now) < newStationsPerDay;

/// Le tue stazioni entro [meters] da un punto: più piante nello stesso posto fanno calare la Vis (depauperamento,
/// capitolo 02; la regola dell'isolamento è del blocco 3).
List<Station> stationsWithin(GameState state, double latitude, double longitude, double meters) => [
  for (final s in state.stations)
    if (distanceMeters(latitude, longitude, s.latitude, s.longitude) <= meters) s,
];

/// Le tue stazioni di una specie, dalla più vecchia.
List<Station> stationsOf(GameState state, String speciesSci) => [
  for (final s in state.stations)
    if (s.speciesSci == speciesSci) s,
]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

/// La prima stazione di una specie con la tua foto: la foto con il timbro che prende il posto di quella del catalogo
/// (capitolo 02, "L'incontro è una figurina con il timbro"). Null finché non l'hai fotografata.
Station? firstPhotoOf(GameState state, String speciesSci) {
  for (final s in stationsOf(state, speciesSci)) {
    if (s.photo != null) return s;
  }
  return null;
}
