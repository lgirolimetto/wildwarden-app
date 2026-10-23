// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Druid';

  @override
  String get navErbario => 'Herbarium';

  @override
  String get navSettings => 'Settings';

  @override
  String get erbarioTitle => 'Herbarium';

  @override
  String erbarioFound(int found, int total) {
    return '$found/$total found';
  }

  @override
  String get unknownSpecies => '???';

  @override
  String hintFamily(String family) {
    return 'A plant of the $family family';
  }

  @override
  String get hintSeasonWinter => 'most noticeable in winter';

  @override
  String get hintSeasonSpring => 'most noticeable in spring';

  @override
  String get hintSeasonSummer => 'most noticeable in summer';

  @override
  String get hintSeasonAutumn => 'most noticeable in autumn';

  @override
  String get hintBandPlain => 'in the lowlands';

  @override
  String get hintBandHill => 'in the hills';

  @override
  String get hintBandMountain => 'in the mountains';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get liveryLabel => 'Livery';

  @override
  String get liveryErbario => 'Herbarium';

  @override
  String get liveryNotturna => 'Nocturne';

  @override
  String get themeModeLabel => 'Appearance';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get loadingError => 'The data could not be loaded';

  @override
  String get retry => 'Retry';

  @override
  String get erbarioEncounteredSection => 'Encountered';

  @override
  String get erbarioMissingSection => 'Still to find around Bologna';

  @override
  String get simulateEncounter => 'Simulate encounter';

  @override
  String get levelToStudy => 'To study';

  @override
  String get levelRecognise => 'Recognise it';

  @override
  String get levelKnow => 'Family and life';

  @override
  String get levelWhereWhen => 'Its habitat';

  @override
  String get levelMastery => 'Mastery';

  @override
  String get navStudy => 'Home';

  @override
  String get navRecipes => 'Recipes';

  @override
  String get rankApprentice => 'Apprentice';

  @override
  String get rankWanderer => 'Wanderer';

  @override
  String get rankSeeker => 'Seeker';

  @override
  String get rankWarden => 'Warden';

  @override
  String get rankBotanomancer => 'Botanomancer';

  @override
  String xpTotal(int xp) {
    return '$xp XP';
  }

  @override
  String nextRank(String rank, int xp) {
    return 'Next title: $rank at $xp XP';
  }

  @override
  String get maxRankReached => 'You have reached the highest title';

  @override
  String get seasonWinter => 'winter';

  @override
  String get seasonSpring => 'spring';

  @override
  String get seasonSummer => 'summer';

  @override
  String get seasonAutumn => 'autumn';

  @override
  String get bandPlain => 'Lowlands (below 150 m)';

  @override
  String get bandHill => 'Hills (150–600 m)';

  @override
  String get bandMountain => 'Mountains (above 600 m)';

  @override
  String get qPhotoToName => 'What plant is this?';

  @override
  String qNameToPhoto(String name) {
    return 'Which of these is $name?';
  }

  @override
  String qSciToCommon(String sci) {
    return 'What is the common name of $sci?';
  }

  @override
  String qCommonToSci(String name) {
    return 'What is the scientific name of: $name?';
  }

  @override
  String qFamilyFromCommon(String name) {
    return 'Which family does $name belong to?';
  }

  @override
  String qFamilyFromSci(String sci) {
    return 'Which family does $sci belong to?';
  }

  @override
  String get qFamilyFromPhoto =>
      'Which family does the plant in the photo belong to?';

  @override
  String qRelativeOf(String name) {
    return 'Which of these plants is in the same family as: $name?';
  }

  @override
  String get qOddOneOut => 'Which one is NOT in the same family as the others?';

  @override
  String qBandOf(String name) {
    return 'Where do you most often meet $name here?';
  }

  @override
  String qWhichInBand(String band) {
    return 'Which of these plants are you most likely to find $band?';
  }

  @override
  String factAppearance(String name, String sci) {
    return '$name ($sci)';
  }

  @override
  String factName(String name, String sci) {
    return '$name = $sci';
  }

  @override
  String factFamily(String name, String family) {
    return '$name belongs to the $family family.';
  }

  @override
  String factRelatives(String name, String relatives, String family) {
    return '$name is related to: $relatives ($family).';
  }

  @override
  String factSeason(String name, String season, String months) {
    return '$name is most noticeable in $season. Best months: $months.';
  }

  @override
  String factAltitude(String name, String band, int meters) {
    return '$name is mostly found $band (median altitude $meters m).';
  }

  @override
  String get answerRight => 'Correct!';

  @override
  String get answerWrong => 'Not quite.';

  @override
  String get answerWillReturn =>
      'It will come back shortly, asked another way.';

  @override
  String answerRemembered(int days) {
    return 'You remembered! Next review in $days days.';
  }

  @override
  String get answerForgotten =>
      'Forgotten: it will come back in tomorrow\'s reviews.';

  @override
  String xpGained(int xp) {
    return '+$xp XP';
  }

  @override
  String get next => 'Next';

  @override
  String get close => 'Close';

  @override
  String studyLevelTitle(String name, int level) {
    return '$name · level $level';
  }

  @override
  String get reviewTitle => 'Review';

  @override
  String studyProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String get summaryTitle => 'Session complete';

  @override
  String summaryLevelPassed(int level, String name) {
    return 'Level $level passed: $name joins your reviews from tomorrow.';
  }

  @override
  String get summaryReviewDone => 'Reviews complete.';

  @override
  String summaryAnswers(int correct, int answers) {
    return 'Correct answers: $correct of $answers';
  }

  @override
  String get summaryMastery => 'Mastery reached!';

  @override
  String summaryRecipeUnlocked(String recipe) {
    return 'Recipe unlocked: $recipe';
  }

  @override
  String get summaryNewFunFacts =>
      'New curiosities on the way: you\'ll get one a day.';

  @override
  String get saveToNotebook => 'Save to notebook';

  @override
  String get savedToNotebook => 'In your notebook';

  @override
  String get notebookLocked => 'Save to notebook';

  @override
  String get diarioUpsell =>
      'With the Herbalist\'s Journal you save what you learn in one tap and find it when you need it, even while studying. Without it you can do the same with a real notebook and the per-species notes, which stay free.';

  @override
  String get notebookTitle => 'Notebook';

  @override
  String get notebookSearch => 'Search: family, month, species, notes…';

  @override
  String get notebookEmpty =>
      'Still empty: while studying, use \"Save to notebook\".';

  @override
  String get notebookNoResults => 'No results.';

  @override
  String get notesTitle => 'Your notes';

  @override
  String get notesHint => 'Where you saw it, how to recognise it…';

  @override
  String get notesSave => 'Save note';

  @override
  String get notesSaved => 'Note saved';

  @override
  String get funOfDayTitle => 'Curiosity of the day';

  @override
  String funOfDayCount(int seen, int total) {
    return '$seen found of $total';
  }

  @override
  String get funOfDayEmpty =>
      'Meet and study a species to receive a daily curiosity about what you\'ve learned.';

  @override
  String get funToVerify => 'to be verified';

  @override
  String funRank(String name, int rank) {
    return '$name ranks #$rank among the most observed wild plants in the area.';
  }

  @override
  String funHigh(String name, int meters) {
    return '$name is one of the 5 species in the area that live highest: half of the sightings are above $meters m.';
  }

  @override
  String funLow(String name, int meters) {
    return '$name is one of the 5 most lowland species in the area: median altitude $meters m.';
  }

  @override
  String funPeak(String name, String month) {
    return '$name is most noticeable in $month.';
  }

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String reviewsDue(int count) {
    return '$count facts to review today';
  }

  @override
  String get reviewsNone =>
      'Nothing to review today. What you learn comes back after 1, 3, 7 and 21 days.';

  @override
  String get reviewsStart => 'Review';

  @override
  String get desiderataTitle => 'Desiderata';

  @override
  String desiderataCount(int count, int max) {
    return '$count of $max';
  }

  @override
  String get desiderataEmpty =>
      'Choose up to 3 species to look for: you\'ll see photos and where and when to find them.';

  @override
  String get desiderataSuggestions => 'In season now';

  @override
  String get seasonalFirstHint =>
      'Three species that are easy to recognise, to start right away: you can study from home too.';

  @override
  String get seasonalHint =>
      'Study them now or mark them as desiderata to look for.';

  @override
  String get seasonalStudy => 'Study';

  @override
  String get yourSpeciesMet => 'met';

  @override
  String get desiderataAdd => 'Add to desiderata';

  @override
  String get desiderataRemove => 'Remove from desiderata';

  @override
  String get desiderataFull =>
      'You already have 3 desiderata: complete or remove one.';

  @override
  String desiderataWhere(String band) {
    return 'Where: $band';
  }

  @override
  String desiderataWhen(String months) {
    return 'When: $months';
  }

  @override
  String desiderataFamily(String family) {
    return 'Family: $family';
  }

  @override
  String get yourSpecies => 'Your species';

  @override
  String get yourSpeciesEmpty =>
      'No species in study yet: start with one in season.';

  @override
  String studyLevelButton(int level) {
    return 'Study level $level';
  }

  @override
  String get studyComplete => 'Questions complete';

  @override
  String get levelsTitle => 'Study levels';

  @override
  String lockedSection(int level, String name) {
    return 'Revealed at level $level ($name)';
  }

  @override
  String get sectionSci => 'Scientific name';

  @override
  String get sectionFamily => 'Family';

  @override
  String get sectionRelatives => 'Relatives in the area';

  @override
  String get sectionWhen => 'When it is seen';

  @override
  String sectionWhere(int meters) {
    return 'Where (median altitude $meters m)';
  }

  @override
  String get sectionLore => 'Lore';

  @override
  String sectionFunFacts(int seen, int total) {
    return 'Curiosities $seen/$total';
  }

  @override
  String sectionFunFactsHidden(int count) {
    return '$count still to discover';
  }

  @override
  String safetyWarning(String text) {
    return '⚠️ $text · to be verified';
  }

  @override
  String get protectedNote =>
      'Wild orchid, protected in many regions: altitude bands only, never exact locations.';

  @override
  String get masteryTitle => 'Mastery';

  @override
  String masteryFacts(int done, int total) {
    return 'Consolidated facts (remembered after 1 and 3 days): $done/$total';
  }

  @override
  String masteryDraws(int done, int total, int traits, int needed) {
    return 'Essences drawn: $done/$total · different traits: $traits/$needed';
  }

  @override
  String get masteryOnlyField =>
      'Study alone doesn\'t lead to mastery: you also need essences drawn in the field.';

  @override
  String get masteryReached => 'Mastery reached';

  @override
  String get simulateDraw => 'Simulate drawing';

  @override
  String get noTrait => 'No trait';

  @override
  String get traitFrost => '❄️ Frost';

  @override
  String get traitRain => '🌧 Rain';

  @override
  String get traitFog => '🌫 Fog';

  @override
  String get traitSun => '☀️ Sun';

  @override
  String get traitMoon => '🌕 Moon';

  @override
  String get traitDew => '💧 Dew';

  @override
  String get traitDusk => '🌅 Dusk';

  @override
  String get recipesTitle => 'Recipes';

  @override
  String get recipeUnlocked => 'Unlocked';

  @override
  String get recipeLocked => 'Locked';

  @override
  String recipeKnownIngredients(int known, int total) {
    return 'Known ingredients $known/$total';
  }

  @override
  String get recipeUnknownIngredient => '???';

  @override
  String recipeHint(String hint) {
    return 'Hint: $hint';
  }

  @override
  String get recipeAnySpecies => 'any species';

  @override
  String recipeCurrentLevel(int level) {
    return 'now: level $level';
  }

  @override
  String erbarioPages(int done, int total) {
    return 'Pages filled $done/$total';
  }

  @override
  String missionLabel(int index, int total) {
    return 'Quest $index of $total';
  }

  @override
  String get missionVisitErbarioTitle => 'Open the herbarium';

  @override
  String get missionVisitErbarioBody =>
      'The herbarium gathers the species of the area, each with photo and name. The rest you discover by studying and meeting them.';

  @override
  String get missionMarkDesiderataTitle => 'Choose your desiderata';

  @override
  String get missionMarkDesiderataBody =>
      'Choose up to 3 species to look for: for each you\'ll see photos, season and altitude. Start with one in season now.';

  @override
  String get missionFirstEncounterTitle => 'Meet a species';

  @override
  String get missionFirstEncounterBody =>
      'Go out botanizing and photograph one of your desiderata: once recognised it will appear in the herbarium. Photograph, don\'t pick.';

  @override
  String get missionFirstLevelTitle => 'Study your first species';

  @override
  String get missionFirstLevelBody =>
      'Pick a species in season and pass its first study level: you can start from home. Mistakes teach too, and they earn experience.';

  @override
  String get missionFirstRecipeTitle => 'Your first recipe';

  @override
  String get missionFirstRecipeBody =>
      'Bring a species to the level a recipe requires to unlock it. Recipes ask for different species and conditions: a reason to go out again.';

  @override
  String get missionSkip => 'Skip the apprenticeship';

  @override
  String get missionActionOpenErbario => 'Open the herbarium';

  @override
  String get missionActionChooseDesiderata => 'Choose in the herbarium';

  @override
  String get missionActionStudy => 'Start studying';

  @override
  String get missionActionRecipes => 'See the recipes';

  @override
  String get missionGlossary => 'Glossary';

  @override
  String get apprenticeshipComplete => 'Apprenticeship complete!';

  @override
  String get glossaryTitle => 'Glossary';

  @override
  String get glossErbarioTerm => 'Herbarium';

  @override
  String get glossErbarioText =>
      'A collection of plants, once dried and annotated on sheets with the date and place of collection. Here it fills up with the species you meet and study.';

  @override
  String get glossDesiderataTerm => 'Desiderata';

  @override
  String get glossDesiderataText =>
      'In herbaria and among collectors, the list of specimens one wishes to find. Here, the species (up to 3) you have chosen to look for.';

  @override
  String get glossErborizzareTerm => 'Botanizing';

  @override
  String get glossErborizzareText =>
      'Roaming fields and woods to observe and study plants: the historical word for botanists\' field trips.';

  @override
  String get glossStazioneTerm => 'Stand';

  @override
  String get glossStazioneText =>
      'In botany, the precise place where a population of a species grows, with its soil, exposure and altitude. Here, the spot where you met a species and where you can return to draw from it.';

  @override
  String get glossTrattoTerm => 'Trait';

  @override
  String get glossTrattoText =>
      'The condition of the moment when you draw an essence (full moon, rain, fog, dew…). Recipes ask for different traits: the same plant on different days gives different essences.';

  @override
  String get glossAttingereTerm => 'Draw';

  @override
  String get glossAttingereText =>
      'Drawing the essence from a stand without touching the plant: you photograph and observe, you don\'t pick.';

  @override
  String get glossMaestriaTerm => 'Mastery';

  @override
  String get glossMaestriaText =>
      'The final level of a species: you must remember what you learned days later and have drawn the species in the field under different conditions.';

  @override
  String get glossMissioneTerm => 'Quest';

  @override
  String get glossMissioneText =>
      'A goal to reach in the real world or in your studies: meet a species, pass a level, unlock a recipe.';

  @override
  String get debugTitle => 'Testing tools';

  @override
  String debugDays(int days) {
    return 'Simulated day: +$days';
  }

  @override
  String debugAdvance(int days) {
    return '+$days d';
  }

  @override
  String get debugDiario => 'Herbalist\'s Journal (simulated subscription)';

  @override
  String get debugReset => 'Reset progress';

  @override
  String get debugResetConfirm => 'Tap again to delete everything';

  @override
  String get debugResetDone => 'Progress reset';

  @override
  String get notEncounteredYet => 'Not met yet';

  @override
  String get desiderataAddShort => 'Add';

  @override
  String get simulateShort => 'Simulate';

  @override
  String get liverySottobosco => 'Undergrowth';

  @override
  String get dayTimeDawn => 'at dawn';

  @override
  String get dayTimeDay => 'by day';

  @override
  String get dayTimeDusk => 'at dusk';

  @override
  String get dayTimeNight => 'at night';

  @override
  String get liveryFeltro => 'Felt';

  @override
  String studyThemeProgress(String theme, int done, int total) {
    return '$theme · $done of $total';
  }

  @override
  String qOrderOf(String name) {
    return 'Which order does $name belong to?';
  }

  @override
  String qCommonnessOf(String name) {
    return 'How common is $name in this area?';
  }

  @override
  String get optionYes => 'Yes';

  @override
  String get optionNo => 'No';

  @override
  String get commonnessVeryCommon => 'Among the most common';

  @override
  String get commonnessCommon => 'Common';

  @override
  String get commonnessUncommon => 'Less common';

  @override
  String get commonnessRare => 'Among the least observed';

  @override
  String factScientificName(String name, String sci) {
    return 'The scientific name of $name is $sci: the first word is the genus, the second the species.';
  }

  @override
  String factCongeners(String genus, String names) {
    return 'Other species of the genus $genus in Italy: $names.';
  }

  @override
  String factOrder(String name, String order, String family) {
    return '$name belongs to the order $order, which includes the family $family.';
  }

  @override
  String factWarning(String name, String warning) {
    return '$name: $warning. Look at it and photograph it, don\'t taste it. Warning to be verified.';
  }

  @override
  String factCommonness(String name, String commonness) {
    return 'In this area $name is: $commonness (from GBIF observations).';
  }

  @override
  String qGrowthFormOf(String name) {
    return 'What shape is $name?';
  }

  @override
  String qLifeCycleOf(String name) {
    return 'How long does $name live?';
  }

  @override
  String qSeedDispersalOf(String name) {
    return 'How do the seeds of $name travel?';
  }

  @override
  String qOriginOf(String name) {
    return 'Was $name brought to Italy by people?';
  }

  @override
  String qLightOf(String name) {
    return 'How much light does $name like?';
  }

  @override
  String qMoistureOf(String name) {
    return 'What soil does $name prefer?';
  }

  @override
  String get growthTree => 'Tree';

  @override
  String get growthShrub => 'Shrub';

  @override
  String get growthHerb => 'Herb';

  @override
  String get growthClimber => 'Climber';

  @override
  String get cycleAnnual => 'One year (annual)';

  @override
  String get cycleBiennial => 'Two years (biennial)';

  @override
  String get cyclePerennial => 'Many years (perennial)';

  @override
  String get seedsEatenByAnimals => 'In fruits eaten by animals';

  @override
  String get seedsStuckToAnimals => 'Stuck to animal fur';

  @override
  String get seedsHoardedByAnimals => 'Hidden by animals as stores';

  @override
  String get seedsAnts => 'Carried by ants';

  @override
  String get seedsWind => 'On the wind';

  @override
  String get seedsWater => 'By water';

  @override
  String get seedsLaunched => 'Launched by the plant';

  @override
  String get seedsNearby => 'They fall nearby, unaided';

  @override
  String get lightShade => 'Shade';

  @override
  String get lightHalfShade => 'Half shade';

  @override
  String get lightSun => 'Full sun';

  @override
  String get moistureDry => 'Dry';

  @override
  String get moistureFresh => 'Fresh';

  @override
  String get moistureMoist => 'Moist';

  @override
  String factGrowthForm(String name, String form) {
    return 'Shape of $name: $form.';
  }

  @override
  String factLifeCycle(String name, String cycle) {
    return '$name lives $cycle.';
  }

  @override
  String factSeedDispersal(String name, String modes) {
    return 'The seeds of $name: $modes.';
  }

  @override
  String factOriginNative(String name) {
    return '$name is native: it has always grown in Italy, without human help.';
  }

  @override
  String factOriginIntroduced(String name) {
    return '$name was brought to Italy by people: it is not from here.';
  }

  @override
  String factLight(String name, String light) {
    return '$name likes: $light.';
  }

  @override
  String factMoisture(String name, String moisture) {
    return '$name prefers $moisture soil.';
  }

  @override
  String get sourcesTraits => 'Traits: WCVP (Kew), EIVE 1.0, EuDiS, CC BY 4.0';

  @override
  String get sectionTraits => 'What it is like and how it lives';
}
