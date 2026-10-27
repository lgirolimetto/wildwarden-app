import 'package:druid_app/business_logic/models/essence.dart';

/// Essenze della Dispensa (capitolo 02, "Stazioni, Vis e uso delle pozioni"): la purezza e l'ordine in cui si spendono
/// le Vis.

/// Purezza di un'Essenza secondo il livello di studio della specie quando la attingi, da 0 (mai studiata) a 4
/// (maestria): più conosci la pianta, più l'Essenza è pura (`purity_by_level` del simulatore).
const purityByLevel = [0.4, 0.6, 0.75, 0.9, 1.0];

double purityOfLevel(int level) => purityByLevel[level.clamp(0, purityByLevel.length - 1)];

/// Ordine in cui si spendono le Vis quando la specie non conta (riciclo): prima le Essenze meno preziose, cioè con meno
/// tratti, poi meno pure, poi le più vecchie. Così le Essenze con i tratti rari restano per le ricette.
int compareBySpendOrder(Essence a, Essence b) {
  if (a.traits.length != b.traits.length) return a.traits.length.compareTo(b.traits.length);
  if (a.purity != b.purity) return a.purity.compareTo(b.purity);
  return a.index.compareTo(b.index);
}

/// Toglie [amount] Vis dalle Essenze di [speciesSci], nell'ordine di [compareBySpendOrder]. Le Essenze restano anche a
/// 0 Vis (la Dispensa non le mostra più).
List<Essence> spendVis(List<Essence> essences, String speciesSci, int amount) {
  final order = [
    for (final e in essences)
      if (e.speciesSci == speciesSci && e.vis > 0) e,
  ]..sort(compareBySpendOrder);
  final taken = <int, int>{};
  var left = amount;
  for (final e in order) {
    if (left <= 0) break;
    final take = e.vis < left ? e.vis : left;
    taken[e.index] = take;
    left -= take;
  }
  return [for (final e in essences) taken.containsKey(e.index) ? e.withVis(e.vis - taken[e.index]!) : e];
}
