/// Che pianta è, rispetto alla mappa del posto (capitolo 02, "Zone come mappe e flora a cerchi").
///
/// ⚠️ Il nome di ogni valore viene salvato negli eventi `StationCreated`: non si rinomina.
enum StationKind {
  /// Nella mappa della Zona: studio, Ricettario, forza secondo la rarità della stazione.
  zone,

  /// Spontanea ma non nella mappa (mai osservata lì): timbro "Scoperta", da confermare.
  discovery,

  /// Non cresce spontanea nella regione (Pl@ntNet la trova solo nella flora del mondo): Vis e PE molto deboli.
  guest,
}

/// Una stazione: una pianta in un punto, nata da una foto riconosciuta. Solo sul telefono, mai mostrata su una mappa
/// né condivisa (capitolo 02).
class Station {
  final String id;
  final String speciesSci;
  final StationKind kind;
  final double latitude;
  final double longitude;

  /// Precisione del GPS alla nascita, in metri.
  final double accuracy;

  /// Sicurezza del riconoscimento (punteggio di Pl@ntNet della specie scelta, 0–1): diventa la forza della stazione
  /// (capitolo 02, "La sicurezza del riconoscimento diventa la forza della pianta"; soglia e proporzione ⏳).
  final double confidence;
  final DateTime createdAt;

  /// Per le piante fuori dalla mappa (Scoperte, Ospiti): nome comune e famiglia dalla risposta di Pl@ntNet, perché
  /// il catalogo non le ha.
  final String? commonName;
  final String? family;

  const Station({
    required this.id,
    required this.speciesSci,
    required this.kind,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.confidence,
    required this.createdAt,
    this.commonName,
    this.family,
  });
}
