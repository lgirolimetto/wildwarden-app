import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/potion.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';

/// Usare una pozione (capitolo 02, "Una pozione si tiene o si usa"): l'effetto vale per 7 giorni, con la forza della
/// potenza (1–10); il Tocco aggiunge un piccolo effetto in più, che rinforza quello della pozione se è lo stesso.
/// Effetti sempre di gioco.

/// Giorni di un effetto (`use_effect_days` del simulatore).
const potionEffectDays = 7;

/// Forza dell'effetto in più del Tocco.
const touchStrength = 2;

/// La forza in corso di ogni effetto adesso: degli effetti uguali si sommano le forze, fino a 10.
Map<PotionEffect, int> activeEffects(GameState state, DateTime now) {
  final strength = <PotionEffect, int>{};
  for (final ActiveEffect e in state.effects) {
    if (!now.isBefore(e.until)) continue;
    strength[e.effect] = ((strength[e.effect] ?? 0) + e.strength).clamp(0, 10);
  }
  return strength;
}

/// Quando finisce l'ultimo effetto in corso di [effect] (`null` se non è in corso).
DateTime? effectUntil(GameState state, PotionEffect effect, DateTime now) => state.effects
    .where((e) => e.effect == effect && now.isBefore(e.until))
    .map((e) => e.until)
    .fold<DateTime?>(null, (latest, at) => latest == null || at.isAfter(latest) ? at : latest);

/// **Abbondanza**: Vis in più a ogni Essenza, il 5 % per punto di forza (forza 10 = +50 %, `use_effect_bonus` del
/// simulatore).
int visWithAbundance(int vis, int strength) => (vis * (1 + 0.05 * strength)).round();

/// **Limpidezza**: purezza in più a ogni Essenza, 2 punti per punto di forza, fino a 1,0.
double purityWithClarity(double purity, int strength) => (purity + 0.02 * strength).clamp(0.0, 1.0);

/// **Ricrescita**: la specie torna pronta prima; con forza 10 dopo 12 ore invece che il giorno dopo.
Duration regrowthWait(int strength) => Duration(minutes: ((24 - 1.2 * strength) * 60).round());

/// **Presagio**: probabilità che scatti a ogni Essenza, il 10 % per punto di forza.
double omenChance(int strength) => strength / 10;

/// **Presagio** su un'Essenza appena attinta (capitolo 02, 2026-10-29): se scatta ([roll] sotto [omenChance]),
/// l'Essenza prende la prima delle [affinities] della pianta che non ha già, in più alle sue Qualia; se le ha già
/// tutte, la purezza sale come con la Limpidezza della stessa forza. Prima valeva solo per un'Essenza senza Qualia, ma
/// la luna del giorno c'è sempre e non scattava mai.
({List<String> traits, double purity}) withOmen({
  required List<String> traits,
  required List<Trait> affinities,
  required double purity,
  required int strength,
  required double roll,
}) {
  if (roll >= omenChance(strength)) return (traits: traits, purity: purity);
  for (final a in affinities) {
    if (!traits.contains(a.name)) return (traits: [...traits, a.name], purity: purity);
  }
  return (traits: traits, purity: purityWithClarity(purity, strength));
}
