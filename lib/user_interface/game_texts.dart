import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:druid_app/user_interface/common_widgets/diorama.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/species.dart';
import 'package:druid_app/business_logic/models/species_traits.dart';
import 'package:druid_app/business_logic/rules/erbario_views.dart';
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

  String builtInView(BuiltInView v) => switch (v) {
    BuiltInView.all => l10n.viewAll,
    BuiltInView.inSeason => l10n.viewInSeason,
    BuiltInView.desiderata => l10n.viewDesiderata,
    BuiltInView.protectedSpecies => l10n.viewProtected,
  };

  String speciesStatus(SpeciesStatus s) => switch (s) {
    SpeciesStatus.met => l10n.statusMet,
    SpeciesStatus.toFind => l10n.statusToFind,
    SpeciesStatus.desiderata => l10n.statusDesiderata,
    SpeciesStatus.studying => l10n.statusStudying,
  };

  /// Nome leggibile di una fonte di protezione del catalogo.
  String protectionSource(String id) => switch (id) {
    'regional-emilia-romagna' => l10n.protectionEmiliaRomagna,
    'habitats-annex-ii' => l10n.protectionHabitats('II'),
    'habitats-annex-iv' => l10n.protectionHabitats('IV'),
    'habitats-annex-v' => l10n.protectionHabitats('V'),
    _ => id,
  };

  String grade(Grade g) => switch (g) {
    Grade.common => l10n.gradeCommon,
    Grade.uncommon => l10n.gradeUncommon,
    Grade.rare => l10n.gradeRare,
    Grade.mythic => l10n.gradeMythic,
  };

  String trait(Trait t) => switch (t) {
    Trait.frost => l10n.traitFrost,
    Trait.rain => l10n.traitRain,
    Trait.fog => l10n.traitFog,
    Trait.sun => l10n.traitSun,
    Trait.moon => l10n.traitMoon,
    Trait.dew => l10n.traitDew,
    Trait.dusk => l10n.traitDusk,
    Trait.dawn => l10n.traitDawn,
    Trait.night => l10n.traitNight,
    Trait.afterStorm => l10n.traitAfterStorm,
    Trait.newMoon => l10n.traitNewMoon,
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
      QuestionForm.orderOf => l10n.qOrderOf(name(s)),
      QuestionForm.relativeOf => l10n.qRelativeOf(name(s)),
      QuestionForm.oddOneOut => l10n.qOddOneOut,
      QuestionForm.bandOf => l10n.qBandOf(name(s)),
      QuestionForm.whichInBand => l10n.qWhichInBand(bandPhrase(q.band!)),
      QuestionForm.commonnessOf => l10n.qCommonnessOf(name(s)),
      QuestionForm.growthFormOf => l10n.qGrowthFormOf(name(s)),
      QuestionForm.lifeCycleOf => l10n.qLifeCycleOf(name(s)),
      QuestionForm.seedDispersalOf => l10n.qSeedDispersalOf(name(s)),
      QuestionForm.originOf => l10n.qOriginOf(name(s)),
      QuestionForm.lightOf => l10n.qLightOf(name(s)),
      QuestionForm.moistureOf => l10n.qMoistureOf(name(s)),
    };
  }

  String option(Question q, AnswerOption option) => switch (option) {
    SpeciesOption(:final species) => name(species),
    ScientificNameOption(:final sci) => sci,
    FamilyOption(:final family) => family,
    OrderOption(:final order) => order,
    BandOption(band: final b) => band(b),
    YesNoOption(:final yes) => yes ? l10n.optionYes : l10n.optionNo,
    CommonnessOption(:final commonness) => this.commonness(commonness),
    TraitOption(:final value) => plantTrait(value),
  };

  /// Testo di un valore dei tratti della pianta (forma di crescita, ciclo, semi, luce, umidità).
  String plantTrait(Enum value) => switch (value) {
    GrowthForm.tree => l10n.growthTree,
    GrowthForm.shrub => l10n.growthShrub,
    GrowthForm.herb => l10n.growthHerb,
    GrowthForm.climber => l10n.growthClimber,
    LifeCycle.annual => l10n.cycleAnnual,
    LifeCycle.biennial => l10n.cycleBiennial,
    LifeCycle.perennial => l10n.cyclePerennial,
    SeedDispersal.eatenByAnimals => l10n.seedsEatenByAnimals,
    SeedDispersal.stuckToAnimals => l10n.seedsStuckToAnimals,
    SeedDispersal.hoardedByAnimals => l10n.seedsHoardedByAnimals,
    SeedDispersal.ants => l10n.seedsAnts,
    SeedDispersal.wind => l10n.seedsWind,
    SeedDispersal.water => l10n.seedsWater,
    SeedDispersal.launched => l10n.seedsLaunched,
    SeedDispersal.nearby => l10n.seedsNearby,
    LightPreference.shade => l10n.lightShade,
    LightPreference.halfShade => l10n.lightHalfShade,
    LightPreference.sun => l10n.lightSun,
    MoisturePreference.dry => l10n.moistureDry,
    MoisturePreference.fresh => l10n.moistureFresh,
    MoisturePreference.moist => l10n.moistureMoist,
    _ => value.name,
  };

  /// Le cose che si sanno dei tratti di una specie, fino al livello di studio raggiunto: per la scheda.
  List<String> traitLines(Species s, int level) {
    final t = s.traits;
    return [
      if (level >= 1 && t.growthForm != null) l10n.factGrowthForm(name(s), plantTrait(t.growthForm!).toLowerCase()),
      if (level >= 2 && t.lifeCycle != null) l10n.factLifeCycle(name(s), plantTrait(t.lifeCycle!).toLowerCase()),
      if (level >= 2 && t.dispersal.isNotEmpty) _seeds(s),
      if (level >= 3 && t.introducedInItaly != null)
        t.introducedInItaly! ? l10n.factOriginIntroduced(name(s)) : l10n.factOriginNative(name(s)),
      if (level >= 3 && lightPreferenceOf(s) != null)
        l10n.factLight(name(s), plantTrait(lightPreferenceOf(s)!).toLowerCase()),
      if (level >= 3 && moisturePreferenceOf(s) != null)
        l10n.factMoisture(name(s), plantTrait(moisturePreferenceOf(s)!).toLowerCase()),
    ];
  }

  String _seeds(Species s) => l10n.factSeedDispersal(
    name(s),
    (s.traits.dispersal.toList()..sort((a, b) => a.index.compareTo(b.index)))
        .map((m) => plantTrait(m).toLowerCase())
        .join(', '),
  );

  String commonness(Commonness c) => switch (c) {
    Commonness.veryCommon => l10n.commonnessVeryCommon,
    Commonness.common => l10n.commonnessCommon,
    Commonness.uncommon => l10n.commonnessUncommon,
    Commonness.rare => l10n.commonnessRare,
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
      FactKind.scientificName => [
        l10n.factScientificName(name(s), s.sci),
        if (s.congeners.isNotEmpty) l10n.factCongeners(s.genus, s.congeners.take(4).join(', ')),
      ].join(' '),
      FactKind.order => l10n.factOrder(name(s), s.order ?? '', s.family),
      FactKind.toxicity => l10n.factWarning(name(s), catalog.safety[s.sci]?.resolve(language) ?? ''),
      FactKind.commonness => l10n.factCommonness(name(s), commonness(commonnessOf(s, catalog)).toLowerCase()),
      FactKind.growthForm => l10n.factGrowthForm(name(s), plantTrait(s.traits.growthForm!).toLowerCase()),
      FactKind.lifeCycle => l10n.factLifeCycle(name(s), plantTrait(s.traits.lifeCycle!).toLowerCase()),
      FactKind.seedDispersal => _seeds(s),
      FactKind.origin =>
        s.traits.introducedInItaly! ? l10n.factOriginIntroduced(name(s)) : l10n.factOriginNative(name(s)),
      FactKind.light => l10n.factLight(name(s), plantTrait(lightPreferenceOf(s)!).toLowerCase()),
      FactKind.moisture => l10n.factMoisture(name(s), plantTrait(moisturePreferenceOf(s)!).toLowerCase()),
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
}

extension GameTextsContext on BuildContext {
  GameTexts get game => GameTexts(AppLocalizations.of(this), Localizations.localeOf(this).languageCode);
}
