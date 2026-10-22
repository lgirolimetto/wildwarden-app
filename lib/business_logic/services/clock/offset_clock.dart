import 'package:druid_app/business_logic/interfaces/i_clock.dart';
import 'package:druid_app/business_logic/interfaces/i_preferences.dart';

/// Orologio con uno scostamento in giorni, salvato nelle preferenze: serve a provare ripassi e curiosità
/// sul simulatore ("fai passare i giorni"). Usato solo con gli strumenti di debug.
class OffsetClock implements IClock {
  static const offsetKey = 'debug.clockOffsetDays';

  final IClock _base;
  final IPreferences _preferences;

  OffsetClock(this._base, this._preferences);

  int get offsetDays => int.tryParse(_preferences.getString(offsetKey) ?? '') ?? 0;

  @override
  DateTime now() {
    final real = _base.now();
    return DateTime(real.year, real.month, real.day + offsetDays, real.hour, real.minute, real.second);
  }

  Future<void> advanceDays(int days) => _preferences.setString(offsetKey, '${offsetDays + days}');

  Future<void> reset() => _preferences.setString(offsetKey, '0');
}
