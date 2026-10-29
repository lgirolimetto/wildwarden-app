import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/rules/field/identification.dart';
import 'package:druid_app/business_logic/rules/field/stations.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';

/// Dalla risposta di Pl@ntNet alla pianta scelta (step 3 del Campo, capitolo 02 del 2026-10-28): prima la flora
/// regionale, poi quella del mondo; l'ipotesi di chi gioca scioglie l'indecisione; PE per l'ipotesi giusta e per la
/// prima Ospite.

/// Ipotesi giusta alla prima raccolta della specie, genere giusto, prima volta che si trova un'Ospite (🔵 da tarare
/// nel simulatore).
const guessExactXp = 20;
const guessGenusXp = 5;
const guestDiscoveryXp = 10;

/// Un candidato si può scegliere (anche con l'ipotesi) solo da questo punteggio in su.
const minimumChoiceScore = 0.05;

/// Due candidati sono contesi quando il secondo ha almeno questa parte del punteggio del primo (es. evonimo: 41 % contro
/// 45 %): se l'ipotesi non scioglie, sceglie chi gioca.
const contestedRatio = 0.6;

/// Un candidato con la specie del catalogo (null fuori dalla mappa) e il tipo di pianta.
class CaptureChoice {
  final PlantCandidate candidate;
  final Species? species;
  final StationKind kind;

  const CaptureChoice(this.candidate, this.species, this.kind);
}

class CaptureReview {
  final List<CaptureChoice> choices;

  /// Il candidato proposto: quello dell'ipotesi se è tra i candidati, se no il primo.
  final int selected;

  /// I primi due sono contesi e l'ipotesi non li ha sciolti: sceglie chi gioca.
  final bool needsChoice;

  /// Pl@ntNet non ha trovato niente nella flora regionale: i candidati vengono dalla flora del mondo (Ospiti).
  final bool worldOnly;

  const CaptureReview({
    required this.choices,
    required this.selected,
    required this.needsChoice,
    required this.worldOnly,
  });

  bool get empty => choices.isEmpty;
}

CaptureReview reviewCapture({
  required PlantIdentification regional,
  PlantIdentification? world,
  required Catalog catalog,
  String? guess,
}) {
  final worldOnly = regional.candidates.isEmpty;
  final source = worldOnly ? (world ?? PlantIdentification.none) : regional;
  final choices = [
    for (final candidate in source.candidates.take(shownCandidates))
      if (candidate.score >= minimumChoiceScore || candidate == source.candidates.first)
        _choice(candidate, catalog, inRegionalFlora: !worldOnly),
  ];
  final guessed = choices.indexWhere(
    (c) => c.candidate.score >= minimumChoiceScore && guessResultOf(guess, c) == GuessResult.exact,
  );
  final contested =
      choices.length > 1 &&
      choices[1].candidate.score >= minimumChoiceScore &&
      choices[1].candidate.score >= contestedRatio * choices[0].candidate.score;
  return CaptureReview(
    choices: choices,
    selected: guessed < 0 ? 0 : guessed,
    needsChoice: contested && guessed < 0,
    worldOnly: worldOnly,
  );
}

CaptureChoice _choice(PlantCandidate candidate, Catalog catalog, {required bool inRegionalFlora}) {
  final species = catalogSpeciesOf(candidate, catalog);
  // Le aromatiche Ospiti del tutorial (il basilico) restano Ospiti anche se il catalogo le ha.
  if (species != null && catalog.kitchenGuests.contains(species.sci)) {
    return CaptureChoice(candidate, species, StationKind.guest);
  }
  return CaptureChoice(candidate, species, stationKindOf(inCatalog: species != null, inRegionalFlora: inRegionalFlora));
}

enum GuessResult { none, exact, genus, wrong }

/// Com'è andata l'ipotesi rispetto a una pianta: giusta (nome scientifico o comune), genere giusto, sbagliata, o non
/// data ("Non lo so").
GuessResult guessResultOf(String? guess, CaptureChoice choice) {
  final wanted = guess?.trim().toLowerCase() ?? '';
  if (wanted.isEmpty) return GuessResult.none;
  final species = choice.species;
  final names = <String>[
    choice.candidate.scientificName,
    ...choice.candidate.commonNames,
    if (species != null) ...[species.sci, species.name.resolve('it')],
  ].map((n) => n.toLowerCase());
  if (names.any((n) => n == wanted || binomial(n) == binomial(wanted))) return GuessResult.exact;
  final genus = (choice.species?.genus ?? choice.candidate.scientificName.split(' ').first).toLowerCase();
  return wanted.split(RegExp(r'\s+')).first == genus ? GuessResult.genus : GuessResult.wrong;
}

/// PE dello scatto: solo la prima volta che si trova la specie (l'ipotesi giusta, la scoperta di un'Ospite).
int captureXp(GameState state, CaptureChoice choice, GuessResult guess) {
  final sci = choice.species?.sci ?? choice.candidate.scientificName;
  if (state.hasEncountered(sci)) return 0;
  return switch (guess) {
        GuessResult.exact => guessExactXp,
        GuessResult.genus => guessGenusXp,
        _ => 0,
      } +
      (choice.kind == StationKind.guest ? guestDiscoveryXp : 0);
}
