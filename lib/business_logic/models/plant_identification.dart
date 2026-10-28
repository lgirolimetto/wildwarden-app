/// La parte della pianta in una foto, con il nome che le dà Pl@ntNet: la pianta intera (Pl@ntNet la riconosce da
/// sé, "auto"), una foglia, un fiore. Le tre foto di una pianta vanno a Pl@ntNet insieme (capitolo 02, 2026-10-28).
enum PlantOrgan {
  whole('auto'),
  leaf('leaf'),
  flower('flower');

  final String plantNetName;

  const PlantOrgan(this.plantNetName);
}

/// Le piante fra cui Pl@ntNet cerca: tutto il mondo, o la flora della regione botanica della Zona (per Bologna l'Europa
/// sudorientale, in cui le regioni botaniche mettono l'Italia). Con la flora regionale una pianta coltivata lontano dal
/// suo ambiente è riconosciuta con meno sicurezza: meno forza (capitolo 02, 2026-10-28). Da provare con la Prova sul
/// campo; con più Zone il progetto verrà dal catalogo.
enum PlantFlora {
  world('all'),
  regional('k-southeastern-europe');

  final String plantNetProject;

  const PlantFlora(this.plantNetProject);
}

/// Una foto per il riconoscimento.
class PlantPhoto {
  final String path;
  final PlantOrgan organ;

  const PlantPhoto(this.path, this.organ);
}

/// Una specie proposta da Pl@ntNet per una foto, con la sicurezza (0–1).
class PlantCandidate {
  final String scientificName;
  final List<String> commonNames;
  final double score;

  /// Chiave GBIF che Pl@ntNet associa alla specie, se la dà.
  final int? gbifKey;

  const PlantCandidate({required this.scientificName, required this.commonNames, required this.score, this.gbifKey});

  factory PlantCandidate.fromJson(Map<String, dynamic> json) {
    final species = json['species'] as Map<String, dynamic>;
    return PlantCandidate(
      scientificName: species['scientificNameWithoutAuthor'] as String,
      commonNames: [for (final name in species['commonNames'] as List? ?? const []) name as String],
      score: (json['score'] as num).toDouble(),
      gbifKey: int.tryParse('${(json['gbif'] as Map?)?['id'] ?? ''}'),
    );
  }
}

/// Risposta di Pl@ntNet: i candidati dal più probabile e le identificazioni rimaste oggi (se la risposta le dice).
class PlantIdentification {
  final List<PlantCandidate> candidates;
  final int? remainingRequests;

  const PlantIdentification({required this.candidates, this.remainingRequests});

  /// Nessuna specie riconosciuta (Pl@ntNet risponde 404).
  static const none = PlantIdentification(candidates: []);

  factory PlantIdentification.fromJson(Map<String, dynamic> json) => PlantIdentification(
    candidates: [for (final result in json['results'] as List) PlantCandidate.fromJson(result as Map<String, dynamic>)]
      ..sort((a, b) => b.score.compareTo(a.score)),
    remainingRequests: json['remainingIdentificationRequests'] as int?,
  );
}
