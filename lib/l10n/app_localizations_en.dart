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
  String get simulateEncounter => 'Simulate Encounter';

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
  String get navRecipes => 'Recipe Book';

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
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Next Rank: $rank at $xpString XP';
  }

  @override
  String get maxRankReached => 'You have reached the highest Rank';

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
    return 'You remembered! Next Review in $days days.';
  }

  @override
  String get answerForgotten =>
      'Forgotten: it will come back in tomorrow\'s Reviews.';

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
    return '$name · Level $level';
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
    return 'Level $level passed: $name joins your Reviews from tomorrow.';
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
  String get summaryNewFunFacts =>
      'New Curiosities on the way: you\'ll get one a day.';

  @override
  String get saveToNotebook => 'Save to Notebook';

  @override
  String get savedToNotebook => 'In your Notebook';

  @override
  String get notebookLocked => 'Save to Notebook';

  @override
  String get diarioUpsell =>
      'With the Herbalist\'s Journal you save what you learn in one tap and find it when you need it, even while studying. Without it you can do the same with a real notebook and the per-species notes, which stay free.';

  @override
  String get notebookTitle => 'Notebook';

  @override
  String get notebookSearch => 'Search: family, month, species, notes…';

  @override
  String get notebookEmpty =>
      'Still empty: while studying, use \"Save to Notebook\".';

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
      'Meet and study a species to receive a daily Curiosity about what you\'ve learned.';

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
    return '$count Facts to review today';
  }

  @override
  String get reviewsNone =>
      'Nothing to review today. What you learn comes back after 1, 3, 7, 21, 60 and 180 days.';

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
      'Study them now or mark them as Desiderata to look for.';

  @override
  String get seasonalStudy => 'Study';

  @override
  String get yourSpeciesMet => 'Met';

  @override
  String get desiderataAdd => 'Add to Desiderata';

  @override
  String get desiderataRemove => 'Remove from Desiderata';

  @override
  String get desiderataFull =>
      'You already have 3 Desiderata: complete or remove one.';

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
    return 'Study Level $level';
  }

  @override
  String get studyButton => 'Study';

  @override
  String get studyComplete => 'Questions complete';

  @override
  String get levelsTitle => 'Study levels';

  @override
  String lockedSection(int level, String name) {
    return 'Revealed at Level $level ($name)';
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
    return '$text · to be verified';
  }

  @override
  String protectedNote(String sources) {
    return 'Protected species ($sources). Look at it and photograph it: don\'t pick it, don\'t trample it, don\'t alter its surroundings and stay on the path.';
  }

  @override
  String get masteryTitle => 'Mastery';

  @override
  String masteryFacts(int done, int total) {
    return 'Consolidated Facts (remembered after 1 and 3 days): $done/$total';
  }

  @override
  String masteryDraws(int done, int total, int traits, int needed) {
    return 'Essences Drawn: $done/$total · different Traits: $traits/$needed';
  }

  @override
  String get masteryOnlyField =>
      'Study alone doesn\'t lead to Mastery: you also need Essences Drawn in the field.';

  @override
  String get masteryReached => 'Mastery reached';

  @override
  String get simulateDraw => 'Simulate Drawing';

  @override
  String get noTrait => 'No Trait';

  @override
  String get traitFrost => '❄️ Frost';

  @override
  String get traitRain => '🌧 Rain';

  @override
  String get traitFog => '🌫 Fog';

  @override
  String get traitSun => '☀️ Sun';

  @override
  String get traitMoon => '🌕 Full moon';

  @override
  String get traitDew => '💧 Dew';

  @override
  String get traitDusk => '🌅 Sunset';

  @override
  String get recipesTitle => 'Recipes';

  @override
  String get recipeAnySpecies => 'any species';

  @override
  String erbarioPages(int done, int total) {
    return 'Pages filled $done/$total';
  }

  @override
  String missionLabel(int index, int total) {
    return 'Quest $index of $total';
  }

  @override
  String get missionVisitErbarioTitle => 'Open the Herbarium';

  @override
  String get missionVisitErbarioBody =>
      'The Herbarium gathers the species of the area, each with photo and name. The rest you discover by studying and Meeting them.';

  @override
  String get missionMarkDesiderataTitle => 'Choose your Desiderata';

  @override
  String get missionMarkDesiderataBody =>
      'Choose up to 3 species to look for: for each you\'ll see photos, season and altitude. Start with one in season now.';

  @override
  String get missionFirstEncounterTitle => 'Meet a species';

  @override
  String get missionFirstEncounterBody =>
      'Go out Botanizing and photograph one of your Desiderata: once recognised it will appear in the Herbarium. Photograph, don\'t pick.';

  @override
  String get missionFirstLevelTitle => 'Study your first species';

  @override
  String get missionFirstLevelBody =>
      'Pick a species in season and pass its first study Level: you can start from home. Mistakes teach too, and they earn XP.';

  @override
  String get missionFirstRecipeTitle => 'Your first Recipe';

  @override
  String get missionFirstRecipeBody =>
      'Studying a species teaches you its Common Recipe: you\'ll find it in the Recipe Book, on the plant\'s Page. The other Plates on the Page come from the Trove of Experience.';

  @override
  String get missionSkip => 'Skip the Apprenticeship';

  @override
  String get missionActionOpenErbario => 'Open the Herbarium';

  @override
  String get missionActionChooseDesiderata => 'Choose in the Herbarium';

  @override
  String get missionActionStudy => 'Start studying';

  @override
  String get missionActionRecipes => 'Open the Recipe Book';

  @override
  String get missionGlossary => 'Glossary';

  @override
  String get apprenticeshipComplete => 'Apprenticeship complete!';

  @override
  String get glossaryTitle => 'Legend and glossary';

  @override
  String get glossErbarioTerm => 'Herbarium';

  @override
  String get glossErbarioText =>
      'A collection of plants, once dried and annotated on sheets with the date and place of collection. Here it fills up with the species you Meet and study.';

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
  String get glossStazioneTerm => 'Station';

  @override
  String get glossStazioneText =>
      'In botany, the precise place where a population of a species grows, with its soil, exposure and altitude. Here, the spot where you Met a species and where you can return to Draw from it.';

  @override
  String get glossTrattoTerm => 'Trait';

  @override
  String get glossTrattoText =>
      'A condition of the moment when you Draw an Essence (Full moon, Rain, Fog, Dew…): an Essence carries all of them. Recipes ask for different Traits: the same plant on different days gives different Essences.';

  @override
  String get glossAttingereTerm => 'Draw';

  @override
  String get glossAttingereText =>
      'Drawing the Essence from a Station without touching the plant: you photograph and observe, you don\'t pick.';

  @override
  String get glossMaestriaTerm => 'Mastery';

  @override
  String get glossMaestriaText =>
      'The final Level of a species: you must remember what you learned days later and have Drawn the species in the field under different conditions.';

  @override
  String get glossMissioneTerm => 'Quest';

  @override
  String get glossMissioneText =>
      'A goal to reach in the real world or in your studies: Meet a species, pass a Level, unlock a Recipe.';

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
  String get notEncounteredYet => 'Not Met yet';

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

  @override
  String xpToCash(int xp) {
    return '$xp XP to Cash in: you Cash them in with the first Essence of each species';
  }

  @override
  String speciesXpToCash(int xp) {
    return '$xp XP to Cash in: Draw the first Essence of this species.';
  }

  @override
  String get summaryXpToCash =>
      'The XP from studying this species are Cashed in when you Draw its first Essence.';

  @override
  String visStored(int vis) {
    return 'Vis stored: $vis';
  }

  @override
  String get drawExhausted => 'Exhausted: ready again tomorrow';

  @override
  String get drawNeedsEncounter => 'Drawing needs a Station: Meet it first';

  @override
  String get gradeCommon => 'Common';

  @override
  String get gradeUncommon => 'Uncommon';

  @override
  String get gradeRare => 'Rare';

  @override
  String get gradeMythic => 'Mythic';

  @override
  String get protectionEmiliaRomagna => 'Emilia-Romagna regional law 2/1977';

  @override
  String protectionHabitats(String annex) {
    return 'Habitats Directive, Annex $annex';
  }

  @override
  String summaryRecipeLearned(String name) {
    return 'You learned a Recipe: $name';
  }

  @override
  String get debugGradePreview => 'Grade preview';

  @override
  String get debugGradeSampleName => 'Sample Elixir';

  @override
  String get debugGradeSampleIngredient => 'Honesty';

  @override
  String get debugGradeSampleEffect =>
      'The next Draw under a Full moon gets an extra Trait (game effect).';

  @override
  String get badgeEncountered => 'Met on';

  @override
  String get badgeProtected => 'Protected Species';

  @override
  String get legendTitle => 'Legend';

  @override
  String get glossarySection => 'Glossary';

  @override
  String get legendGrades => 'Grades (Recipes, Potions, Trove)';

  @override
  String get legendBadges => 'Badges';

  @override
  String get legendProtected =>
      'Species protected by law: look and photograph only';

  @override
  String get legendEncountered => 'Species Met, with the date you Met it';

  @override
  String get legendXpToCash => 'XP to Cash in with the species\' first Essence';

  @override
  String get legendLevels => 'Study levels';

  @override
  String get legendTraits => 'Essence Traits';

  @override
  String get glossProtettaTerm => 'Protected';

  @override
  String get glossProtettaText =>
      'A species protected by the Habitats Directive or a regional law. Look and photograph: don\'t pick it, don\'t trample it, stay on the path.';

  @override
  String get glossEssenzaTerm => 'Essence';

  @override
  String get glossEssenzaText =>
      'What you Draw from a Station: it has a Purity, which grows with your knowledge of the species, and Traits, given by the conditions of the moment.';

  @override
  String get glossVisTerm => 'Vis';

  @override
  String get glossVisText =>
      'The subtle sap of plants: the energy you store with each Draw. Recipes ask for an amount of it for each Ingredient.';

  @override
  String get glossPeDaIncassareTerm => 'XP to Cash in';

  @override
  String get glossPeDaIncassareText =>
      'The Experience Points from studying a species you haven\'t Drawn yet. You Cash them in with that species\' first Essence, and from then on they count for your Rank.';

  @override
  String get glossGradoTerm => 'Grade';

  @override
  String get glossGradoText =>
      'Common, Uncommon, Rare, Mythic: white, silver, gold, red gold. It applies to Ingredients, Recipes, Potions and the Trove of Experience.';

  @override
  String get glossBottinoTerm => 'Trove of Experience';

  @override
  String get glossBottinoText =>
      'The Trove you buy with XP: you choose the Grade, the content is a surprise (Recipes, rare Curiosities, hints).';

  @override
  String get glossFigurinaTerm => 'Figurine';

  @override
  String get glossFigurinaText =>
      'A Recipe or a Potion in the Album. The Recipe Album shows the ones you know; the counter says how many there are in all.';

  @override
  String get recipesEmpty =>
      'You don\'t know any Recipe yet. Every plant has its own Common Recipe: you learn it by passing Level 1 of the species, from Home or the Herbarium.';

  @override
  String get viewAll => 'All';

  @override
  String get viewInSeason => 'In season now';

  @override
  String get viewDesiderata => 'My Desiderata';

  @override
  String get viewProtected => 'Protected';

  @override
  String get viewNew => 'New view';

  @override
  String get viewName => 'View name';

  @override
  String get viewStatus => 'Status';

  @override
  String get viewWhen => 'When and how';

  @override
  String get viewProtectedOnly => 'Protected only';

  @override
  String get viewBand => 'Altitude';

  @override
  String get viewForm => 'Shape';

  @override
  String get viewFamily => 'Family';

  @override
  String get viewSave => 'Save the view';

  @override
  String get viewRemove => 'Delete the view';

  @override
  String get viewEmpty => 'No species in this view.';

  @override
  String get statusMet => 'Met';

  @override
  String get statusToFind => 'To find';

  @override
  String get statusDesiderata => 'Desiderata';

  @override
  String get statusStudying => 'Studying';

  @override
  String get traitDawn => '🌄 Dawn';

  @override
  String get traitNewMoon => '🌑 New moon';

  @override
  String get traitWaxingMoon => '🌓 Waxing moon';

  @override
  String get traitWaningMoon => '🌗 Waning moon';

  @override
  String get legendTraitsDaylight => 'Daylight';

  @override
  String get legendTraitsMoon => 'Moon';

  @override
  String get legendTraitsWeather => 'Weather';

  @override
  String get traitWhenFrost => 'When it is below freezing: hoarfrost and ice.';

  @override
  String get traitWhenRain =>
      'While it rains. During a thunderstorm Drawing is suspended.';

  @override
  String get traitWhenFog => 'When there is fog.';

  @override
  String get traitWhenSun => 'With sunshine and few clouds.';

  @override
  String get traitWhenMoon =>
      'All day long on the full moon: no need to go out at night.';

  @override
  String get traitWhenDew =>
      'From sunrise to about two hours later, after a cool clear night: the grass is still wet.';

  @override
  String get traitWhenDusk =>
      'From about an hour before sunset until sunset, never after dark.';

  @override
  String get traitWhenDawn =>
      'From first light to about an hour after sunrise.';

  @override
  String get traitWhenNewMoon =>
      'All day long on the new moon: no need to go out at night.';

  @override
  String get traitWhenWaxingMoon =>
      'Every day the moon is growing, from new to full: no need to go out at night.';

  @override
  String get traitWhenWaningMoon =>
      'Every day the moon is shrinking, from full to new: no need to go out at night.';

  @override
  String get recipeBookTitle => 'Recipe Book';

  @override
  String recipeBookPlates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Plates',
      one: '1 Plate',
    );
    return '$_temp0';
  }

  @override
  String recipeBookPagesSummary(int pages, int total, int complete) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages Pages',
      one: '1 Page',
    );
    return '$_temp0 of $total · $complete complete';
  }

  @override
  String recipeBookPageCount(int known, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      known,
      locale: localeName,
      other: '$known Plates',
      one: '1 Plate',
    );
    return '$_temp0 of $total';
  }

  @override
  String get recipeBookFavouredTraits => 'Favoured traits';

  @override
  String get recipeBookVocation => 'Vocation';

  @override
  String get recipeBookMissingPlate => 'Plate to find';

  @override
  String get recipeBookSwipeHint => 'Swipe to leaf through the Pages';

  @override
  String recipeBookSpeciesLink(int known, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      known,
      locale: localeName,
      other: '$known Plates',
      one: '1 Plate',
    );
    return 'Recipe Book · $_temp0 of $total';
  }

  @override
  String get recipeMonths => 'When it can be made';

  @override
  String get recipeNever =>
      'Never: the ingredients are not found in the same months';

  @override
  String get recipeEffect => 'Effect';

  @override
  String get effectRegrowth => 'Regrowth';

  @override
  String get effectClarity => 'Clarity';

  @override
  String get effectOmen => 'Omens';

  @override
  String get effectAbundance => 'Abundance';

  @override
  String get effectRegrowthText =>
      'The Station where you use it is ready sooner (game effect).';

  @override
  String get effectClarityText =>
      'Extra purity on your next Essence (game effect).';

  @override
  String get effectOmenText =>
      'A guaranteed Trait on your next Essence (game effect).';

  @override
  String get effectAbundanceText =>
      'Extra Vis on your next Essence (game effect).';

  @override
  String mythicNumber(String number) {
    return 'Plate No. $number';
  }

  @override
  String get mythicToFind => 'To find';

  @override
  String mythicWindow(String from, String to) {
    return 'Only from $from to $to';
  }

  @override
  String get mythicAllYear => 'All year round';

  @override
  String get mythicsIntro =>
      'The Mythics of the Area: handwritten, tied to its places and feasts. They only come from the mythic Trove of Experience.';

  @override
  String recipeBookMythicsRow(String zone) {
    return 'Mythics · $zone';
  }

  @override
  String recipeBookMythicsCount(int known, int total) {
    return '$known of $total';
  }

  @override
  String get debugSimulateRecipeBook => 'Simulate a Recipe Book';

  @override
  String debugSimulateRecipeBookDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Plates added',
      one: '1 Plate added',
    );
    return '$_temp0 to the Recipe Book';
  }

  @override
  String get troveTitle => 'Trove of Experience';

  @override
  String get navTrove => 'Trove';

  @override
  String get labBalance => 'Balance';

  @override
  String labBalanceXp(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '$xpString XP to spend';
  }

  @override
  String labTrovesLeft(int left, int total) {
    return '$left of $total today';
  }

  @override
  String troveName(String grade) {
    return 'Trove of Experience · $grade';
  }

  @override
  String get troveGradeCommon => 'common';

  @override
  String get troveGradeUncommon => 'uncommon';

  @override
  String get troveGradeRare => 'rare';

  @override
  String get troveGradeMythic => 'mythic';

  @override
  String get troveContentsCommon =>
      'Almost always a Common, sometimes an Uncommon';

  @override
  String get troveContentsUncommon =>
      'Mostly Uncommons, sometimes a Common or a Rare';

  @override
  String get troveContentsRare => 'Mostly Rares, sometimes an Uncommon';

  @override
  String get troveContentsMythic => 'A Rare or a Mythic, half and half';

  @override
  String troveSpend(int cost) {
    final intl.NumberFormat costNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String costString = costNumberFormat.format(cost);

    return 'Spend $costString XP';
  }

  @override
  String troveNeedXp(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'You need $xpString more XP';
  }

  @override
  String troveCostMissing(int cost, int xp) {
    final intl.NumberFormat costNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String costString = costNumberFormat.format(cost);
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Costs $costString XP: you need $xpString more';
  }

  @override
  String troveDailyLimit(int total) {
    return 'That\'s enough for today: $total Trove of Experience a day. Come back tomorrow.';
  }

  @override
  String get troveRules =>
      'Uncommon, Rare and Mythic Plates come out incomplete: the missing components are found in other Trove of Experience. With the first common and the first uncommon, a Plate of the grade above as a gift. Mythics only come from the mythic Trove of Experience.';

  @override
  String labIncomplete(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count incomplete Plates',
      one: '1 incomplete Plate',
    );
    return '$_temp0';
  }

  @override
  String labRecycled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recycled',
      one: '1 recycled',
    );
    return '$_temp0';
  }

  @override
  String get welcomeGiftTitle => 'Hey, there\'s a gift for you';

  @override
  String welcomeGiftBody(int full, int price) {
    final intl.NumberFormat fullNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String fullString = fullNumberFormat.format(full);
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    return 'Your first Trove of Experience · rare at a friendly price: $priceString XP instead of $fullString.';
  }

  @override
  String get welcomeGiftWaiting =>
      'You can redeem it after an Essence: go out and draw from a station.';

  @override
  String welcomeGiftRedeem(int price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    return 'Redeem · $priceString XP';
  }

  @override
  String get troveTapToTurn => 'Tap the Plates to turn them';

  @override
  String get troveFindNew => 'New Plate';

  @override
  String troveFindIncomplete(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count components missing',
      one: '1 component missing',
    );
    return 'New Plate · $_temp0';
  }

  @override
  String get troveFindPiece => 'A component found';

  @override
  String get troveFindCompleted => 'Plate completed';

  @override
  String troveFindRecycled(String grade) {
    return 'Duplicate: 1 $grade recycled';
  }

  @override
  String get troveFindTaste => 'A taste of the grade above';

  @override
  String get troveNothing => 'Nothing new this time.';

  @override
  String get troveDone => 'Done';

  @override
  String recipeMissingPieces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count components missing',
      one: '1 component missing',
    );
    return '$_temp0';
  }

  @override
  String get recipeEffectUnknown =>
      'Still to discover: a component of the name is missing.';

  @override
  String get debugGrantXp => 'Add 5,000 XP';

  @override
  String get recycleTitle => 'Recycling';

  @override
  String get recycleIntro =>
      'Every duplicate is one recycled of its grade. 3 recycled make a component of the same grade, 9 one of the grade above, for an incomplete Plate of your choice. It costs a little Vis.';

  @override
  String recycleVis(int vis) {
    return '$vis Vis to spend';
  }

  @override
  String recycleUse(int count, String grade, int vis) {
    return '$count $grade recycled · $vis Vis';
  }

  @override
  String recycleNeedVis(int vis) {
    return 'You need $vis Vis';
  }

  @override
  String get recycleNothing =>
      'With the recycled you have you can\'t make a component yet.';

  @override
  String recycleDone(String name) {
    return 'Component added: $name';
  }

  @override
  String recycleCompleted(String name) {
    return 'Plate completed: $name';
  }

  @override
  String get recycledGradeCommon => 'common';

  @override
  String get recycledGradeUncommon => 'uncommon';

  @override
  String get recycledGradeRare => 'rare';

  @override
  String get recycledGradeMythic => 'mythic';
}
