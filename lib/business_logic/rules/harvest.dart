import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/potion_effects.dart';

/// Raccolta: quanta Vis si immagazzina e quando una specie si può attingere di nuovo.
///
/// Senza stazioni vere (blocchi 2-3) la regola "una raccolta al giorno per stazione" vale per specie. I numeri sono
/// provvisori: si tarano con il simulatore dell'economia (capitolo 02, "Stazioni, Vis e uso delle pozioni").
const visPerDraw = 10;

/// Si attinge solo da una specie incontrata (serve una stazione) e al massimo una volta al giorno; con la Ricrescita
/// in corso anche prima, passate le ore di [regrowthWait].
bool canDraw(GameState state, String speciesSci, DateTime now) =>
    state.hasEncountered(speciesSci) && !isExhausted(state, speciesSci, now);

/// La specie è esaurita: attinta oggi, torna pronta domani (o prima, con la Ricrescita).
bool isExhausted(GameState state, String speciesSci, DateTime now) {
  final last = state.lastDraws[speciesSci];
  if (last == null || !_sameDay(last, now)) return false;
  final regrowth = activeEffects(state, now)[PotionEffect.regrowth];
  return regrowth == null || now.difference(last) < regrowthWait(regrowth);
}

/// Essenze attinte oggi: una al giorno per specie, quindi le specie attinte oggi.
int drawsToday(GameState state, DateTime now) => state.lastDraws.values.where((last) => _sameDay(last, now)).length;

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
