import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/rules/economy.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/trove.dart';

/// Riciclo dei doppioni (capitolo 02, "Ricette ad affissi e pagine per pianta"): ogni doppione uscito dal Bottino è un
/// riciclato del suo grado; 3 riciclati fanno un componente dello stesso grado, 9 uno del grado sopra, a scelta tra le
/// tue Tavole incomplete, pagando un po' di Vis di qualsiasi specie.

/// Un modo di riciclare per una Tavola incompleta: con [used] riciclati di [fromGrade].
class RecycleOption {
  final String recipeId;

  /// Grado della Tavola (e del componente).
  final Grade grade;
  final Grade fromGrade;
  final int used;

  /// Vis che costa.
  final int visCost;

  const RecycleOption({
    required this.recipeId,
    required this.grade,
    required this.fromGrade,
    required this.used,
    required this.visCost,
  });

  /// Con 9 riciclati del grado sotto.
  bool get gradeUp => fromGrade != grade;
}

/// Vis in tutto, di tutte le specie.
int totalVis(GameState state) => state.vis.values.fold(0, (a, b) => a + b);

/// I modi di riciclare per le tue Tavole incomplete, per Tavola nell'ordine in cui le hai trovate: con 3 riciclati
/// del suo grado e con 9 del grado sotto, se li hai. Non guarda le Vis: si vede cosa servirebbe.
List<RecycleOption> recycleOptions(Catalog catalog, GameState state) => [
  for (final id in state.missingPieces.keys)
    if (recipeGrade(catalog, id) case final Grade grade) ...[
      if ((state.recycled[grade] ?? 0) >= EconomyRules.recycleSameGrade)
        RecycleOption(
          recipeId: id,
          grade: grade,
          fromGrade: grade,
          used: EconomyRules.recycleSameGrade,
          visCost: EconomyRules.recycleVisCost(grade),
        ),
      if (grade != Grade.common && (state.recycled[Grade.values[grade.index - 1]] ?? 0) >= EconomyRules.recycleGradeUp)
        RecycleOption(
          recipeId: id,
          grade: grade,
          fromGrade: Grade.values[grade.index - 1],
          used: EconomyRules.recycleGradeUp,
          visCost: EconomyRules.recycleVisCost(grade),
        ),
    ],
];

/// Le Vis da spendere per [amount], prese dalle specie che ne hanno di più (a pari Vis in ordine di nome); `null` se
/// non bastano.
Map<String, int>? visToSpend(GameState state, int amount) {
  final stocks = state.vis.entries.where((e) => e.value > 0).toList()
    ..sort((a, b) => b.value != a.value ? b.value.compareTo(a.value) : a.key.compareTo(b.key));
  final taken = <String, int>{};
  var left = amount;
  for (final MapEntry(key: sci, value: available) in stocks) {
    if (left <= 0) break;
    final take = available < left ? available : left;
    taken[sci] = take;
    left -= take;
  }
  return left > 0 ? null : taken;
}
