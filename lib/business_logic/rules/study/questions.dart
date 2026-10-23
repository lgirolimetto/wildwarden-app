import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/species_traits.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';

/// Forma di una domanda. Ogni fatto ha una o più forme: chi sbaglia rivede lo stesso fatto chiesto diversamente.
///
/// Nello studio di un livello il nome comune della specie è nel titolo: le forme che lo chiedono ([photoToName],
/// [sciToCommon]) valgono solo nei ripassi, che mescolano più specie.
enum QuestionForm {
  photoToName,
  nameToPhoto,
  sciToCommon,
  commonToSci,
  familyFromCommon,
  familyFromSci,
  familyFromPhoto,
  orderOf,
  relativeOf,
  oddOneOut,
  bandOf,
  whichInBand,
  commonnessOf,
  growthFormOf,
  lifeCycleOf,
  seedDispersalOf,
  originOf,
  lightOf,
  moistureOf,
}

/// Risposta possibile. È solo dato: il testo lo compone la UI nella lingua dell'utente.
sealed class AnswerOption {
  const AnswerOption();
}

class SpeciesOption extends AnswerOption {
  final Species species;

  /// Valorizzata quando l'opzione si mostra come foto (forma [QuestionForm.nameToPhoto]).
  final String? imageUrl;

  const SpeciesOption(this.species, {this.imageUrl});

  @override
  bool operator ==(Object other) => other is SpeciesOption && other.species.sci == species.sci;

  @override
  int get hashCode => species.sci.hashCode;
}

/// Un nome scientifico, anche di una specie che non è nel catalogo (le specie sorelle dello stesso genere).
class ScientificNameOption extends AnswerOption {
  final String sci;

  const ScientificNameOption(this.sci);

  @override
  bool operator ==(Object other) => other is ScientificNameOption && other.sci == sci;

  @override
  int get hashCode => sci.hashCode;
}

class OrderOption extends AnswerOption {
  final String order;

  const OrderOption(this.order);

  @override
  bool operator ==(Object other) => other is OrderOption && other.order == order;

  @override
  int get hashCode => order.hashCode;
}

class YesNoOption extends AnswerOption {
  final bool yes;

  const YesNoOption(this.yes);

  @override
  bool operator ==(Object other) => other is YesNoOption && other.yes == yes;

  @override
  int get hashCode => yes.hashCode;
}

/// Un valore fra pochi possibili (forma di crescita, ciclo vitale, semi, luce, umidità…): l'enum dice quale.
class TraitOption extends AnswerOption {
  final Enum value;

  const TraitOption(this.value);

  @override
  bool operator ==(Object other) => other is TraitOption && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class CommonnessOption extends AnswerOption {
  final Commonness commonness;

  const CommonnessOption(this.commonness);

  @override
  bool operator ==(Object other) => other is CommonnessOption && other.commonness == commonness;

  @override
  int get hashCode => commonness.hashCode;
}

class FamilyOption extends AnswerOption {
  final String family;

  const FamilyOption(this.family);

  @override
  bool operator ==(Object other) => other is FamilyOption && other.family == family;

  @override
  int get hashCode => family.hashCode;
}

class BandOption extends AnswerOption {
  final AltitudeBand band;

  const BandOption(this.band);

  @override
  bool operator ==(Object other) => other is BandOption && other.band == band;

  @override
  int get hashCode => band.hashCode;
}

class Question {
  final Fact fact;
  final QuestionForm form;

  /// Foto mostrata con la domanda, se la forma la prevede.
  final String? imageUrl;

  /// Banda di quota citata nella domanda (forma [QuestionForm.whichInBand]).
  final AltitudeBand? band;
  final List<AnswerOption> options;
  final AnswerOption answer;

  const Question({
    required this.fact,
    required this.form,
    required this.options,
    required this.answer,
    this.imageUrl,
    this.band,
  });

  bool isCorrect(AnswerOption chosen) => chosen == answer;
}

/// Numero massimo di risposte sbagliate proposte per domanda.
const _distractorCount = 3;

/// Forme disponibili per un fatto, nel suo catalogo. Nei ripassi ([AnswerMode.review]) si aggiungono quelle che
/// chiedono il nome comune.
List<QuestionForm> formsFor(Fact fact, Catalog catalog, {AnswerMode mode = AnswerMode.learning}) {
  final s = fact.species;
  final review = mode == AnswerMode.review;
  final canShowPhotos = catalog.species.where((o) => o.sci != s.sci && o.images.isNotEmpty).length >= 2;
  return switch (fact.kind) {
    FactKind.appearance => [
      if (canShowPhotos) QuestionForm.nameToPhoto,
      if (review || !canShowPhotos) QuestionForm.photoToName,
    ],
    FactKind.scientificName => [QuestionForm.commonToSci, if (review) QuestionForm.sciToCommon],
    FactKind.family => [
      QuestionForm.familyFromCommon,
      QuestionForm.familyFromSci,
      if (s.images.isNotEmpty) QuestionForm.familyFromPhoto,
    ],
    FactKind.order => [QuestionForm.orderOf],
    FactKind.relatives => [
      QuestionForm.relativeOf,
      if (catalog.relativesOf(s).length >= 2 && _otherFamilies(s, catalog).isNotEmpty) QuestionForm.oddOneOut,
    ],
    FactKind.altitude => [QuestionForm.bandOf, if (_absentFromBand(s, catalog).length >= 2) QuestionForm.whichInBand],
    FactKind.commonness => [QuestionForm.commonnessOf],
    FactKind.growthForm => [QuestionForm.growthFormOf],
    FactKind.lifeCycle => [QuestionForm.lifeCycleOf],
    FactKind.seedDispersal => [QuestionForm.seedDispersalOf],
    FactKind.origin => [QuestionForm.originOf],
    FactKind.light => [QuestionForm.lightOf],
    FactKind.moisture => [QuestionForm.moistureOf],
    // Ritirati: non si chiedono più.
    FactKind.name || FactKind.season || FactKind.toxicity => const [],
  };
}

/// Costruisce una domanda per il fatto, in una forma diversa da [avoid] se ce n'è più di una.
Question buildQuestion(
  Fact fact,
  Catalog catalog,
  Random random, {
  QuestionForm? avoid,
  AnswerMode mode = AnswerMode.learning,
}) {
  final forms = formsFor(fact, catalog, mode: mode);
  assert(forms.isNotEmpty, 'Fatto ritirato: ${fact.id}');
  final candidates = forms.length > 1 ? forms.where((f) => f != avoid).toList() : forms;
  final form = candidates[random.nextInt(candidates.length)];
  final s = fact.species;

  Question make({
    required List<AnswerOption> wrong,
    required AnswerOption answer,
    String? imageUrl,
    AltitudeBand? band,
  }) {
    final options = [...wrong.take(_distractorCount), answer]..shuffle(random);
    return Question(fact: fact, form: form, options: options, answer: answer, imageUrl: imageUrl, band: band);
  }

  String photoOf(Species species) => species.images[random.nextInt(species.images.length)].url;

  return switch (form) {
    QuestionForm.photoToName => make(
      imageUrl: photoOf(s),
      answer: SpeciesOption(s),
      wrong: _lookalikes(s, catalog, random).map(SpeciesOption.new).toList(),
    ),
    // "Quale di queste è la malva?": tra specie che si somigliano, e mai con la foto di copertina dell'erbario
    // se la specie ne ha altre (riconoscerla vuol dire riconoscerla in una foto nuova).
    QuestionForm.nameToPhoto => make(
      answer: SpeciesOption(
        s,
        imageUrl: s.images.length > 1 ? s.images[1 + random.nextInt(s.images.length - 1)].url : s.images.first.url,
      ),
      wrong: _lookalikes(
        s,
        catalog,
        random,
        where: (o) => o.images.isNotEmpty,
      ).map((o) => SpeciesOption(o, imageUrl: photoOf(o))).toList(),
    ),
    QuestionForm.sciToCommon => make(
      answer: SpeciesOption(s),
      wrong: _lookalikes(s, catalog, random).map(SpeciesOption.new).toList(),
    ),
    QuestionForm.commonToSci => make(
      answer: ScientificNameOption(s.sci),
      wrong: similarScientificNames(s, catalog, random).map(ScientificNameOption.new).toList(),
    ),
    QuestionForm.familyFromCommon || QuestionForm.familyFromSci || QuestionForm.familyFromPhoto => make(
      imageUrl: form == QuestionForm.familyFromPhoto ? photoOf(s) : null,
      answer: FamilyOption(s.family),
      wrong: (_otherFamilies(s, catalog)..shuffle(random)).map(FamilyOption.new).toList(),
    ),
    QuestionForm.orderOf => make(
      answer: OrderOption(s.order!),
      wrong: (catalog.species.map((o) => o.order).nonNulls.toSet().where((o) => o != s.order).toList()..shuffle(random))
          .map(OrderOption.new)
          .toList(),
    ),
    QuestionForm.relativeOf => () {
      final relatives = catalog.relativesOf(s);
      return make(
        answer: SpeciesOption(relatives[random.nextInt(relatives.length)]),
        wrong: (catalog.species.where((o) => o.family != s.family).toList()..shuffle(random))
            .map(SpeciesOption.new)
            .toList(),
      );
    }(),
    QuestionForm.oddOneOut => () {
      final sameFamily = [s, ...(catalog.relativesOf(s)..shuffle(random)).take(2)];
      final others = catalog.species.where((o) => o.family != s.family).toList();
      return make(
        answer: SpeciesOption(others[random.nextInt(others.length)]),
        wrong: sameFamily.map(SpeciesOption.new).toList(),
      );
    }(),
    QuestionForm.bandOf => make(
      answer: BandOption(s.topBand),
      wrong: AltitudeBand.values.where((b) => b != s.topBand).map(BandOption.new).toList(),
    ),
    QuestionForm.whichInBand => make(
      band: s.topBand,
      answer: SpeciesOption(s),
      wrong: (_absentFromBand(s, catalog)..shuffle(random)).map(SpeciesOption.new).toList(),
    ),
    QuestionForm.growthFormOf => _oneOf(make, s.traits.growthForm!, GrowthForm.values, random),
    QuestionForm.lifeCycleOf => _oneOf(make, s.traits.lifeCycle!, LifeCycle.values, random),
    // Se i semi viaggiano in più modi se ne chiede uno; le risposte sbagliate sono modi che questa specie non usa.
    QuestionForm.seedDispersalOf => () {
      final modes = s.traits.dispersal.toList()..sort((a, b) => a.index.compareTo(b.index));
      return make(
        answer: TraitOption(modes[random.nextInt(modes.length)]),
        wrong: (SeedDispersal.values.where((m) => !modes.contains(m)).toList()..shuffle(random))
            .map(TraitOption.new)
            .toList(),
      );
    }(),
    QuestionForm.originOf => make(
      answer: YesNoOption(s.traits.introducedInItaly!),
      wrong: [YesNoOption(!s.traits.introducedInItaly!)],
    ),
    QuestionForm.lightOf => _oneOf(make, lightPreferenceOf(s)!, LightPreference.values, random),
    QuestionForm.moistureOf => _oneOf(make, moisturePreferenceOf(s)!, MoisturePreference.values, random),
    QuestionForm.commonnessOf => make(
      answer: CommonnessOption(commonnessOf(s, catalog)),
      wrong: Commonness.values.where((c) => c != commonnessOf(s, catalog)).map(CommonnessOption.new).toList(),
    ),
  };
}

/// Specie che si somigliano, per le risposte sbagliate: prima lo stesso genere, poi la stessa famiglia, poi un colore
/// simile (quello caratteristico della foto, `mysteryColor`), poi le altre.
List<Species> _lookalikes(Species s, Catalog catalog, Random random, {bool Function(Species)? where}) {
  bool ok(Species o) => o.sci != s.sci && (where?.call(o) ?? true);
  int closeness(Species o) {
    if (o.genus == s.genus) return 0;
    if (o.family == s.family) return 1;
    if (_hueDistance(o, s) < 30) return 2;
    return 3;
  }

  final pool = catalog.species.where(ok).toList()..shuffle(random);
  return (pool..sort((a, b) => closeness(a).compareTo(closeness(b)))).take(_distractorCount).toList();
}

/// Distanza tra le tinte caratteristiche di due specie, in gradi (0-180); 180 se una delle due non ce l'ha.
double _hueDistance(Species a, Species b) {
  if (a.mysteryColor == null || b.mysteryColor == null) return 180;
  final d = (_hue(a.mysteryColor!) - _hue(b.mysteryColor!)).abs();
  return min(d, 360 - d);
}

double _hue(int rgb) {
  final r = (rgb >> 16 & 0xFF) / 255, g = (rgb >> 8 & 0xFF) / 255, b = (rgb & 0xFF) / 255;
  final high = max(r, max(g, b)), low = min(r, min(g, b)), delta = high - low;
  if (delta == 0) return 0;
  final h = high == r
      ? ((g - b) / delta) % 6
      : high == g
      ? (b - r) / delta + 2
      : (r - g) / delta + 4;
  return h * 60;
}

/// Nomi scientifici plausibili ma sbagliati: prima le specie vere dello stesso genere (anche fuori dal catalogo),
/// poi i nomi che suonano più simili tra quelli conosciuti (catalogo e sorelle). Mai nomi inventati.
List<String> similarScientificNames(Species s, Catalog catalog, Random random) {
  final congeners = (s.congeners.where((n) => n != s.sci).toList()..shuffle(random)).take(_distractorCount).toList();
  if (congeners.length >= _distractorCount) return congeners;
  final known = {
    for (final o in catalog.species) ...[o.sci, ...o.congeners],
  }.difference({s.sci, ...congeners});
  final bySound = known.toList()..sort((a, b) => _similarity(b, s.sci).compareTo(_similarity(a, s.sci)));
  // Tra i più simili si pesca a caso, così la domanda non si ripete sempre uguale.
  final closest = bySound.take(_distractorCount * 2).toList()..shuffle(random);
  return [...congeners, ...closest].take(_distractorCount).toList();
}

/// Somiglianza tra due nomi (coefficiente di Dice sui trigrammi, 0-1).
double _similarity(String a, String b) {
  Set<String> trigrams(String text) {
    final t = '  ${text.toLowerCase()} ';
    return {for (var i = 0; i + 3 <= t.length; i++) t.substring(i, i + 3)};
  }

  final x = trigrams(a), y = trigrams(b);
  return 2 * x.intersection(y).length / (x.length + y.length);
}

/// Domanda con un valore giusto tra pochi possibili: le risposte sbagliate sono gli altri valori.
Question _oneOf<T extends Enum>(
  Question Function({required List<AnswerOption> wrong, required AnswerOption answer}) make,
  T answer,
  List<T> values,
  Random random,
) => make(
  answer: TraitOption(answer),
  wrong: (values.where((v) => v != answer).toList()..shuffle(random)).map(TraitOption.new).toList(),
);

List<String> _otherFamilies(Species s, Catalog catalog) =>
    catalog.species.map((o) => o.family).toSet().where((f) => f != s.family).toList();

/// Specie che nella fascia di quota prevalente di [s] non si trovano quasi mai.
List<Species> _absentFromBand(Species s, Catalog catalog) =>
    catalog.species.where((o) => o.sci != s.sci && (o.bandShare[s.topBand] ?? 0) < 0.25).toList();
