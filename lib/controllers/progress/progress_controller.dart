import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_clock.dart';
import 'package:druid_app/business_logic/interfaces/i_game_event_store.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/fun_facts.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/business_logic/rules/study/xp_rules.dart';
import 'package:druid_app/controllers/base/loadable_controller.dart';

/// Progressi del giocatore: legge il registro degli eventi all'avvio e lo aggiorna a ogni azione.
/// Ogni azione di gioco passa da qui e diventa un evento.
class ProgressController extends LoadableController<GameState> {
  final IGameEventStore _store;
  final IClock _clock;

  /// Catalogo corrente (serve per maestria e curiosità); `null` se non è ancora caricato.
  final Catalog? Function() _catalog;

  ProgressController(this._store, this._clock, {required Catalog? Function() catalog}) : _catalog = catalog;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  Future<Validation<GameState>> fetch() => _store.loadAll().map(GameState.replay);

  /// Stato corrente; vuoto se il caricamento è fallito o non è finito.
  GameState get state => uiData.fold((_) => GameState.empty, (s) => s);

  DateTime get now => _clock.now();

  /// Salva un evento e lo applica allo stato. Se il salvataggio fallisce lo stato non cambia.
  Future<Validation<GameState>> record(GameEvent event) async {
    final saved = await _store.append(event);
    return saved.fold((failures) => Invalid<GameState>(failures), (event) {
      uiData = uiData.map((state) => state.apply(event));
      update();
      return uiData;
    });
  }

  /// Incontro con una specie. Se era tra le desiderata la missione è compiuta.
  Future<Validation<GameState>> encounter(String speciesSci, {required EncounterMethod method}) async {
    final wasDesired = state.desiderata.contains(speciesSci);
    final result = await record(SpeciesEncountered(speciesSci: speciesSci, method: method, occurredAt: now));
    if (!result.isValid || !wasDesired) return result;
    return record(DesiderataFulfilled(speciesSci: speciesSci, xp: XpRules.desiderataFulfilled, occurredAt: now));
  }

  /// Aggiunge o toglie una specie dalle desiderata. Restituisce `false` se si è già al massimo.
  Future<bool> toggleDesiderata(String speciesSci) async {
    final marked = state.desiderata.contains(speciesSci);
    if (!marked && !canAddDesiderata(state)) return false;
    final result = await record(DesiderataChanged(speciesSci: speciesSci, marked: !marked, occurredAt: now));
    return result.isValid;
  }

  /// Essenza attinta simulata (strumento di debug finché non c'è il campo).
  Future<void> drawSimulated(String speciesSci, {String? trait}) async {
    await record(EssenceDrawn(speciesSci: speciesSci, trait: trait, simulated: true, occurredAt: now));
    await checkMastery(speciesSci);
  }

  /// Registra la maestria se le condizioni sono appena state raggiunte.
  Future<void> checkMastery(String speciesSci) async {
    final catalog = _catalog();
    final species = catalog?.speciesBySci(speciesSci);
    if (species == null || state.mastered.contains(speciesSci)) return;
    if (masteryProgress(species, catalog!, state).reached) {
      await record(MasteryReached(speciesSci: speciesSci, xp: XpRules.mastery, occurredAt: now));
    }
  }

  /// Consegna la curiosità del giorno, se ce n'è una nuova.
  Future<void> revealTodayFunFact() async {
    final catalog = _catalog();
    if (catalog == null) return;
    final fact = funFactToRevealToday(catalog, state, now);
    if (fact != null) await record(FunFactRevealed(funFactId: fact.id, occurredAt: now));
  }

  Future<void> saveNote(String speciesSci, String text) {
    if ((state.notes[speciesSci] ?? '') == text) return Future.value();
    return record(NoteSaved(speciesSci: speciesSci, text: text, occurredAt: now));
  }

  Future<void> saveToNotebook(String factId) =>
      state.notebook.contains(factId) ? Future.value() : record(NotebookEntrySaved(factId: factId, occurredAt: now));

  Future<void> markOnboarding(OnboardingMark mark) =>
      state.onboardingMarks.contains(mark) ? Future.value() : record(OnboardingMarked(mark: mark, occurredAt: now));

  /// Strumento di debug: cancella tutti i progressi.
  Future<void> resetAll() async {
    await _store.clear();
    await load();
  }
}
