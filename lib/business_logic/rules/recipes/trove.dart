import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/economy.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';

/// Bottino dell'Esperienza (capitolo 02): si compra con il saldo dei PE e il grado decide quanto vale ciò che esce.
/// Il caso sta qui, il risultato si salva nell'evento `TroveOpened` e non si ricalcola più.

/// Bottini aperti oggi.
int trovesToday(GameState state, DateTime now) => state.troves.where((t) => _sameDay(t.$2, now)).length;

/// Perché un Bottino non si può aprire; `null` se si può.
enum TroveBlock { balance, dailyLimit }

TroveBlock? troveBlock(GameState state, Grade grade, DateTime now, {bool gift = false}) {
  if (trovesToday(state, now) >= EconomyRules.trovesPerDay) return TroveBlock.dailyLimit;
  final price = gift ? EconomyRules.welcomeTrovePrice : EconomyRules.troveCost(grade);
  return state.balance < price ? TroveBlock.balance : null;
}

/// Hai già un Bottino raro (o mitico): il regalo "bentornato" non serve più.
bool _hasRareTrove(GameState state) => state.troves.any((t) => t.$1.index >= Grade.rare.index);

/// Il regalo "bentornato" va offerto adesso: dopo 4 settimane di gioco, a chi non ha un Bottino raro e attinge poco.
/// Si offre una volta sola.
bool welcomeGiftDue(GameState state, DateTime now) {
  final started = state.startedAt;
  if (started == null || state.welcomeOfferedAt != null || _hasRareTrove(state)) return false;
  if (now.difference(started).inDays < EconomyRules.welcomeAfterDays) return false;
  final since = now.subtract(const Duration(days: 28));
  return state.essenceTimes.where((t) => t.isAfter(since)).length < EconomyRules.welcomeIfEssencesBelow;
}

/// Stato del regalo "bentornato" per la pagina del Bottino.
enum WelcomeGift { none, waitingForEssence, ready }

/// Offerto e non ancora riscattato: si riscatta solo dopo un'Essenza attinta da quando è arrivato.
WelcomeGift welcomeGiftOf(GameState state) {
  final offered = state.welcomeOfferedAt;
  if (offered == null || state.welcomeRedeemed || _hasRareTrove(state)) return WelcomeGift.none;
  return state.essenceTimes.any((t) => !t.isBefore(offered)) ? WelcomeGift.ready : WelcomeGift.waitingForEssence;
}

/// Grado di una ricetta del Ricettario o di una Mitica; `null` se l'id non esiste più.
Grade? recipeGrade(Catalog catalog, String recipeId) {
  if (catalog.mythics.any((m) => m.id == recipeId)) return Grade.mythic;
  return recipeBookOf(catalog).recipeById(recipeId)?.grade;
}

/// Apre un Bottino di [grade]: un pezzo di una Tavola incompleta (con [EconomyRules.trovePieceChance], se ce n'è una
/// del grado del Bottino o più bassa) oppure una Tavola del grado tirato a sorte, nuova o doppione. Al primo Bottino di
/// un grado si aggiunge l'assaggio del grado sopra, una Tavola tutta da completare.
List<TroveFind> openTroveFinds({
  required Grade grade,
  required Catalog catalog,
  required GameState state,
  required Random random,
}) {
  final finds = <TroveFind>[];
  final owned = ownedRecipeIds(catalog, state);
  final incomplete = [
    for (final id in state.missingPieces.keys)
      if ((recipeGrade(catalog, id)?.index ?? 99) <= grade.index) id,
  ]..sort();
  if (incomplete.isNotEmpty && random.nextDouble() < EconomyRules.trovePieceChance) {
    final id = incomplete[random.nextInt(incomplete.length)];
    finds.add(TroveFind(recipeId: id, grade: recipeGrade(catalog, id)!, kind: TroveFindKind.piece));
  } else {
    final found = _rollGrade(EconomyRules.troveContents(grade), random);
    final id = _pickRecipe(found, catalog, state, owned, random);
    if (id != null) finds.add(_findOf(id, found, owned));
  }
  final firstOfGrade = !state.troves.any((t) => t.$1 == grade);
  if (firstOfGrade && grade != Grade.mythic) {
    final above = Grade.values[grade.index + 1];
    final taken = {for (final f in finds) f.recipeId};
    final id = _pickRecipe(above, catalog, state, owned, random, onlyNew: true, exclude: taken);
    if (id != null) {
      finds.add(
        TroveFind(
          recipeId: id,
          grade: above,
          kind: TroveFindKind.recipe,
          missing: EconomyRules.missingPiecesWhenFound(above),
          taste: true,
        ),
      );
    }
  }
  return finds;
}

Grade _rollGrade(Map<Grade, double> weights, Random random) {
  var roll = random.nextDouble() * weights.values.fold(0.0, (a, b) => a + b);
  for (final MapEntry(key: grade, value: weight) in weights.entries) {
    roll -= weight;
    if (roll < 0) return grade;
  }
  return weights.keys.last;
}

/// Le Tavole che hai: complete (anche la Comune di una pianta studiata e le Mitiche) o incomplete.
Set<String> ownedRecipeIds(Catalog catalog, GameState state) => {
  ...knownRecipeIds(catalog, state),
  ...state.learnedRecipes.keys,
  ...state.missingPieces.keys,
};

TroveFind _findOf(String id, Grade grade, Set<String> owned) => owned.contains(id)
    ? TroveFind(recipeId: id, grade: grade, kind: TroveFindKind.recycled)
    : TroveFind(
        recipeId: id,
        grade: grade,
        kind: TroveFindKind.recipe,
        missing: EconomyRules.missingPiecesWhenFound(grade),
      );

/// Una ricetta di [grade]: le Mitiche della Zona, oppure una Tavola di una pagina, per lo più delle piante che
/// conosci. Con [onlyNew] solo tra quelle che non hai (`null` se le hai tutte).
String? _pickRecipe(
  Grade grade,
  Catalog catalog,
  GameState state,
  Set<String> owned,
  Random random, {
  bool onlyNew = false,
  Set<String> exclude = const {},
}) {
  bool allowed(String id) => !exclude.contains(id) && (!onlyNew || !owned.contains(id));
  if (grade == Grade.mythic) {
    final ids = [
      for (final m in catalog.mythics)
        if (allowed(m.id)) m.id,
    ];
    return ids.isEmpty ? null : ids[random.nextInt(ids.length)];
  }
  final all = [
    for (final page in recipeBookOf(catalog).pages)
      for (final r in page.recipes)
        if (r.grade == grade && allowed(r.id)) (sci: page.plant.sci, id: r.id),
  ];
  if (all.isEmpty) return null;
  final known = [
    for (final r in all)
      if (state.hasEncountered(r.sci) || state.levelOf(r.sci) > 0) r,
  ];
  final pool = known.isNotEmpty && random.nextDouble() < EconomyRules.troveKnownPlantsShare ? known : all;
  return pool[random.nextInt(pool.length)].id;
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
