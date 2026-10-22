import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:druid_app/user_interface/common_widgets/diorama.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/rules/fun_facts.dart';
import 'package:druid_app/business_logic/rules/onboarding.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';
import 'package:druid_app/business_logic/rules/study/questions.dart';
import 'package:druid_app/business_logic/rules/study/xp_rules.dart';
import 'package:druid_app/l10n/app_localizations.dart';
import 'package:druid_app/user_interface/pages/erbario/hint_text.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Testi composti dalle regole di gioco: le regole producono dati, qui diventano frasi nella lingua dell'utente.
class GameTexts {
  final AppLocalizations l10n;
  final String language;

  const GameTexts(this.l10n, this.language);

  String name(Species s) => s.name.resolve(language);

  String dayTime(DayTime t) => switch (t) {
    DayTime.dawn => l10n.dayTimeDawn,
    DayTime.day => l10n.dayTimeDay,
    DayTime.dusk => l10n.dayTimeDusk,
    DayTime.night => l10n.dayTimeNight,
  };

  String season(Season s) => switch (s) {
    Season.winter => l10n.seasonWinter,
    Season.spring => l10n.seasonSpring,
    Season.summer => l10n.seasonSummer,
    Season.autumn => l10n.seasonAutumn,
  };

  String band(AltitudeBand b) => switch (b) {
    AltitudeBand.plain => l10n.bandPlain,
    AltitudeBand.hill => l10n.bandHill,
    AltitudeBand.mountain => l10n.bandMountain,
  };

  /// "in pianura", "in collina", "in montagna".
  String bandPhrase(AltitudeBand b) => switch (b) {
    AltitudeBand.plain => l10n.hintBandPlain,
    AltitudeBand.hill => l10n.hintBandHill,
    AltitudeBand.mountain => l10n.hintBandMountain,
  };

  String month(int month) {
    final text = DateFormat.MMMM(language).format(DateTime(2000, month));
    return text;
  }

  String months(List<int> months) => months.map(month).join(', ');

  String hint(Species s) => hintText(l10n, s.hint);

  String rank(Rank r) => switch (r) {
    Rank.apprentice => l10n.rankApprentice,
    Rank.wanderer => l10n.rankWanderer,
    Rank.seeker => l10n.rankSeeker,
    Rank.warden => l10n.rankWarden,
    Rank.botanomancer => l10n.rankBotanomancer,
  };

  String trait(Trait t) => switch (t) {
    Trait.frost => l10n.traitFrost,
    Trait.rain => l10n.traitRain,
    Trait.fog => l10n.traitFog,
    Trait.sun => l10n.traitSun,
    Trait.moon => l10n.traitMoon,
    Trait.dew => l10n.traitDew,
    Trait.dusk => l10n.traitDusk,
  };

  String prompt(Question q) {
    final s = q.fact.species;
    return switch (q.form) {
      QuestionForm.photoToName => l10n.qPhotoToName,
      QuestionForm.nameToPhoto => l10n.qNameToPhoto(name(s)),
      QuestionForm.sciToCommon => l10n.qSciToCommon(s.sci),
      QuestionForm.commonToSci => l10n.qCommonToSci(name(s)),
      QuestionForm.familyFromCommon => l10n.qFamilyFromCommon(name(s)),
      QuestionForm.familyFromSci => l10n.qFamilyFromSci(s.sci),
      QuestionForm.familyFromPhoto => l10n.qFamilyFromPhoto,
      QuestionForm.relativeOf => l10n.qRelativeOf(name(s)),
      QuestionForm.oddOneOut => l10n.qOddOneOut,
      QuestionForm.seasonOf => l10n.qSeasonOf(name(s)),
      QuestionForm.bestMonthOf => l10n.qBestMonthOf(name(s)),
      QuestionForm.bandOf => l10n.qBandOf(name(s)),
      QuestionForm.whichInBand => l10n.qWhichInBand(bandPhrase(q.band!)),
    };
  }

  String option(Question q, AnswerOption option) => switch (option) {
    SpeciesOption(:final species) => q.form == QuestionForm.commonToSci ? species.sci : name(species),
    FamilyOption(:final family) => family,
    SeasonOption(season: final s) => _capitalize(season(s)),
    MonthOption(month: final m) => _capitalize(month(m)),
    BandOption(band: final b) => band(b),
  };

  /// Il fatto spiegato, mostrato dopo ogni risposta e salvato nel taccuino.
  String fact(Fact fact, Catalog catalog) {
    final s = fact.species;
    return switch (fact.kind) {
      FactKind.appearance => l10n.factAppearance(name(s), s.sci),
      FactKind.name => l10n.factName(name(s), s.sci),
      FactKind.family => l10n.factFamily(name(s), s.family),
      FactKind.relatives => l10n.factRelatives(name(s), catalog.relativesOf(s).map(name).join(', '), s.family),
      FactKind.season => l10n.factSeason(name(s), season(s.peakSeason), months(s.topMonths())),
      FactKind.altitude => l10n.factAltitude(name(s), bandPhrase(s.topBand), s.elevationMedian?.round() ?? 0),
    };
  }

  String funFact(FunFact f) => switch (f) {
    CuratedFunFactItem(:final text) => text.resolve(language),
    ObservationRankFact(:final rank) => l10n.funRank(name(f.species), rank),
    HighAltitudeFact(:final medianMeters) => l10n.funHigh(name(f.species), medianMeters),
    LowlandFact(:final medianMeters) => l10n.funLow(name(f.species), medianMeters),
    PeakMonthFact(month: final m) => l10n.funPeak(name(f.species), month(m)),
  };

  String missionTitle(Mission m) => switch (m) {
    Mission.visitErbario => l10n.missionVisitErbarioTitle,
    Mission.markDesiderata => l10n.missionMarkDesiderataTitle,
    Mission.firstEncounter => l10n.missionFirstEncounterTitle,
    Mission.firstLevel => l10n.missionFirstLevelTitle,
    Mission.firstRecipe => l10n.missionFirstRecipeTitle,
  };

  String missionBody(Mission m) => switch (m) {
    Mission.visitErbario => l10n.missionVisitErbarioBody,
    Mission.markDesiderata => l10n.missionMarkDesiderataBody,
    Mission.firstEncounter => l10n.missionFirstEncounterBody,
    Mission.firstLevel => l10n.missionFirstLevelBody,
    Mission.firstRecipe => l10n.missionFirstRecipeBody,
  };

  static String _capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}

extension GameTextsContext on BuildContext {
  GameTexts get game => GameTexts(AppLocalizations.of(this), Localizations.localeOf(this).languageCode);
}
