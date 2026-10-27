import 'package:druid_app/business_logic/models/localized_text.dart';
import 'package:druid_app/business_logic/models/mythic.dart';
import 'package:druid_app/business_logic/models/recipe.dart';
import 'package:druid_app/business_logic/models/species.dart';

/// Curiosità scritta a mano, legata a un livello di studio della specie.
/// `verified == false` finché qualcuno non l'ha controllata su una fonte.
class CuratedFunFact {
  final int level;
  final LocalizedText text;
  final bool verified;

  const CuratedFunFact({required this.level, required this.text, required this.verified});

  factory CuratedFunFact.fromJson(Map<String, dynamic> json) => CuratedFunFact(
    level: json['level'] as int,
    text: LocalizedText.fromJson(json['text'] as Map<String, dynamic>),
    verified: json['verified'] as bool,
  );
}

/// Contenuti di gioco di una zona: specie, ricette, lore, curiosità, avvisi di sicurezza.
class Catalog {
  /// 3: rarità della pianta, correzioni a mano e Mitiche (tappa C).
  static const supportedFormatVersion = 3;

  final String regionId;
  final LocalizedText regionName;
  final List<Species> species;
  final List<Recipe> recipes;

  /// Mitiche scritte a mano, in ordine di numero.
  final List<Mythic> mythics;
  final Map<String, LocalizedText> lore;
  final Map<String, List<CuratedFunFact>> funFacts;

  /// Avvisi di tossicità o irritazione. ⚠️ Vanno verificati a mano su fonti autorevoli.
  final Map<String, LocalizedText> safety;

  final Map<String, Species> _bySci;

  Catalog({
    required this.regionId,
    required this.regionName,
    required this.species,
    required this.recipes,
    this.mythics = const [],
    required this.lore,
    required this.funFacts,
    required this.safety,
  }) : _bySci = {for (final s in species) s.sci: s};

  factory Catalog.fromJson(Map<String, dynamic> json) {
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
      regionName: LocalizedText.fromJson(region['name'] as Map<String, dynamic>),
      species: (json['species'] as List).map((s) => Species.fromJson(s as Map<String, dynamic>)).toList(),
      recipes: (json['recipes'] as List).map((r) => Recipe.fromJson(r as Map<String, dynamic>)).toList(),
      mythics: (json['mythics'] as List).map((m) => Mythic.fromJson(m as Map<String, dynamic>)).toList(),
      lore: texts('lore'),
      funFacts: (json['funFacts'] as Map<String, dynamic>).map(
        (sci, facts) =>
            MapEntry(sci, (facts as List).map((f) => CuratedFunFact.fromJson(f as Map<String, dynamic>)).toList()),
      ),
      safety: texts('safety'),
    );
  }

  Species? speciesBySci(String sci) => _bySci[sci];

  /// Specie della stessa famiglia presenti nel catalogo, esclusa quella indicata.
  List<Species> relativesOf(Species species) =>
      this.species.where((s) => s.family == species.family && s.sci != species.sci).toList();
}
