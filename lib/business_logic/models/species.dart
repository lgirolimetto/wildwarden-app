import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/localized_text.dart';
import 'package:druid_app/business_logic/models/species_traits.dart';

/// Foto di riferimento di una specie, sempre con licenza CC0 o CC BY 4.0 verificata sulla singola foto.
class SpeciesImage {
  final String url;
  final String creator;
  final String license;
  final int gbifOccurrence;

  /// `true` se la foto è stata scattata nella zona del catalogo.
  final bool local;

  const SpeciesImage({
    required this.url,
    required this.creator,
    required this.license,
    required this.gbifOccurrence,
    required this.local,
  });

  factory SpeciesImage.fromJson(Map<String, dynamic> json) => SpeciesImage(
    url: json['url'] as String,
    creator: json['creator'] as String,
    license: json['license'] as String,
    gbifOccurrence: json['gbifOccurrence'] as int,
    local: json['local'] as bool,
  );
}

/// La specie in tutto il paese (il Ricettario è nazionale: capitolo 02, "Ricettario, Tavole, Laboratorio e Zone"):
/// stagionalità e clima dei posti dove è osservata. Decidono i tratti d'elezione della sua pagina.
class NationalData {
  /// Peso relativo di ogni mese in tutto il paese (indice 0 = gennaio), corretto per l'attività degli osservatori.
  final List<double> monthsRelative;

  /// Giorni al mese con sole, pioggia, nebbia, rugiada e gelo nei posti dove la specie è osservata.
  final Map<Trait, List<double>> climate;

  const NationalData({required this.monthsRelative, required this.climate});

  factory NationalData.fromJson(Map<String, dynamic> json) => NationalData(
    monthsRelative: (json['monthsRelative'] as List).map((v) => (v as num).toDouble()).toList(),
    climate: (json['climate'] as Map<String, dynamic>).map(
      (id, days) => MapEntry(Trait.values.byName(id), climateDays(days as List)),
    ),
  );
}

/// Giorni al mese di una condizione meteo, dal JSON del catalogo.
List<double> climateDays(List<dynamic> days) => [for (final d in days) (d as num).toDouble()];

/// Specie del catalogo di una zona, con i dati ricavati dalle osservazioni GBIF.
class Species {
  /// Nome scientifico: è la chiave stabile della specie in tutta l'app.
  final String sci;

  /// Chiave della specie in GBIF: lega le risposte di Pl@ntNet alla specie anche quando il nome è un sinonimo.
  final int? gbifKey;
  final LocalizedText name;

  /// Ordine tassonomico (es. Malvales); `null` se il catalogo non ce l'ha.
  final String? order;
  final String family;
  final String genus;

  /// Specie vere dello stesso genere osservate in Italia, anche fuori dal catalogo: risposte plausibili alla
  /// domanda sul nome scientifico.
  final List<String> congeners;
  final int observations;

  /// Peso relativo di ogni mese (indice 0 = gennaio), già corretto per l'attività degli osservatori.
  final List<double> monthsRelative;

  /// Mesi (1-12) in cui la specie si osserva di più.
  final List<int> bestMonths;
  final Map<Season, double> seasonShare;
  final Season peakSeason;
  final double? elevationMedian;
  final int elevationSamples;
  final Map<AltitudeBand, double> bandShare;
  final List<SpeciesImage> images;

  /// Tinta pastello (0xRRGGBB) che sostituisce la foto finché la specie non è incontrata: il colore più
  /// caratteristico della foto (fiore, bacca…), calcolato dalla pipeline dei contenuti. `null` se manca.
  final int? mysteryColor;

  /// Tratti per lo studio (forma, ciclo, ecologia, semi); vuoti se il catalogo non li ha.
  final SpeciesTraits traits;

  /// Fonti di legge che proteggono la specie nella zona (es. `regional-emilia-romagna`, `habitats-annex-v`); vuoto se
  /// nessuna delle liste ufficiali della pipeline la protegge.
  final List<String> protection;

  /// Rarità della pianta nella Zona, dalle osservazioni: poche osservazioni = difficile da raggiungere (capitolo 02,
  /// 2026-10-27). Decide la pagina del Ricettario e i compagni delle ricette.
  final Grade grade;

  /// Tratti d'elezione e vocazione corretti a mano (porta di servizio di `extras.json`); `null` = li calcola la
  /// regola delle ricette.
  final List<Trait>? favouredTraits;
  final List<PotionEffect>? vocation;

  /// Solo per le aromatiche del tutorial: il compagno della loro Non comune (capitolo 03, 2026-10-29); le piante della
  /// Zona prendono i compagni dall'habitat.
  final String? companion;

  /// La specie in tutto il paese; `null` se la pipeline non l'ha calcolata (le regole usano allora i dati della Zona).
  final NationalData? national;

  const Species({
    required this.sci,
    this.gbifKey,
    required this.name,
    this.order,
    required this.family,
    required this.genus,
    this.congeners = const [],
    required this.observations,
    required this.monthsRelative,
    required this.bestMonths,
    required this.seasonShare,
    required this.peakSeason,
    required this.elevationMedian,
    required this.elevationSamples,
    required this.bandShare,
    required this.images,
    this.mysteryColor,
    this.traits = SpeciesTraits.none,
    this.protection = const [],
    this.grade = Grade.common,
    this.favouredTraits,
    this.vocation,
    this.companion,
    this.national,
  });

  factory Species.fromJson(Map<String, dynamic> json) => Species(
    sci: json['sci'] as String,
    gbifKey: json['gbifKey'] as int?,
    name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
    order: json['order'] as String?,
    family: json['family'] as String,
    genus: json['genus'] as String,
    congeners: (json['congeners'] as List?)?.cast<String>() ?? const [],
    observations: json['observations'] as int,
    monthsRelative: (json['monthsRelative'] as List).map((v) => (v as num).toDouble()).toList(),
    bestMonths: (json['bestMonths'] as List).cast<int>(),
    seasonShare: (json['seasonShare'] as Map<String, dynamic>).map(
      (id, share) => MapEntry(Season.fromId(id), (share as num).toDouble()),
    ),
    peakSeason: Season.fromId(json['peakSeason'] as String),
    elevationMedian: (json['elevationMedian'] as num?)?.toDouble(),
    elevationSamples: json['elevationSamples'] as int,
    bandShare: (json['bandShare'] as Map<String, dynamic>).map(
      (id, share) => MapEntry(AltitudeBand.fromId(id), (share as num).toDouble()),
    ),
    images: (json['images'] as List).map((i) => SpeciesImage.fromJson(i as Map<String, dynamic>)).toList(),
    mysteryColor: _parseHexColor(json['mysteryColor'] as String?),
    traits: json['traits'] == null
        ? SpeciesTraits.none
        : SpeciesTraits.fromJson(json['traits'] as Map<String, dynamic>),
    protection: (json['protection'] as List?)?.cast<String>() ?? const [],
    grade: Grade.values.byName(json['grade'] as String),
    favouredTraits: (json['favouredTraits'] as List?)?.map((t) => Trait.values.byName(t as String)).toList(),
    vocation: (json['vocation'] as List?)?.map((e) => PotionEffect.values.byName(e as String)).toList(),
    companion: json['companion'] as String?,
    national: json['national'] == null ? null : NationalData.fromJson(json['national'] as Map<String, dynamic>),
  );
}

/// "#RRGGBB" → 0xRRGGBB; `null` se assente o non valido.
int? _parseHexColor(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) return null;
  return int.parse(hex.substring(1), radix: 16);
}
