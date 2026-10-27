import 'dart:math';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_clock.dart';
import 'package:druid_app/business_logic/interfaces/i_game_event_store.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/economy.dart';
import 'package:druid_app/business_logic/rules/essences.dart';
import 'package:druid_app/business_logic/rules/fun_facts.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/harvest.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/business_logic/rules/recipes/recycling.dart';
import 'package:druid_app/business_logic/rules/recipes/trove.dart';
import 'package:druid_app/business_logic/rules/study/xp_rules.dart';
import 'package:druid_app/controllers/base/loadable_controller.dart';

/// Progressi del giocatore: legge il registro degli eventi all'avvio e lo aggiorna a ogni azione.
/// Ogni azione di gioco passa da qui e diventa un evento.
class ProgressController extends LoadableController<GameState> {
  final IGameEventStore _store;
  final IClock _clock;

  /// Catalogo corrente (serve per maestria e curiosità); `null` se non è ancora caricato.
  final Catalog? Function() _catalog;

  /// Il caso del Bottino dell'Esperienza (nei test un seme fisso).
  final Random _random;

  ProgressController(this._store, this._clock, {required Catalog? Function() catalog, Random? random})
    : _catalog = catalog,
      _random = random ?? Random();

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

  /// Essenza attinta simulata (strumento di debug finché non c'è il campo): immagazzina Vis, dà PE e, se è la
  /// prima della specie, incassa i suoi PE virtuali. Restituisce `false` se oggi la specie è già stata attinta o non
  /// è ancora incontrata.
  Future<bool> drawSimulated(String speciesSci, {List<String> traits = const []}) async {
    if (!canDraw(state, speciesSci, now)) return false;
    await record(
      EssenceDrawn(
        speciesSci: speciesSci,
        traits: traits,
        simulated: true,
        vis: visPerDraw,
        purity: purityOfLevel(state.levelOf(speciesSci)),
        xp: XpRules.essence(drawnToday: drawsToday(state, now)),
        occurredAt: now,
      ),
    );
    await checkMastery(speciesSci);
    return true;
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

  /// Compra e apre un Bottino dell'Esperienza di [grade] (con [gift] il regalo "bentornato": raro, a prezzo di
  /// favore). Restituisce cosa è uscito, o `null` se non si può aprire (saldo, limite del giorno, regalo non pronto).
  Future<List<TroveFind>?> openTrove(Grade grade, {bool gift = false}) async {
    final catalog = _catalog();
    if (catalog == null || troveBlock(state, grade, now, gift: gift) != null) return null;
    if (gift && (grade != Grade.rare || welcomeGiftOf(state) != WelcomeGift.ready)) return null;
    final finds = openTroveFinds(grade: grade, catalog: catalog, state: state, random: _random);
    final price = gift ? EconomyRules.welcomeTrovePrice : EconomyRules.troveCost(grade);
    final result = await record(TroveOpened(grade: grade, price: price, gift: gift, finds: finds, occurredAt: now));
    return result.isValid ? finds : null;
  }

  /// Ricicla per la Tavola incompleta di [option]: spende i riciclati e le Vis (dalle specie che ne hanno di più) e
  /// aggiunge un componente. Restituisce `false` se non si può (riciclati o Vis che non bastano).
  Future<bool> recycle(RecycleOption option) async {
    final catalog = _catalog();
    if (catalog == null) return false;
    final available = recycleOptions(
      catalog,
      state,
    ).any((o) => o.recipeId == option.recipeId && o.fromGrade == option.fromGrade && o.used == option.used);
    final vis = visToSpend(state, option.visCost);
    if (!available || vis == null) return false;
    final result = await record(
      RecipeRecycled(
        recipeId: option.recipeId,
        fromGrade: option.fromGrade,
        used: option.used,
        vis: vis,
        occurredAt: now,
      ),
    );
    return result.isValid;
  }

  /// Offre il regalo "bentornato" se è il momento (una volta sola).
  Future<void> offerWelcomeGiftIfDue() async {
    if (welcomeGiftDue(state, now)) await record(WelcomeGiftOffered(occurredAt: now));
  }

  /// Strumento di prova: una Dispensa piena, per vedere le Essenze e preparare pozioni senza uscire. Per 10 piante
  /// (prima quelle delle Pagine del Ricettario) le incontra, se serve, e attinge da 2 a 4 Essenze nei giorni scorsi,
  /// spesso con uno o due dei tratti d'elezione della pianta. Sempre le stesse (seme fisso). Restituisce quante.
  Future<int> simulatePantry() async {
    final catalog = _catalog();
    if (catalog == null) return 0;
    final random = Random(31);
    final book = recipeBookOf(catalog);
    final collected = collectedPages(catalog, state).map((p) => p.page);
    final pages = [...collected, ...book.pages.where((p) => !collected.contains(p))].take(10).toList();
    var drawn = 0;
    for (final (i, page) in pages.indexed) {
      final sci = page.plant.sci;
      if (!state.hasEncountered(sci)) {
        await record(
          SpeciesEncountered(
            speciesSci: sci,
            method: EncounterMethod.simulated,
            occurredAt: now.subtract(Duration(days: 20 + i)),
          ),
        );
      }
      final count = 2 + random.nextInt(3);
      for (var j = 0; j < count; j++) {
        final traits = [...page.favouredTraits]..shuffle(random);
        await record(
          EssenceDrawn(
            speciesSci: sci,
            traits: [for (final t in traits.take(random.nextInt(3))) t.name],
            simulated: true,
            vis: visPerDraw,
            purity: purityOfLevel(state.levelOf(sci)),
            occurredAt: now.subtract(Duration(days: 1 + j * 3 + i % 3, hours: i)),
          ),
        );
        drawn++;
      }
    }
    return drawn;
  }

  /// Strumento di prova: PE da spendere nel Bottino senza giocare settimane.
  Future<void> grantDebugXp(int xp) => record(XpGranted(xp: xp, reason: 'debug', occurredAt: now));

  /// Strumento di prova: un Ricettario fitto, per vedere indice, Pagine e navigazione senza giocare settimane. Impara
  /// le Tavole di 30 piante (tutte le Comuni, circa metà delle altre, 3 Pagine complete) e la prima Mitica, come se
  /// venissero dal Bottino, in giorni diversi. Sempre le stesse (seme fisso). Restituisce quante Tavole ha aggiunto.
  Future<int> simulateRecipeBook() async {
    final catalog = _catalog();
    if (catalog == null) return 0;
    final random = Random(27);
    final pages = [...recipeBookOf(catalog).pages]..shuffle(random);
    final ids = <String>[
      for (final (i, page) in pages.take(30).indexed)
        for (final (j, recipe) in page.recipes.indexed)
          if (j == 0 || i < 3 || random.nextDouble() < 0.45) recipe.id,
      ?catalog.mythics.firstOrNull?.id,
    ];
    var added = 0;
    for (final (i, id) in ids.indexed) {
      if (state.learnedRecipes.containsKey(id)) continue;
      final at = now.subtract(Duration(hours: ids.length - i));
      await record(RecipeLearned(recipeId: id, origin: RecipeOrigin.trove, occurredAt: at));
      added++;
    }
    return added;
  }

  /// Strumento di debug: cancella tutti i progressi.
  Future<void> resetAll() async {
    await _store.clear();
    await load();
  }
}
