import 'package:druid_app/business_logic/interfaces/i_clock.dart';
import 'package:druid_app/business_logic/interfaces/i_preferences.dart';
import 'package:druid_app/business_logic/rules/did_you_know.dart';
import 'package:get/get.dart';

/// Quali "Lo sapevi che…" hai già visto e quando è comparso l'ultimo: nelle preferenze (non è gioco).
class DidYouKnowController extends GetxController {
  static const seenKey = 'did_you_know_seen';
  static const lastKey = 'did_you_know_last';

  final IPreferences _preferences;
  final IClock _clock;

  /// Spenti nei test delle pagine: il toast coprirebbe i tocchi.
  final bool enabled;

  DidYouKnowController(this._preferences, this._clock, {this.enabled = true});

  Set<DidYouKnow> get seen => {
    for (final name in (_preferences.getString(seenKey) ?? '').split(',')) ?DidYouKnow.values.asNameMap()[name],
  };

  /// Quello di oggi, se c'è: lo segna come visto.
  Future<DidYouKnow?> today() async {
    if (!enabled) return null;
    final last = DateTime.tryParse(_preferences.getString(lastKey) ?? '');
    var seen = this.seen;
    // Visti tutti: si ricomincia.
    if (seen.length == DidYouKnow.values.length) seen = {};
    final tip = didYouKnowToday(seen: seen, lastShown: last, now: _clock.now());
    if (tip != null) await _remember(seen, tip);
    return tip;
  }

  /// Una regola entra in gioco per la prima volta: il suo avviso compare subito (null se l'hai già visto).
  Future<DidYouKnow?> firstTime(DidYouKnow tip) async {
    if (!enabled) return null;
    final seen = this.seen;
    if (seen.contains(tip)) return null;
    await _remember(seen, tip);
    return tip;
  }

  Future<void> _remember(Set<DidYouKnow> seen, DidYouKnow tip) async {
    await _preferences.setString(seenKey, {...seen, tip}.map((t) => t.name).join(','));
    await _preferences.setString(lastKey, _clock.now().toIso8601String());
  }
}
