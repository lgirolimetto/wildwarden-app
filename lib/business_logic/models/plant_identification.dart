/// Una specie proposta da Pl@ntNet per una foto, con la sicurezza (0–1).
class PlantCandidate {
  final String scientificName;
  final List<String> commonNames;
  final double score;

  const PlantCandidate({required this.scientificName, required this.commonNames, required this.score});

  factory PlantCandidate.fromJson(Map<String, dynamic> json) {
    final species = json['species'] as Map<String, dynamic>;
    return PlantCandidate(
      scientificName: species['scientificNameWithoutAuthor'] as String,
      commonNames: [for (final name in species['commonNames'] as List? ?? const []) name as String],
      score: (json['score'] as num).toDouble(),
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
