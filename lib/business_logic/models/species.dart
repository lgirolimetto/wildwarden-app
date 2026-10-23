import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:druid_app/business_logic/models/localized_text.dart';

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

/// Specie del catalogo di una zona, con i dati ricavati dalle osservazioni GBIF.
class Species {
  /// Nome scientifico: è la chiave stabile della specie in tutta l'app.
  final String sci;
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

  const Species({
    required this.sci,
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
  });

  factory Species.fromJson(Map<String, dynamic> json) => Species(
    sci: json['sci'] as String,
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
  );
}

/// "#RRGGBB" → 0xRRGGBB; `null` se assente o non valido.
int? _parseHexColor(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) return null;
  return int.parse(hex.substring(1), radix: 16);
}
