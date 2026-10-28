import 'dart:convert';

import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/station.dart';

/// Come è avvenuto l'incontro con una specie.
enum EncounterMethod {
  /// Pulsante di debug: nessuna foto, nessuna posizione.
  simulated,

  /// Foto riconosciuta da Pl@ntNet (blocco 2).
  photo,

  /// Specie confermata da una guida durante un'escursione.
  guide,
}

/// Come si risponde: studio di un livello, Ripasso o mini-quiz per risvegliare la Maestria ([awakening], che non si
/// salva come `AnswerGiven`).
enum AnswerMode { learning, review, awakening }

/// Da dove arriva una ricetta imparata: dallo studio (la Comune di una pianta) o dal Bottino dell'Esperienza.
enum RecipeOrigin { study, trove }

/// Passi dell'onboarding che non si deducono dallo stato di gioco. [albumVisited] è il Ricettario aperto (si chiamava
/// Album: il nome è salvato negli eventi e non si rinomina).
enum OnboardingMark { erbarioVisited, albumVisited, skipped }

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
      MasteryAwakened.typeId => MasteryAwakened(speciesSci: d['species'] as String, occurredAt: occurredAt),
      EssenceDrawn.typeId => EssenceDrawn(
        speciesSci: d['species'] as String,
        traits: _decodeTraits(d),
        simulated: d['simulated'] as bool,
        // Assenti negli eventi salvati prima dello step 4 della tappa B.
        vis: d['vis'] as int? ?? 0,
        // Assente prima della Dispensa (step 7 della tappa C): la si ricava dal livello di studio di allora.
        purity: (d['purity'] as num?)?.toDouble(),
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
      TroveOpened.typeId => TroveOpened(
        grade: Grade.values.byName(d['grade'] as String),
        price: d['price'] as int,
        gift: d['gift'] as bool? ?? false,
        finds: [for (final f in d['finds'] as List) TroveFind.fromJson(f as Map<String, dynamic>)],
        occurredAt: occurredAt,
      ),
      WelcomeGiftOffered.typeId => WelcomeGiftOffered(occurredAt: occurredAt),
      PotionBrewed.typeId => PotionBrewed(
        recipeId: d['recipe'] as String,
        essences: (d['essences'] as Map<String, dynamic>).map((i, vis) => MapEntry(int.parse(i), vis as int)),
        potency: d['potency'] as int,
        touch: d['touch'] == null ? null : PotionEffect.values.byName(d['touch'] as String),
        freeSpecies: d['freeSpecies'] as String?,
        spoiled: d['spoiled'] as bool? ?? false,
        xp: d['xp'] as int,
        occurredAt: occurredAt,
      ),
      PotionUsed.typeId => PotionUsed(
        potionIndex: d['potion'] as int,
        effect: PotionEffect.values.byName(d['effect'] as String),
        strength: d['strength'] as int,
        touch: d['touch'] == null ? null : PotionEffect.values.byName(d['touch'] as String),
        occurredAt: occurredAt,
      ),
      RecipeRecycled.typeId => RecipeRecycled(
        recipeId: d['recipe'] as String,
        fromGrade: Grade.values.byName(d['fromGrade'] as String),
        used: d['used'] as int,
        vis: (d['vis'] as Map<String, dynamic>).map((sci, amount) => MapEntry(sci, amount as int)),
        occurredAt: occurredAt,
      ),
      StationCreated.typeId => StationCreated(
        station: Station(
          id: d['id'] as String,
          speciesSci: d['species'] as String,
          kind: StationKind.values.byName(d['kind'] as String),
          latitude: (d['lat'] as num).toDouble(),
          longitude: (d['lon'] as num).toDouble(),
          accuracy: (d['accuracy'] as num).toDouble(),
          confidence: (d['confidence'] as num).toDouble(),
          createdAt: occurredAt,
          commonName: d['name'] as String?,
          family: d['family'] as String?,
        ),
      ),
      XpGranted.typeId => XpGranted(xp: d['xp'] as int, reason: d['reason'] as String, occurredAt: occurredAt),
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

/// Nasce una stazione: una pianta riconosciuta da una foto, in un punto (blocco 2).
class StationCreated extends GameEvent {
  static const typeId = 'station_created';
  final Station station;

  StationCreated({required this.station}) : super(occurredAt: station.createdAt);

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {
    'id': station.id,
    'species': station.speciesSci,
    'kind': station.kind.name,
    'lat': station.latitude,
    'lon': station.longitude,
    'accuracy': station.accuracy,
    'confidence': station.confidence,
    if (station.commonName != null) 'name': station.commonName,
    if (station.family != null) 'family': station.family,
  };
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

/// La Maestria sopita di una specie si è risvegliata: il mini-quiz è stato superato. Niente PE.
class MasteryAwakened extends GameEvent {
  static const typeId = 'mastery_awakened';
  final String speciesSci;

  const MasteryAwakened({required this.speciesSci, required super.occurredAt});

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'species': speciesSci};
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

  /// Purezza dell'Essenza, dal livello di studio della specie in quel momento; `null` negli eventi di prima della
  /// Dispensa.
  final double? purity;
  @override
  final int xp;

  const EssenceDrawn({
    required this.speciesSci,
    this.traits = const [],
    required this.simulated,
    this.vis = 0,
    this.purity,
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
    'purity': ?purity,
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

/// Ricetta imparata: si sa farla. Studiando, la Comune della pianta; dal Bottino, quella uscita (il caso si salva qui,
/// non si ricalcola).
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

/// Che cosa è una cosa uscita da un Bottino dell'Esperienza.
enum TroveFindKind {
  /// Una Tavola nuova: completa (le Comuni) o con dei pezzi del nome da trovare.
  recipe,

  /// Un pezzo del nome di una Tavola incompleta che hai.
  piece,

  /// Un doppione (Tavola che hai già, anche incompleta): diventa un riciclato del suo grado.
  recycled,
}

/// Una cosa uscita da un Bottino. Porta con sé il grado e i pezzi mancanti: lo stato del gioco non conosce il
/// catalogo, e il caso non si ricalcola.
class TroveFind {
  final String recipeId;
  final Grade grade;
  final TroveFindKind kind;

  /// Pezzi del nome che mancano alla Tavola nuova (0 = completa); per pezzi e doppioni 0.
  final int missing;

  /// L'assaggio del grado sopra: al primo Bottino di un grado, una Tavola del grado successivo.
  final bool taste;

  const TroveFind({
    required this.recipeId,
    required this.grade,
    required this.kind,
    this.missing = 0,
    this.taste = false,
  });

  factory TroveFind.fromJson(Map<String, dynamic> json) => TroveFind(
    recipeId: json['recipe'] as String,
    grade: Grade.values.byName(json['grade'] as String),
    kind: TroveFindKind.values.byName(json['kind'] as String),
    missing: json['missing'] as int? ?? 0,
    taste: json['taste'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'recipe': recipeId,
    'grade': grade.name,
    'kind': kind.name,
    'missing': missing,
    'taste': taste,
  };
}

/// Bottino dell'Esperienza comprato e aperto: il saldo cala di [price], e quel che è uscito si salva qui.
class TroveOpened extends GameEvent {
  static const typeId = 'trove_opened';
  final Grade grade;
  final int price;

  /// Comprato con il regalo "bentornato", a prezzo di favore.
  final bool gift;
  final List<TroveFind> finds;

  const TroveOpened({
    required this.grade,
    required this.price,
    this.gift = false,
    required this.finds,
    required super.occurredAt,
  });

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {
    'grade': grade.name,
    'price': price,
    'gift': gift,
    'finds': [for (final f in finds) f.toJson()],
  };
}

/// "Ehi, c'è un regalo per te": il primo Bottino raro a prezzo di favore è stato offerto. Si riscatta dopo
/// un'Essenza attinta da quel momento.
class WelcomeGiftOffered extends GameEvent {
  static const typeId = 'welcome_gift_offered';

  const WelcomeGiftOffered({required super.occurredAt});

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {};
}

/// PE dati fuori dal gioco: oggi solo dagli strumenti di prova ([reason] `debug`).
class XpGranted extends GameEvent {
  static const typeId = 'xp_granted';
  @override
  final int xp;
  final String reason;

  const XpGranted({required this.xp, required this.reason, required super.occurredAt});

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'xp': xp, 'reason': reason};
}

/// Riciclo: [used] riciclati di [fromGrade] e un po' di Vis diventano un componente della Tavola incompleta
/// [recipeId] (dello stesso grado con 3, del grado sopra con 9). Le Vis spese si salvano per specie.
class RecipeRecycled extends GameEvent {
  static const typeId = 'recipe_recycled';
  final String recipeId;
  final Grade fromGrade;
  final int used;
  final Map<String, int> vis;

  const RecipeRecycled({
    required this.recipeId,
    required this.fromGrade,
    required this.used,
    required this.vis,
    required super.occurredAt,
  });

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {'recipe': recipeId, 'fromGrade': fromGrade.name, 'used': used, 'vis': vis};
}

/// Pozione preparata: le Vis prese dalle Essenze (per indice), la potenza, il Tocco e i PE, calcolati al momento. Con
/// [spoiled] la pozione si è guastata (una pianta tossica, [freeSpecies], nello slot libero di una ricetta da bere):
/// le Vis sono perse, niente pozione, e si impara che la pianta è tossica.
class PotionBrewed extends GameEvent {
  static const typeId = 'potion_brewed';
  final String recipeId;
  final Map<int, int> essences;
  final int potency;
  final PotionEffect? touch;
  final String? freeSpecies;
  final bool spoiled;
  @override
  final int xp;

  const PotionBrewed({
    required this.recipeId,
    required this.essences,
    required this.potency,
    this.touch,
    this.freeSpecies,
    this.spoiled = false,
    required this.xp,
    required super.occurredAt,
  });

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {
    'recipe': recipeId,
    'essences': {for (final MapEntry(key: i, value: vis) in essences.entries) '$i': vis},
    'potency': potency,
    'touch': touch?.name,
    'freeSpecies': freeSpecies,
    'spoiled': spoiled,
    'xp': xp,
  };
}

/// Pozione usata: lascia lo Scaffale e il suo effetto vale per qualche giorno, con la forza della potenza; il Tocco
/// aggiunge un piccolo effetto in più. Effetto e forza si salvano qui (la ricetta potrebbe cambiare).
class PotionUsed extends GameEvent {
  static const typeId = 'potion_used';
  final int potionIndex;
  final PotionEffect effect;

  /// Da 1 a 10: la potenza della pozione.
  final int strength;
  final PotionEffect? touch;

  const PotionUsed({
    required this.potionIndex,
    required this.effect,
    required this.strength,
    this.touch,
    required super.occurredAt,
  });

  @override
  String get type => typeId;

  @override
  Map<String, dynamic> payload() => {
    'potion': potionIndex,
    'effect': effect.name,
    'strength': strength,
    'touch': touch?.name,
  };
}
