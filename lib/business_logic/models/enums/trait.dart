/// Tratti delle essenze: le condizioni del momento in cui si attinge.
///
/// ⚠️ Il nome di ogni valore viene salvato negli eventi `EssenceDrawn`: non si rinomina.
/// Le ricette del catalogo usano ancora etichette testuali ("🌕 Lunare"): si convertono a questi id nel blocco 3,
/// quando i tratti nasceranno dalle condizioni reali.
enum Trait { frost, rain, fog, sun, moon, dew, dusk }
