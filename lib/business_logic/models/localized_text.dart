/// Testo di contenuto in più lingue (nomi delle specie, lore, ricette…).
///
/// I contenuti nascono in italiano: se manca la lingua richiesta si ripiega
/// sull'italiano, e in ultima istanza sulla prima lingua disponibile.
class LocalizedText {
  static const fallbackLanguage = 'it';

  final Map<String, String> _values;

  const LocalizedText(this._values);

  factory LocalizedText.fromJson(Map<String, dynamic> json) =>
      LocalizedText(json.map((lang, text) => MapEntry(lang, text as String)));

  String resolve(String languageCode) => _values[languageCode] ?? _values[fallbackLanguage] ?? _values.values.first;

  @override
  bool operator ==(Object other) =>
      other is LocalizedText &&
      other._values.length == _values.length &&
      other._values.entries.every((e) => _values[e.key] == e.value);

  @override
  int get hashCode => Object.hashAllUnordered(_values.entries.map((e) => Object.hash(e.key, e.value)));
}
