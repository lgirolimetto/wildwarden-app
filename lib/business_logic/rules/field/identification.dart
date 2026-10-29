import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/business_logic/models/species.dart';

/// Sotto questo punteggio Pl@ntNet non è abbastanza sicuro: l'app chiede un'altra foto (blocco 2). Provvisorio: si
/// tara con i numeri della prova sul campo (`prompts/app/feat_campo/STEP0.md`). Sull'emulatore, senza nessuna pianta
/// nella foto, i candidati avevano 0,2 %.
const minimumScore = 0.20;

/// Quanti candidati si mostrano tra cui scegliere.
const shownCandidates = 3;

/// Un candidato di Pl@ntNet con la specie del catalogo a cui corrisponde (null = fuori catalogo).
class CandidateChoice {
  final PlantCandidate candidate;
  final Species? species;

  const CandidateChoice(this.candidate, this.species);

  bool get inCatalog => species != null;
}

/// Che cosa mostrare dopo una foto: i primi candidati e se Pl@ntNet è abbastanza sicuro.
class IdentificationReview {
  final List<CandidateChoice> choices;

  /// Il primo candidato supera [minimumScore]. Se no l'app dice "Non ne sono sicuro: prova un'altra foto".
  final bool confident;

  const IdentificationReview({required this.choices, required this.confident});

  /// Pl@ntNet non ha riconosciuto niente.
  bool get empty => choices.isEmpty;
}

IdentificationReview reviewIdentification(PlantIdentification identification, Catalog catalog) {
  final choices = [
    for (final candidate in identification.candidates.take(shownCandidates))
      CandidateChoice(candidate, catalogSpeciesOf(candidate, catalog)),
  ];
  return IdentificationReview(
    choices: choices,
    confident: choices.isNotEmpty && choices.first.candidate.score >= minimumScore,
  );
}

/// La specie del catalogo che corrisponde a un candidato: prima per chiave GBIF (regge i sinonimi), poi per genere e
/// specie del nome scientifico (senza sottospecie, varietà e segno degli ibridi).
Species? catalogSpeciesOf(PlantCandidate candidate, Catalog catalog) {
  final byKey = candidate.gbifKey == null ? null : catalog.speciesByGbifKey(candidate.gbifKey!);
  if (byKey != null) return byKey;
  final wanted = binomial(candidate.scientificName);
  return catalog.species.where((s) => binomial(s.sci) == wanted).firstOrNull;
}

/// "Helleborus viridis subsp. occidentalis" → "helleborus viridis"; "Mentha × piperita" → "mentha piperita".
String binomial(String scientificName) => scientificName
    .toLowerCase()
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty && w != '×' && w != 'x')
    .take(2)
    .join(' ');
