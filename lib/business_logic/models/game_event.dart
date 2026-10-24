import 'dart:convert';

/// Come è avvenuto l'incontro con una specie.
enum EncounterMethod {
  /// Pulsante di debug: nessuna foto, nessuna posizione.
  simulated,

  /// Foto riconosciuta da Pl@ntNet (blocco 2).
  photo,

  /// Specie confermata da una guida durante un'escursione.
  guide,
}

/// Modalità di una risposta: apprendimento di un livello o ripasso a distanza di giorni.
enum AnswerMode { learning, review }

/// Da dove arriva una ricetta imparata: dallo studio (le comuni) o dal Bottino dell'Esperienza (tappa C).
enum RecipeOrigin { study, trove }

/// Passi dell'onboarding che non si deducono dallo stato di gioco.
enum OnboardingMark { erbarioVisited, skipped }

/// Evento di gioco. Si salvano solo eventi: livelli, PE ed erbario si ricalcolano rileggendoli
/// (vedi `GameState.replay`). È lo stesso formato che un giorno verrà inviato al server.
///
/// ⚠️ `type` e chiavi del payload sono salvati nel database: non si rinominano mai.
sealed class GameEvent {
  final DateTime occurredAt;

  const GameEvent({required this.occurredAt});

  String get type;

  /// PE guadagnati con questo evento (0 se nessuno).
  int get xp => 0;

  Map<String, dynamic> payload();

  String encodePayload() => jsonEncode(payload());

  /// Ricostruisce un evento dal database. Un tipo sconosciuto lancia: il chiamante lo trasforma in `Fail`.
  static GameEvent decode({required String type, required String payload, required DateTime occurredAt}) {
    final d = jsonDecode(payload) as Map<String, dynamic>;
    return switch (type) {
      SpeciesEncountered.typeId => SpeciesEncountered(
        speciesSci: d['species'] as String,
        method: EncounterMethod.values.byName(d['method'] as String),
        occurredAt: occurredAt,
      ),
      AnswerGiven.typeId => AnswerGiven(
        factId: d['fact'] as String,
        correct: d['correct'] as bool,
        mode: AnswerMode.values.byName(d['mode'] as String),
        xp: d['xp'] as int,
        occurredAt: occurredAt,
      ),
      LevelPassed.typeId => LevelPassed(
        speciesSci: d['species'] as String,
        level: d['level'] as int,
        xp: d['xp'] as int,
        occurredAt: occurredAt,
      ),
      MasteryReached.typeId => MasteryReached(
        speciesSci: d['species'] as String,
        xp: d['xp'] as int,
        occurredAt: occurredAt,
      ),
      EssenceDrawn.typeId => EssenceDrawn(
        speciesSci: d['species'] as String,
        traits: _decodeTraits(d),
        simulated: d['simulated'] as bool,
        // Assenti negli eventi salvati prima dello step 4 della tappa B.
        vis: d['vis'] as int? ?? 0,
        xp: d['xp'] as int? ?? 0,
        occurredAt: occurredAt,
      ),
      DesiderataChanged.typeId => DesiderataChanged(
        speciesSci: d['species'] as String,
        marked: d['marked'] as bool,
        occurredAt: occurredAt,
      ),
      DesiderataFulfilled.typeId => DesiderataFulfilled(
        speciesSci: d['species'] as String,
        xp: d['xp'] as int,
        occurredAt: occurredAt,
      ),
      FunFactRevealed.typeId => FunFactRevealed(funFactId: d['funFact'] as String, occurredAt: occurredAt),
      NoteSaved.typeId => NoteSaved(
        speciesSci: d['species'] as String,
        text: d['text'] as String,
        occurredAt: occurredAt,
      ),
      NotebookEntrySaved.typeId => NotebookEntrySaved(factId: d['fact'] as String, occurredAt: occurredAt),
      RecipeLearned.typeId => RecipeLearned(
        recipeId: d['recipe'] as String,
        origin: RecipeOrigin.values.byName(d['origin'] as String),
        occurredAt: occurredAt,
      ),
      OnboardingMarked.typeId => OnboardingMarked(
        mark: OnboardingMark.values.byName(d['mark'] as String),
        occurredAt: occurredAt,
      ),
      _ => throw FormatException('Tipo di evento sconosciuto: $type'),
    };
  }
}

/// Tratti di un `EssenceDrawn`. Prima di "più tratti per essenza" si salvava un solo `trait` (anche `null`): si
/// rilegge come una lista di un elemento (o vuota).
List<String> _decodeTraits(Map<String, dynamic> d) {
  if (d['traits'] case final List<dynamic> traits) return traits.cast<String>();
  return [?d['trait'] as String?];
}

/// Il giocatore ha incontrato una specie (la prima volta conta per l'erbario).
class SpeciesEncountered extends GameEvent {
  static const typeId = 'species_encountered';
  final String speciesSci;
  final EncounterMethod method;

  const SpeciesEncountered({required this.speciesSci, required this.method, required super.occurredAt});

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'species': speciesSci, 'method': method.name};
}

/// Risposta a una domanda di studio o di ripasso. I PE sono calcolati da `xp_rules` al momento della risposta.
class AnswerGiven extends GameEvent {
  static const typeId = 'answer_given';
  final String factId;
  final bool correct;
  final AnswerMode mode;
  @override
  final int xp;

  const AnswerGiven({
    required this.factId,
    required this.correct,
    required this.mode,
    required this.xp,
    required super.occurredAt,
  });

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'fact': factId, 'correct': correct, 'mode': mode.name, 'xp': xp};
}

/// Livello di studio superato (1-3). Il livello 4 è [MasteryReached].
class LevelPassed extends GameEvent {
  static const typeId = 'level_passed';
  final String speciesSci;
  final int level;
  @override
  final int xp;

  const LevelPassed({required this.speciesSci, required this.level, required this.xp, required super.occurredAt});

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'species': speciesSci, 'level': level, 'xp': xp};
}

class MasteryReached extends GameEvent {
  static const typeId = 'mastery_reached';
  final String speciesSci;
  @override
  final int xp;

  const MasteryReached({required this.speciesSci, required this.xp, required super.occurredAt});

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'species': speciesSci, 'xp': xp};
}

/// Essenza attinta da una stazione, con tutti i tratti veri in quel momento (vuoto = nessuno) e le [vis]
/// immagazzinate. La prima essenza di una specie incassa i PE virtuali dello studio di quella specie.
/// Oggi è solo simulata; dal blocco 3 nasce dalle condizioni reali.
class EssenceDrawn extends GameEvent {
  static const typeId = 'essence_drawn';
  final String speciesSci;
  final List<String> traits;
  final bool simulated;

  /// Unità di Vis ("la linfa sottile delle piante") immagazzinate con questa raccolta.
  final int vis;
  @override
  final int xp;

  const EssenceDrawn({
    required this.speciesSci,
    this.traits = const [],
    required this.simulated,
    this.vis = 0,
    this.xp = 0,
    required super.occurredAt,
  });

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {
    'species': speciesSci,
    'traits': traits,
    'simulated': simulated,
    'vis': vis,
    'xp': xp,
  };
}

/// Specie aggiunta o tolta dalle desiderata.
class DesiderataChanged extends GameEvent {
  static const typeId = 'desiderata_changed';
  final String speciesSci;
  final bool marked;

  const DesiderataChanged({required this.speciesSci, required this.marked, required super.occurredAt});

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'species': speciesSci, 'marked': marked};
}

/// Una specie delle desiderata è stata incontrata: missione compiuta.
class DesiderataFulfilled extends GameEvent {
  static const typeId = 'desiderata_fulfilled';
  final String speciesSci;
  @override
  final int xp;

  const DesiderataFulfilled({required this.speciesSci, required this.xp, required super.occurredAt});

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'species': speciesSci, 'xp': xp};
}

/// Curiosità consegnata come "curiosità del giorno".
class FunFactRevealed extends GameEvent {
  static const typeId = 'fun_fact_revealed';
  final String funFactId;

  const FunFactRevealed({required this.funFactId, required super.occurredAt});

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'funFact': funFactId};
}

/// Nota libera su una specie (gratuita). L'ultima salvata è quella valida.
class NoteSaved extends GameEvent {
  static const typeId = 'note_saved';
  final String speciesSci;
  final String text;

  const NoteSaved({required this.speciesSci, required this.text, required super.occurredAt});

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'species': speciesSci, 'text': text};
}

/// Fatto salvato nel taccuino (funzione del Diario dell'Erborista).
class NotebookEntrySaved extends GameEvent {
  static const typeId = 'notebook_entry_saved';
  final String factId;

  const NotebookEntrySaved({required this.factId, required super.occurredAt});

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'fact': factId};
}

class OnboardingMarked extends GameEvent {
  static const typeId = 'onboarding_marked';
  final OnboardingMark mark;

  const OnboardingMarked({required this.mark, required super.occurredAt});

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'mark': mark.name};
}

/// Ricetta imparata: si sa farla. Il caso (quale tra le ricette possibili) si salva qui, non si ricalcola.
class RecipeLearned extends GameEvent {
  static const typeId = 'recipe_learned';
  final String recipeId;
  final RecipeOrigin origin;

  const RecipeLearned({required this.recipeId, required this.origin, required super.occurredAt});

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'recipe': recipeId, 'origin': origin.name};
}
