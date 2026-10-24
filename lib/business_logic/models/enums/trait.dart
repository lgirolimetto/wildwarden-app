/// Tratti delle essenze: le condizioni del momento in cui si attinge.
///
/// ⚠️ Il nome di ogni valore viene salvato negli eventi `EssenceDrawn`: non si rinomina.
/// Sono anche gli id usati dalle ricette del catalogo (gli ingredienti che chiedono una condizione).
///
/// Si calcolano dal meteo (Open-Meteo) e dall'astronomia (alba, tramonto, fase lunare) nel blocco 3; nessuno li
/// inserisce a mano (capitolo 02, "I tratti delle essenze"). [moon] è la luna piena, [dusk] il tramonto.
///
/// Niente tratti che premiano uscite rischiose: Notte (`night`) e Dopo il temporale (`afterStorm`) sono stati tolti
/// (2026-10-24). Gli eventi simulati prima di allora possono ancora contenerli: i tratti degli eventi restano stringhe.
enum Trait { frost, rain, fog, sun, moon, dew, dusk, dawn, newMoon }
