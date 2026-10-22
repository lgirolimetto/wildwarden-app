import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';

/// Forma di una domanda. Ogni fatto ha una o più forme: chi sbaglia rivede lo stesso fatto chiesto diversamente.
enum QuestionForm {
  photoToName,
  nameToPhoto,
  sciToCommon,
  commonToSci,
  familyFromCommon,
  familyFromSci,
  familyFromPhoto,
  relativeOf,
  oddOneOut,
  seasonOf,
  bestMonthOf,
  bandOf,
  whichInBand,
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

class FamilyOption extends AnswerOption {
  final String family;

  const FamilyOption(this.family);

  @override
  bool operator ==(Object other) => other is FamilyOption && other.family == family;

  @override
  int get hashCode => family.hashCode;
}

class SeasonOption extends AnswerOption {
  final Season season;

  const SeasonOption(this.season);

  @override
  bool operator ==(Object other) => other is SeasonOption && other.season == season;

  @override
  int get hashCode => season.hashCode;
}

class MonthOption extends AnswerOption {
  /// 1-12.
  final int month;

  const MonthOption(this.month);

  @override
  bool operator ==(Object other) => other is MonthOption && other.month == month;

  @override
  int get hashCode => month.hashCode;
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

/// Forme disponibili per un fatto, nel suo catalogo.
List<QuestionForm> formsFor(Fact fact, Catalog catalog) {
  final s = fact.species;
  return switch (fact.kind) {
    FactKind.appearance => [
      QuestionForm.photoToName,
      if (catalog.species.where((o) => o.sci != s.sci && o.images.isNotEmpty).length >= 2) QuestionForm.nameToPhoto,
    ],
    FactKind.name => [QuestionForm.sciToCommon, QuestionForm.commonToSci],
    FactKind.family => [
      QuestionForm.familyFromCommon,
      QuestionForm.familyFromSci,
      if (s.images.isNotEmpty) QuestionForm.familyFromPhoto,
    ],
    FactKind.relatives => [
      QuestionForm.relativeOf,
      if (catalog.relativesOf(s).length >= 2 && _otherFamilies(s, catalog).isNotEmpty) QuestionForm.oddOneOut,
    ],
    FactKind.season => [QuestionForm.seasonOf, if (_lowMonths(s).length >= 3) QuestionForm.bestMonthOf],
    FactKind.altitude => [QuestionForm.bandOf, if (_absentFromBand(s, catalog).length >= 2) QuestionForm.whichInBand],
  };
}

/// Costruisce una domanda per il fatto, in una forma diversa da [avoid] se ce n'è più di una.
Question buildQuestion(Fact fact, Catalog catalog, Random random, {QuestionForm? avoid}) {
  final forms = formsFor(fact, catalog);
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
      wrong: _distractors(s, catalog, random).map(SpeciesOption.new).toList(),
    ),
    QuestionForm.nameToPhoto => make(
      answer: SpeciesOption(s, imageUrl: photoOf(s)),
      wrong: _distractors(
        s,
        catalog,
        random,
        where: (o) => o.images.isNotEmpty,
      ).map((o) => SpeciesOption(o, imageUrl: o.images.first.url)).toList(),
    ),
    QuestionForm.sciToCommon || QuestionForm.commonToSci => make(
      answer: SpeciesOption(s),
      wrong: _distractors(s, catalog, random).map(SpeciesOption.new).toList(),
    ),
    QuestionForm.familyFromCommon || QuestionForm.familyFromSci || QuestionForm.familyFromPhoto => make(
      imageUrl: form == QuestionForm.familyFromPhoto ? photoOf(s) : null,
      answer: FamilyOption(s.family),
      wrong: (_otherFamilies(s, catalog)..shuffle(random)).map(FamilyOption.new).toList(),
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
    QuestionForm.seasonOf => make(
      answer: SeasonOption(s.peakSeason),
      wrong: Season.values.where((x) => x != s.peakSeason).map(SeasonOption.new).toList(),
    ),
    QuestionForm.bestMonthOf => make(
      answer: MonthOption(_peakMonth(s)),
      wrong: (_lowMonths(s)..shuffle(random)).map(MonthOption.new).toList(),
    ),
    QuestionForm.bandOf => make(
      answer: BandOption(s.topBand),
      wrong: AltitudeBand.values.where((b) => b != s.topBand).map(BandOption.new).toList(),
    ),
    QuestionForm.whichInBand => make(
      band: s.topBand,
      answer: SpeciesOption(s),
      wrong: (_absentFromBand(s, catalog)..shuffle(random)).map(SpeciesOption.new).toList(),
    ),
  };
}

/// Risposte sbagliate: prima specie della stessa famiglia (più difficili da distinguere), poi le altre.
List<Species> _distractors(Species s, Catalog catalog, Random random, {bool Function(Species)? where}) {
  bool ok(Species o) => o.sci != s.sci && (where?.call(o) ?? true);
  final same = catalog.species.where((o) => ok(o) && o.family == s.family).toList()..shuffle(random);
  final others = catalog.species.where((o) => ok(o) && o.family != s.family).toList()..shuffle(random);
  return [...same, ...others].take(_distractorCount).toList();
}

List<String> _otherFamilies(Species s, Catalog catalog) =>
    catalog.species.map((o) => o.family).toSet().where((f) => f != s.family).toList();

int _peakMonth(Species s) {
  final values = s.monthsRelative;
  return values.indexOf(values.reduce(max)) + 1;
}

/// Mesi (1-12) in cui la specie si osserva poco: risposte sbagliate credibili ma inequivocabili.
List<int> _lowMonths(Species s) {
  final top = s.monthsRelative.reduce(max);
  return [
    for (var i = 0; i < 12; i++)
      if (s.monthsRelative[i] <= 0.3 * top) i + 1,
  ];
}

/// Specie che nella fascia di quota prevalente di [s] non si trovano quasi mai.
List<Species> _absentFromBand(Species s, Catalog catalog) =>
    catalog.species.where((o) => o.sci != s.sci && (o.bandShare[s.topBand] ?? 0) < 0.25).toList();
