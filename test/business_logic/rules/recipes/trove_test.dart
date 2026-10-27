import 'dart:math';

import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/economy.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/business_logic/rules/recipes/trove.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  final catalog = smallCatalog();
  final book = recipeBookOf(catalog);
  final feb = DateTime(2027, 2, 1, 10);
  final malva = book.pageOf('Malva sylvestris')!;
  XpGranted rich([int xp = 100000]) => XpGranted(xp: xp, reason: 'debug', occurredAt: feb);
  TroveOpened opened(Grade grade, List<TroveFind> finds, {DateTime? at, int? price}) =>
      TroveOpened(grade: grade, price: price ?? EconomyRules.troveCost(grade), finds: finds, occurredAt: at ?? feb);
  EssenceDrawn drawn(DateTime at) => EssenceDrawn(speciesSci: 'Malva sylvestris', simulated: true, occurredAt: at);

  group('stato', () {
    test('il Bottino spende il saldo e conta per il limite del giorno', () {
      final state = GameState.replay([rich(1000), opened(Grade.common, const [])]);
      expect(state.balance, 850);
      expect(trovesToday(state, feb), 1);
      expect(trovesToday(state, feb.add(const Duration(days: 1))), 0);
    });

    test('una Tavola incompleta si completa con i suoi pezzi, i doppioni diventano riciclati', () {
      final rare = malva.recipes.last;
      final state = GameState.replay([
        rich(),
        opened(Grade.rare, [TroveFind(recipeId: rare.id, grade: Grade.rare, kind: TroveFindKind.recipe, missing: 2)]),
        opened(Grade.rare, [TroveFind(recipeId: rare.id, grade: Grade.rare, kind: TroveFindKind.piece)]),
      ]);
      expect(state.missingPieces, {rare.id: 1});
      expect(state.learnedRecipes, isEmpty);
      final done = GameState.replay([
        rich(),
        opened(Grade.rare, [TroveFind(recipeId: rare.id, grade: Grade.rare, kind: TroveFindKind.recipe, missing: 2)]),
        opened(Grade.rare, [TroveFind(recipeId: rare.id, grade: Grade.rare, kind: TroveFindKind.piece)]),
        opened(Grade.rare, [
          TroveFind(recipeId: rare.id, grade: Grade.rare, kind: TroveFindKind.piece),
          TroveFind(recipeId: malva.recipes.first.id, grade: Grade.common, kind: TroveFindKind.recycled),
        ]),
      ]);
      expect(done.missingPieces, isEmpty);
      expect(done.learnedRecipes.keys, [rare.id]);
      expect(done.recycled, {Grade.common: 1});
    });

    test('l\'evento si rilegge uguale dal database', () {
      final event = opened(Grade.uncommon, [
        const TroveFind(recipeId: 'x', grade: Grade.rare, kind: TroveFindKind.recipe, missing: 2, taste: true),
      ]);
      final back = GameEvent.decode(type: event.type, payload: event.encodePayload(), occurredAt: feb) as TroveOpened;
      expect(back.payload(), event.payload());
    });
  });

  group('apertura', () {
    test('al limite del giorno o senza saldo il Bottino non si apre', () {
      expect(troveBlock(GameState.replay([rich(100)]), Grade.common, feb), TroveBlock.balance);
      final three = GameState.replay([rich(), for (var i = 0; i < 3; i++) opened(Grade.common, const [])]);
      expect(troveBlock(three, Grade.common, feb), TroveBlock.dailyLimit);
      expect(troveBlock(GameState.replay([rich()]), Grade.mythic, feb), isNull);
    });

    test('il primo Bottino di un grado porta l\'assaggio del grado sopra, tutto da completare', () {
      final finds = openTroveFinds(
        grade: Grade.uncommon,
        catalog: catalog,
        state: GameState.replay([rich()]),
        random: Random(1),
      );
      final taste = finds.singleWhere((f) => f.taste);
      expect(taste.grade, Grade.rare);
      expect(taste.missing, 2);
      final again = GameState.replay([rich(), opened(Grade.uncommon, const [])]);
      for (var seed = 0; seed < 20; seed++) {
        final more = openTroveFinds(grade: Grade.uncommon, catalog: catalog, state: again, random: Random(seed));
        expect(more.where((f) => f.taste), isEmpty);
      }
    });

    test('il Bottino raro dà a volte una Mitica, con le sue 3 parole da trovare', () {
      final state = GameState.replay([rich(), opened(Grade.rare, const [])]);
      final mythics = [
        for (var seed = 0; seed < 200; seed++)
          ...openTroveFinds(grade: Grade.rare, catalog: catalog, state: state, random: Random(seed)),
      ].where((f) => f.grade == Grade.mythic);
      expect(mythics, isNotEmpty);
      expect(mythics.first.missing, 3);
      expect(mythics.first.recipeId, 'lanterna-santa-lucia');
    });

    test('una Tavola che hai già esce come riciclato', () {
      final common = malva.recipes.first;
      final state = GameState.replay([
        rich(),
        opened(Grade.common, const []),
        LevelPassed(speciesSci: 'Malva sylvestris', level: 1, xp: 0, occurredAt: feb),
      ]);
      final finds = [
        for (var seed = 0; seed < 300; seed++)
          ...openTroveFinds(grade: Grade.common, catalog: catalog, state: state, random: Random(seed)),
      ];
      expect(finds.where((f) => f.recipeId == common.id).map((f) => f.kind).toSet(), {TroveFindKind.recycled});
      expect(finds.where((f) => f.kind == TroveFindKind.recipe && f.grade == Grade.common), isNotEmpty);
    });

    test('con una Tavola incompleta circa 4 volte su 10 esce un suo pezzo', () {
      final uncommon = malva.recipes[1];
      final state = GameState.replay([
        rich(),
        opened(Grade.uncommon, [
          TroveFind(recipeId: uncommon.id, grade: Grade.uncommon, kind: TroveFindKind.recipe, missing: 1),
        ]),
      ]);
      final pieces = [
        for (var seed = 0; seed < 500; seed++)
          ...openTroveFinds(grade: Grade.uncommon, catalog: catalog, state: state, random: Random(seed)),
      ].where((f) => f.kind == TroveFindKind.piece);
      expect(pieces.length, inInclusiveRange(160, 240));
      expect(pieces.map((f) => f.recipeId).toSet(), {uncommon.id});
      // Il Bottino comune non dà pezzi di una Non comune.
      final low = [
        for (var seed = 0; seed < 100; seed++)
          ...openTroveFinds(grade: Grade.common, catalog: catalog, state: state, random: Random(seed)),
      ];
      expect(low.where((f) => f.kind == TroveFindKind.piece), isEmpty);
    });

    test('pesca soprattutto dalle piante che conosci', () {
      final state = GameState.replay([
        rich(),
        opened(Grade.common, const []),
        SpeciesEncountered(speciesSci: 'Fagus sylvatica', method: EncounterMethod.simulated, occurredAt: feb),
      ]);
      final fagus = book.pageOf('Fagus sylvatica')!.recipes.map((r) => r.id).toSet();
      final finds = [
        for (var seed = 0; seed < 400; seed++)
          ...openTroveFinds(grade: Grade.common, catalog: catalog, state: state, random: Random(seed)),
      ];
      final share = finds.where((f) => fagus.contains(f.recipeId)).length / finds.length;
      // 75 % dalle piante conosciute, più la sua parte del resto (1 pagina su 4).
      expect(share, inInclusiveRange(0.72, 0.88));
    });
  });

  group('regalo "bentornato"', () {
    final start = DateTime(2027, 1, 1);

    test('dopo 4 settimane a chi attinge poco e non ha un Bottino raro; una volta sola', () {
      final state = GameState.replay([drawn(start)]);
      expect(welcomeGiftDue(state, start.add(const Duration(days: 27))), isFalse);
      expect(welcomeGiftDue(state, start.add(const Duration(days: 28))), isTrue);
      final offered = state.apply(WelcomeGiftOffered(occurredAt: start.add(const Duration(days: 28))));
      expect(welcomeGiftDue(offered, start.add(const Duration(days: 60))), isFalse);
    });

    test('a chi attinge tanto o ha già un Bottino raro non arriva', () {
      final busy = GameState.replay([for (var d = 0; d < 30; d++) drawn(start.add(Duration(days: d)))]);
      expect(welcomeGiftDue(busy, start.add(const Duration(days: 30))), isFalse);
      final rare = GameState.replay([drawn(start), rich(), opened(Grade.rare, const [], at: start)]);
      expect(welcomeGiftDue(rare, start.add(const Duration(days: 30))), isFalse);
    });

    test('si riscatta solo dopo un\'Essenza attinta da quando è arrivato', () {
      final at = start.add(const Duration(days: 28));
      final offered = GameState.replay([drawn(start), WelcomeGiftOffered(occurredAt: at)]);
      expect(welcomeGiftOf(offered), WelcomeGift.waitingForEssence);
      final ready = offered.apply(drawn(at.add(const Duration(hours: 2))));
      expect(welcomeGiftOf(ready), WelcomeGift.ready);
      final redeemed = ready.apply(
        TroveOpened(
          grade: Grade.rare,
          price: EconomyRules.welcomeTrovePrice,
          gift: true,
          finds: const [],
          occurredAt: at,
        ),
      );
      expect(welcomeGiftOf(redeemed), WelcomeGift.none);
    });
  });
}
