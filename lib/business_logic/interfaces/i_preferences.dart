/// Preferenze locali semplici (tema, livrea…). Non è il posto per i progressi di gioco.
abstract interface class IPreferences {
  String? getString(String key);

  Future<void> setString(String key, String value);
}
