/// Tratti delle essenze: le condizioni del momento in cui si attinge.
///
/// ⚠️ Il nome di ogni valore viene salvato negli eventi `EssenceDrawn`: non si rinomina. L'ordine invece è quello in
/// cui i tratti si mostrano (legenda, scelta dei tratti): per gruppo, poi la luce nell'ordine del giorno e la luna
/// in quello del ciclo.
/// Sono anche gli id usati dalle ricette del catalogo (gli ingredienti che chiedono una condizione).
///
/// Si calcolano dal meteo (Open-Meteo) e dall'astronomia (alba, tramonto, fase lunare) nel blocco 3; nessuno li
/// inserisce a mano (capitolo 02, "I tratti delle essenze"). [moon] è la luna piena, [dusk] il tramonto.
///
/// Niente tratti che premiano uscite rischiose: Notte (`night`) e Dopo il temporale (`afterStorm`) sono stati tolti
/// (2026-10-24). Gli eventi simulati prima di allora possono ancora contenerli: i tratti degli eventi restano stringhe.
enum Trait {
  dawn(TraitGroup.daylight),
  dusk(TraitGroup.daylight),
  waxingMoon(TraitGroup.moon),
  moon(TraitGroup.moon),
  waningMoon(TraitGroup.moon),
  newMoon(TraitGroup.moon),
  sun(TraitGroup.weather),
  rain(TraitGroup.weather),
  fog(TraitGroup.weather),
  dew(TraitGroup.weather),
  frost(TraitGroup.weather);

  final TraitGroup group;

  const Trait(this.group);
}

/// Gruppi dei tratti, per tipo: la luce del giorno (dall'ora del sole), la luna (dalla fase), il meteo (dalle
/// previsioni). Solare e Rugiada sono meteo: dipendono dal cielo, non solo dall'ora.
enum TraitGroup {
  daylight,
  moon,
  weather;

  /// I tratti del gruppo, nell'ordine in cui si mostrano.
  List<Trait> get traits => [for (final t in Trait.values) if (t.group == this) t];
}
