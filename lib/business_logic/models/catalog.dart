import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/localized_text.dart';
import 'package:druid_app/business_logic/models/mythic.dart';
import 'package:druid_app/business_logic/models/species.dart';

/// Curiosità scritta a mano, legata a un livello di studio della specie.
/// `verified == false` finché qualcuno non l'ha controllata su una fonte.
class CuratedFunFact {
  final int level;
  final LocalizedText text;
  final bool verified;

  /// Le fonti della curiosità (capitolo 04, "sempre con le fonti").
  final List<SourceRef> sources;

  const CuratedFunFact({required this.level, required this.text, required this.verified, this.sources = const []});

  factory CuratedFunFact.fromJson(Map<String, dynamic> json) => CuratedFunFact(
    level: json['level'] as int,
    text: LocalizedText.fromJson(json['text'] as Map<String, dynamic>),
    verified: json['verified'] as bool,
    sources: sourcesFromJson(json['sources']),
  );
}

Map<String, List<SourceRef>> sourceMap(Object? json) => {
  for (final MapEntry(:key, :value) in ((json as Map<String, dynamic>?) ?? const {}).entries)
    key: sourcesFromJson(value),
};

List<SourceRef> sourcesFromJson(Object? json) => [
  for (final r in ((json as List?) ?? const []).cast<Map<String, dynamic>>()) SourceRef.fromJson(r),
];

/// Contenuti di gioco di una zona: specie, clima, Mitiche, lore, curiosità, avvisi di sicurezza. Le ricette ad
/// affissi non sono nel catalogo: le calcolano le regole (`rules/recipes/`).
class Catalog {
  /// 3: rarità della pianta, correzioni a mano, Mitiche e clima della Zona (tappa C).
  static const supportedFormatVersion = 3;

  final String regionId;

  /// Il paese del Ricettario (es. `it`): il Ricettario è nazionale e gli id delle ricette cominciano da qui.
  final String countryId;
  final LocalizedText regionName;

  /// Giorni al mese (indice 0 = gennaio) con ogni condizione meteo della Zona: sole, pioggia, nebbia, rugiada,
  /// gelo. Gli altri tratti (luce del giorno, luna) capitano ogni mese.
  final Map<Trait, List<double>> climate;
  final List<Species> species;

  /// Mitiche scritte a mano, in ordine di numero.
  final List<Mythic> mythics;
  final Map<String, LocalizedText> lore;
  final Map<String, List<CuratedFunFact>> funFacts;

  /// Avvisi di tossicità o irritazione, verificati con due fonti autorevoli indipendenti (capitolo 04).
  final Map<String, LocalizedText> safety;

  /// Le fonti degli avvisi e quelli verificati: un avviso non verificato si mostra "da verificare".
  final Map<String, List<SourceRef>> safetySources;
  final Set<String> safetyVerified;

  /// Le fonti dei fatti veri dentro la lore.
  final Map<String, List<SourceRef>> loreSources;

  /// Le aromatiche del tutorial da casa ("dalla cucina", blocco 2b): coltivate, fuori dalla Zona. Non entrano in
  /// [species] (Erbario della Zona, stagione, percentili, compagni delle ricette); si trovano con [speciesBySci].
  final List<Species> kitchen;

  /// Le aromatiche che sono Ospiti (non crescono spontanee in Italia, come il basilico).
  final Set<String> kitchenGuests;

  /// Da dove viene un'aromatica Ospite: il primo "non lo sapevo" del tutorial.
  final Map<String, LocalizedText> origins;

  /// Le fonti di [origins] (capitolo 04, "sempre con le fonti").
  final Map<String, List<SourceRef>> originSources;

  /// Nomi scientifici vecchi (in minuscolo, genere e specie) → il nome del catalogo: Pl@ntNet può rispondere con un
  /// sinonimo (es. "rosmarinus officinalis" → Salvia rosmarinus).
  final Map<String, String> synonyms;

  final Map<String, Species> _bySci;

  Catalog({
    required this.regionId,
    required this.countryId,
    required this.regionName,
    this.climate = const {},
    required this.species,
    this.mythics = const [],
    required this.lore,
    required this.funFacts,
    required this.safety,
    this.safetySources = const {},
    this.safetyVerified = const {},
    this.loreSources = const {},
    this.kitchen = const [],
    this.kitchenGuests = const {},
    this.origins = const {},
    this.originSources = const {},
    this.synonyms = const {},
  }) : _bySci = {
         for (final s in [...species, ...kitchen]) s.sci: s,
       };

  /// [kitchen]: il catalogo delle aromatiche del tutorial (`assets/content/kitchen/catalog.json`, da
  /// `tools/content-pipeline/kitchen.py`), facoltativo.
  factory Catalog.fromJson(Map<String, dynamic> json, {Map<String, dynamic>? kitchen}) {
    final version = json['formatVersion'] as int;
    if (version != supportedFormatVersion) {
      throw FormatException('Formato catalogo $version non supportato (atteso $supportedFormatVersion)');
    }
    final region = json['region'] as Map<String, dynamic>;
    Map<String, LocalizedText> texts(String key) => (json[key] as Map<String, dynamic>).map(
      (sci, text) => MapEntry(sci, LocalizedText.fromJson(text as Map<String, dynamic>)),
    );

    return Catalog(
      regionId: region['id'] as String,
      countryId: region['country'] as String,
      regionName: LocalizedText.fromJson(region['name'] as Map<String, dynamic>),
      climate: (json['climate'] as Map<String, dynamic>).map(
        (id, days) => MapEntry(Trait.values.byName(id), climateDays(days as List)),
      ),
      species: (json['species'] as List).map((s) => Species.fromJson(s as Map<String, dynamic>)).toList(),
      mythics: (json['mythics'] as List).map((m) => Mythic.fromJson(m as Map<String, dynamic>)).toList(),
      lore: texts('lore'),
      funFacts: (json['funFacts'] as Map<String, dynamic>).map(
        (sci, facts) =>
            MapEntry(sci, (facts as List).map((f) => CuratedFunFact.fromJson(f as Map<String, dynamic>)).toList()),
      ),
      safety: texts('safety'),
      safetySources: sourceMap(json['safetySources']),
      safetyVerified: {
        for (final MapEntry(:key, :value) in ((json['safetyVerified'] as Map<String, dynamic>?) ?? const {}).entries)
          if (value == true) key,
      },
      loreSources: sourceMap(json['loreSources']),
      kitchen: [
        for (final s in (kitchen?['species'] as List?) ?? const []) Species.fromJson(s as Map<String, dynamic>),
      ],
      kitchenGuests: {
        for (final s in ((kitchen?['species'] as List?) ?? const []).cast<Map<String, dynamic>>())
          if (s['guest'] == true) s['sci'] as String,
      },
      origins: {
        for (final s in ((kitchen?['species'] as List?) ?? const []).cast<Map<String, dynamic>>())
          if (s['origin'] case final Map<String, dynamic> origin) s['sci'] as String: LocalizedText.fromJson(origin),
      },
      synonyms: {
        for (final s in ((kitchen?['species'] as List?) ?? const []).cast<Map<String, dynamic>>())
          for (final synonym in ((s['synonyms'] as List?) ?? const []).cast<String>())
            synonym.toLowerCase(): s['sci'] as String,
      },
      originSources: {
        for (final s in ((kitchen?['species'] as List?) ?? const []).cast<Map<String, dynamic>>())
          if (s['originSources'] case final List<dynamic> sources)
            s['sci'] as String: [for (final r in sources.cast<Map<String, dynamic>>()) SourceRef.fromJson(r)],
      },
    );
  }

  /// Un'aromatica del tutorial ("dalla cucina").
  bool isKitchen(String sci) => kitchen.any((s) => s.sci == sci);

  Species? speciesBySci(String sci) => _bySci[sci];

  Species? speciesByGbifKey(int key) => [...species, ...kitchen].where((s) => s.gbifKey == key).firstOrNull;

  /// Specie della stessa famiglia presenti nel catalogo, esclusa quella indicata.
  List<Species> relativesOf(Species species) =>
      this.species.where((s) => s.family == species.family && s.sci != species.sci).toList();
}

/// Una fonte di un'affermazione del catalogo: il nome da mostrare e il link.
class SourceRef {
  final String name;
  final String url;

  const SourceRef({required this.name, required this.url});

  factory SourceRef.fromJson(Map<String, dynamic> json) =>
      SourceRef(name: json['name'] as String, url: json['url'] as String);
}

/// Le banche dati dei tratti per lo studio (oltre a WCVP, che ha la sua pagina POWO per specie): CC BY 4.0.
const traitDatasets = [
  SourceRef(name: 'EIVE 1.0', url: 'https://zenodo.org/records/7534792'),
  SourceRef(name: 'EuDiS', url: 'https://doi.org/10.3897/BDJ.11.e104079'),
];
