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
  String get desiderataEmpty =>
      'Choose the species to look for: you\'ll see photos and where and when to find them.';

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
      'In herbaria and among collectors, the list of specimens one wishes to find. Here, the species you have chosen to look for, as many as you like.';

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
      'The final Level of a species: you must remember what you learned days later and have Drawn the species in the field under different conditions. It has to be kept: after 30 days without questions about the species it falls dormant, and a short quiz reawakens it.';

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
      'The Trove you buy with XP: choose the grade and spend your balance; inside there\'s a surprise Plate, often incomplete, or a component of one you have. Mythics only come from the mythic Trove.';

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
      'For 7 days species are ready again sooner, down to 12 hours later (game effect).';

  @override
  String get effectClarityText =>
      'For 7 days extra purity on every Essence (game effect).';

  @override
  String get effectOmenText =>
      'For 7 days an Essence without traits can take the plant\'s favoured trait (game effect).';

  @override
  String get effectAbundanceText =>
      'For 7 days extra Vis on every Essence, up to +50% (game effect).';

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
      'You can redeem it after an Essence: go out and Draw from a Station.';

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

  @override
  String get labTitle => 'Laboratory';

  @override
  String get navLaboratory => 'Laboratory';

  @override
  String get pantryTitle => 'Pantry';

  @override
  String pantryEssences(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Essences',
      one: '1 Essence',
    );
    return '$_temp0';
  }

  @override
  String pantrySpeciesSummary(int count, int vis) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Essences',
      one: '1 Essence',
    );
    return '$_temp0 · $vis Vis';
  }

  @override
  String pantryPurity(int percent) {
    return 'Purity $percent%';
  }

  @override
  String pantryVis(int vis) {
    return '$vis Vis';
  }

  @override
  String get pantryNoTraits => 'No traits';

  @override
  String get pantryEmpty =>
      'The Pantry is empty: the Essences you Draw from Stations stay here, with their traits, purity and Vis. For now you Draw with \"Simulate Drawing\" in the species card.';

  @override
  String get debugSimulatePantry => 'Simulate a Pantry';

  @override
  String debugSimulatePantryDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Essences added',
      one: '1 Essence added',
    );
    return '$_temp0 to the Pantry';
  }

  @override
  String get labTabReady => 'Ready recipes';

  @override
  String get labTabShelf => 'Shelf';

  @override
  String readyCount(int count) {
    return '$count ready';
  }

  @override
  String shelfCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count potions',
      one: '1 potion',
    );
    return '$_temp0';
  }

  @override
  String get readySection => 'Ready to brew';

  @override
  String get readyAlmost => 'Almost there';

  @override
  String readyOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more recipes need',
      one: 'Another recipe needs',
    );
    return '$_temp0 more Essences: you\'ll find them in the Recipe Book.';
  }

  @override
  String get readyEmpty =>
      'You don\'t know any recipes to brew yet: Commons are learned by studying, the others in the Trove of Experience.';

  @override
  String get readyAnyPlant => 'a plant of your choice';

  @override
  String get brewButton => 'Brew';

  @override
  String get brewChooseFree => 'Choose the plant for the free slot';

  @override
  String get brewChooseFreeHint => 'It gives the potion its Touch.';

  @override
  String brewFreeOption(int vis) {
    return '$vis Vis';
  }

  @override
  String get potionTitle => 'Potion';

  @override
  String potionPotency(int potency) {
    return 'Potency $potency';
  }

  @override
  String potionTouch(String touch) {
    return 'Touch: $touch';
  }

  @override
  String potionFirstBonus(int xp) {
    return 'First potion of this recipe: +$xp XP';
  }

  @override
  String get potionSpoiledTitle => 'The potion spoiled';

  @override
  String potionSpoiledText(String name) {
    return '$name: a toxic plant. In a drinkable recipe it spoils the potion: the Vis are lost, but now you know.';
  }

  @override
  String get shelfEmpty =>
      'The Shelf is empty: the potions you brew stay here.';

  @override
  String recipeBestPotency(int potency) {
    return 'Best potency: $potency';
  }

  @override
  String readyMissingVis(int vis) {
    return 'You need $vis more Vis';
  }

  @override
  String get shelfUse => 'Use';

  @override
  String get shelfHint =>
      'Keep it for the collection or use it: the effect lasts 7 days, as strong as its potency; the Touch adds a small extra effect.';

  @override
  String get shelfActive => 'Effects in progress';

  @override
  String shelfActiveLine(String effect, int strength, String date) {
    return '$effect · strength $strength · until $date';
  }

  @override
  String shelfUsed(String effect) {
    return '$effect for 7 days';
  }

  @override
  String get glossTavolaTerm => 'Plate';

  @override
  String get glossTavolaText =>
      'A recipe in the Recipe Book, like the illustrated plates of herbaria: \"1 Plate of 3\". On a plant\'s Page the Plates you don\'t have are empty slots with the grade circle.';

  @override
  String get glossLaboratorioTerm => 'Laboratory';

  @override
  String get glossLaboratorioText =>
      'Your base, the greenhouse shed at the edge of the woods: you work inside it, with the Recipe Book, Pantry, Ready recipes and Shelf.';

  @override
  String get glossRicettarioTerm => 'Recipe Book';

  @override
  String get glossRicettarioText =>
      'The collection of Plates, one per country: a Page for each plant and, at the top, the Mythics of the Area, numbered.';

  @override
  String get glossComponenteTerm => 'Component';

  @override
  String get glossComponenteText =>
      'A piece of the name of an incomplete Plate (\"Frosted Eranthis Tincture of…\"): Uncommons, Rares and Mythics come out of the Trove of Experience with components still to find.';

  @override
  String get glossRiciclatoTerm => 'Recycled';

  @override
  String get glossRiciclatoText =>
      'A duplicate from the Trove of Experience: 3 recycled of a grade make a component of the same grade, 9 one of the grade above, for a little Vis.';

  @override
  String get glossDispensaTerm => 'Pantry';

  @override
  String get glossDispensaText =>
      'The Essences you\'ve drawn, each with its traits, purity (from the plant\'s study level when you drew it) and its Vis.';

  @override
  String get glossRicettePronteTerm => 'Ready recipes';

  @override
  String get glossRicettePronteText =>
      'The recipes you can brew now with your Pantry, and the ones that are almost there, with what\'s missing.';

  @override
  String get glossPozioneTerm => 'Potion';

  @override
  String get glossPozioneText =>
      'Brewed from a recipe with the Vis of your Essences. It has a potency from 1 to 10, mostly from purity: the better you know the plants, the stronger it is. You keep it on the Shelf or use it.';

  @override
  String get glossToccoTerm => 'Touch';

  @override
  String get glossToccoText =>
      'The adjective the plant in the free slot gives the potion (Lush, Clear, Prescient, Bountiful): when you use it, it adds a small effect.';

  @override
  String get glossPozioneGuastataTerm => 'Spoiled potion';

  @override
  String get glossPozioneGuastataText =>
      'A drinkable potion with a toxic plant in the free slot: the Vis are lost, but you learn the plant is toxic.';

  @override
  String get glossScaffaleTerm => 'Shelf';

  @override
  String get glossScaffaleText =>
      'The potions you have: keep them for the collection or use them. The effect lasts 7 days, as strong as the potency.';

  @override
  String get legendPotions => 'Potions';

  @override
  String get legendVessel =>
      'The vessel shows the recipe\'s base (Infusion, Tincture, Philtre…), the colour of the liquid its traits: one layer per trait. The icon at the top right is the effect.';

  @override
  String get viewMet => 'Met';

  @override
  String get erbarioSpecies => 'Species';

  @override
  String get tipOfDayTitle => 'Tip of the day';

  @override
  String get tip01 =>
      'The more you study a plant, the purer the Essences you draw from it: purity goes from 40% (a plant you never studied) to 100% (a plant you have Mastery of).';

  @override
  String get tip02 =>
      'A potion\'s Potency depends mostly on the purity of the Essences you use: the better you know the plants in a recipe, the stronger your potions.';

  @override
  String get tip03 =>
      'The Common Plates of the Recipe Book are learned by studying: when you pass level 1 of a species, that plant\'s Common Plate enters your Recipe Book.';

  @override
  String get tip04 =>
      'Uncommon, Rare and Mythic Plates come out of the Trove of Experience incomplete, with their name in pieces: each missing piece is a Component, found by opening more Trove of Experience.';

  @override
  String get tip05 =>
      'Mythic Plates are only found by opening a mythic-grade Trove of Experience.';

  @override
  String get tip06 =>
      'If the Trove of Experience gives you a Plate or a Component you already have, it\'s a duplicate: recycle it with a little Vis. 3 Recycled make a Component of the same grade, 9 a Component of the grade above.';

  @override
  String get tip07 =>
      'Recycling a duplicate costs a little Vis, taken from your Essences: the least precious Essences are used first, so the ones with Traits stay for recipes.';

  @override
  String get tip08 =>
      'Every recipe has a free slot, “any species”: the plant you put there gives the potion its Touch (Lush, Clear, Prescient or Bountiful).';

  @override
  String get tip09 =>
      'Beware of the free slot in recipes to drink: with a toxic plant the potion spoils and you lose the Vis used, but you learn that plant is toxic.';

  @override
  String get tip10 =>
      'In the Laboratory, the Ready recipes tab shows the recipes you can make now and, for the others, which Essences you are missing: it\'s the list of plants to look for on your next outing.';

  @override
  String get tip11 =>
      'When you use a potion from the Shelf, its effect lasts 7 days and is as strong as its Potency.';

  @override
  String get tip12 =>
      'An Essence\'s Traits tell the conditions you drew it in (weather, time of day, moon); a recipe\'s name says which Traits it needs: “Full-moon” asks for an Essence drawn under the Full moon.';

  @override
  String get tip13 =>
      'The XP you earn studying a species stays to Cash in until you draw the first Essence of that species: only then does it become real XP.';

  @override
  String get tip14 =>
      'The meaning of symbols, colours and grades is in the Legend: Settings → Legend and glossary.';

  @override
  String get tip15 =>
      'In the game a plant is never picked: you photograph it and draw its Vis. Plants stay where they are, untouched.';

  @override
  String get viewToFind => 'To find';

  @override
  String get levelMasteryDormant => 'Dormant Mastery';

  @override
  String get masteryToAwaken => 'Mastery to reawaken';

  @override
  String get awakenButton => 'Reawaken';

  @override
  String get awakenMasteryButton => 'Reawaken your Mastery';

  @override
  String masteryKeepHint(int days) {
    return 'Mastery is kept by answering a question about this species now and then: after $days days without one, it falls dormant.';
  }

  @override
  String masteryDormantText(
    int days,
    int dormant,
    int full,
    int questions,
    int needed,
  ) {
    return 'After $days days without questions about this species your Mastery has fallen dormant: new Essences are $dormant% pure instead of $full%. Reawaken it with $questions questions from every Level: $needed right answers are enough.';
  }

  @override
  String get awakeningTheme => 'Reawakening your Mastery';

  @override
  String summaryAwakened(String name, int full) {
    return 'Mastery reawakened: Essences of $name are $full% pure again.';
  }

  @override
  String summaryStillDormant(int needed, int total) {
    return 'Still dormant: you need at least $needed right answers out of $total. You can try again right away.';
  }

  @override
  String get tip16 =>
      'A species\' Mastery has to be kept: if for 30 days you answer no questions about that species, its Mastery falls dormant. Reawaken it with 5 questions, from the species page or from “Your species” on Home.';

  @override
  String get simulateMastery => 'Simulate Mastery';

  @override
  String get debugFieldTest => 'Field test';

  @override
  String get fieldTestIntro =>
      'Each test takes a photo, sends it to Pl@ntNet and measures GPS from the tap for at least 20 seconds (and 10 after the photo). Tests are saved to a CSV to pull with adb.';

  @override
  String get fieldTestExpected => 'Expected plant';

  @override
  String get fieldTestExpectedHint =>
      'e.g. green hellebore, Helleborus viridis';

  @override
  String get fieldTestPlace => 'Place';

  @override
  String get fieldTestPlaceHint => 'sun, under trees, town…';

  @override
  String get fieldTestRun => 'Shoot and measure';

  @override
  String get fieldTestPhasePhoto => 'Camera…';

  @override
  String get fieldTestPhaseIdentifying => 'Pl@ntNet is looking at the photo…';

  @override
  String get fieldTestPhaseLocating => 'GPS: a few more seconds…';

  @override
  String get fieldTestNoKey =>
      'The Pl@ntNet key (PLANTNET_API_KEY) is missing: photo and GPS are measured, identification is not.';

  @override
  String fieldTestOutcome(String outcome) {
    return 'Outcome: $outcome';
  }

  @override
  String fieldTestTimes(String photo, String plantnet, String kb) {
    return 'Photo in $photo s · Pl@ntNet in $plantnet ms · $kb KB';
  }

  @override
  String fieldTestGps(String first, String a5, String a10, String a20) {
    return 'GPS: first fix after $first s · accuracy at 5 s $a5 m, at 10 s $a10 m, at 20 s $a20 m';
  }

  @override
  String fieldTestGpsAfterPhoto(int during, String first, String accuracy) {
    return 'Fixes during the photo: $during · after the photo the first in $first s, accuracy $accuracy m';
  }

  @override
  String fieldTestRemaining(String count) {
    return 'Identifications left today: $count';
  }

  @override
  String fieldTestRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tests saved',
      one: '1 test saved',
      zero: 'No tests saved',
    );
    return '$_temp0';
  }

  @override
  String get fieldTestCopy => 'Copy the CSV';

  @override
  String get fieldTestCopied => 'CSV copied';

  @override
  String get fieldTestClear => 'Delete the tests';

  @override
  String get fieldTestClearConfirm => 'Tap again to delete them';

  @override
  String get cameraClose => 'Close the camera';

  @override
  String get cameraShutter => 'Shoot';

  @override
  String cameraGps(int metres) {
    return 'GPS ±$metres m';
  }

  @override
  String get cameraGpsSearching => 'GPS…';

  @override
  String get cameraGpsOff => 'GPS off';

  @override
  String get cameraDenied =>
      'To photograph plants the app needs the camera permission: grant it from Android settings, under the app\'s Permissions.';

  @override
  String cameraError(String error) {
    return 'The camera did not open ($error).';
  }

  @override
  String cameraDebug(
    String size,
    String received,
    String analyzed,
    String ms,
    String sharpness,
    String motion,
  ) {
    return '$size · $received fps · analysed $analyzed/s · $ms ms · sharpness $sharpness · motion $motion';
  }

  @override
  String get fieldTestSystemCamera => 'System camera (for comparison)';

  @override
  String fieldTestCamera(
    String fps,
    String analyzed,
    String ms,
    String capture,
    String resize,
  ) {
    return 'Camera: $fps fps, analysed $analyzed/s in $ms ms · shot $capture ms · resize $resize ms';
  }

  @override
  String get cameraFlashOff => 'Flash off';

  @override
  String get cameraFlashAuto => 'Flash auto';

  @override
  String get cameraFlashOn => 'Flash on';

  @override
  String cameraZoom(String zoom) {
    return 'Zoom $zoom';
  }

  @override
  String get cameraGatherHint =>
      'Frame the whole plant: the Vis rises while you photograph it, faster if you move';

  @override
  String get cameraShutterLocked =>
      'Just a moment: the Vis is starting to rise';

  @override
  String get cameraLeafHint => 'Now get close to a leaf';

  @override
  String get cameraFlowerHint => 'And a flower, if there is one';

  @override
  String get cameraNoFlower => 'No flowers';

  @override
  String get cameraOrganWhole => 'Whole plant';

  @override
  String get cameraOrganLeaf => 'Leaf';

  @override
  String get cameraOrganFlower => 'Flower';

  @override
  String get fieldTestRegional =>
      'Compare with the regional flora (2 identifications)';

  @override
  String get fieldTestRegionalResult => 'Regional flora (Southeastern Europe)';

  @override
  String get cameraZoomSlower => 'Without zoom the Vis rises faster';

  @override
  String get tip17 =>
      'When you photograph a plant, its Vis rises as long as you frame it: take your time and move slowly around it, from the whole plant to a leaf to a flower. The patient gather more Vis.';

  @override
  String get captureNoKey =>
      'The Pl@ntNet key (PLANTNET_API_KEY) is missing: for now try Encounters with Simulate Encounter.';

  @override
  String get captureLimitTitle => 'No more new Stations today';

  @override
  String get captureLimitText =>
      'A new Station was already born today: tomorrow you can photograph another plant. Stations need their time.';

  @override
  String get captureGuessTitle => 'Which plant do you think it is?';

  @override
  String get captureGuessHint => 'Common or scientific name';

  @override
  String get captureGuessConfirm => 'That\'s my guess';

  @override
  String get captureGuessSkip => 'I don\'t know';

  @override
  String get captureIdentifying => 'Pl@ntNet is looking at the photos…';

  @override
  String captureFailed(String error) {
    return 'Pl@ntNet did not answer ($error).';
  }

  @override
  String get captureRetry => 'Try again';

  @override
  String get captureNone =>
      'Pl@ntNet doesn\'t recognise this plant: try again closer, with light on the plant, and photograph a leaf or a flower too.';

  @override
  String get captureContested =>
      'Pl@ntNet can\'t decide: which one is in front of you?';

  @override
  String get captureProposed => 'Pl@ntNet thinks it is:';

  @override
  String get captureConfirm => 'That\'s it';

  @override
  String get captureKindDiscovery => 'Discovery';

  @override
  String get captureKindGuest => 'Guest';

  @override
  String get captureGuestText =>
      'It is not native to your places: it is a Guest, and its Vis here is very weak.';

  @override
  String get captureDiscoveryText =>
      'It has never been recorded in your Area: it is a Discovery, to be confirmed.';

  @override
  String get captureGuessExact => 'You got it!';

  @override
  String captureGuessGenus(String genus) {
    return 'Close! It is a $genus.';
  }

  @override
  String captureGuessWrong(String guess) {
    return 'Your guess was “$guess”.';
  }

  @override
  String get captureStationCreated => 'A new Station is born.';

  @override
  String get captureStationExisting => 'You are at your Station of this plant.';

  @override
  String get captureStationNoPosition =>
      'No position: the Encounter counts, the Station doesn\'t.';

  @override
  String get captureStationLimit =>
      'A new Station was already born today: this one counts as an Encounter.';

  @override
  String captureXp(int xp) {
    return '+$xp XP';
  }

  @override
  String get captureDone => 'Done';

  @override
  String get captureAction => 'Draw';

  @override
  String get captureTitle => 'Draw the Vis';

  @override
  String get captureFromSpecies => 'Draw its Vis';

  @override
  String get captureFirstPhoto =>
      'Your photo takes the place of the Herbarium one, with today\'s stamp.';

  @override
  String ownPhotoStamp(String date) {
    return 'Your photo · $date';
  }

  @override
  String get sectionStations => 'Your Stations';

  @override
  String stationAccuracy(int meters) {
    return '± $meters m';
  }

  @override
  String get stationsNote =>
      'Only on your phone: the exact spot is never shown or shared.';

  @override
  String get firstRunWelcomeTitle => 'Welcome to Druid';

  @override
  String get firstRunWelcomeIntro =>
      'You are a herbalist: you find real plants, photograph them, study them and brew fantasy potions with their Essences. Before you start, the rules of the game in the real world.';

  @override
  String get firstRunRuleNoPickTitle => 'Photograph, don\'t pick';

  @override
  String get firstRunRuleNoPickText =>
      'Plants are never picked: you photograph them and they stay where they are. Don\'t tear off leaves or flowers and don\'t trample them.';

  @override
  String get firstRunRuleProtectedTitle => 'Protected species and areas';

  @override
  String get firstRunRuleProtectedText =>
      'Some species are protected by law. In parks and reserves stay on the paths and respect their rules.';

  @override
  String get firstRunRulePrivateTitle => 'No private property';

  @override
  String get firstRunRulePrivateText =>
      'Don\'t enter private gardens, fields or land without permission: photograph from where you are allowed to be.';

  @override
  String get firstRunRuleDaylightTitle => 'In daylight';

  @override
  String get firstRunRuleDaylightText =>
      'Don\'t go out to play at night or in poor light. Moon Traits last all day: you never need to.';

  @override
  String get firstRunRuleSafetyTitle => 'Watch your step';

  @override
  String get firstRunRuleSafetyText =>
      'Mind the ground and the traffic: don\'t take photos while crossing the road or driving. If you go far, tell someone where you are going.';

  @override
  String get firstRunRuleToxicTitle => 'Plants are not food';

  @override
  String get firstRunRuleToxicText =>
      'Many plants are toxic. Don\'t eat them and don\'t use them as remedies: the game\'s potions are fantasy and give no real instructions for use.';

  @override
  String get firstRunRuleIdentifyTitle => 'Identification can be wrong';

  @override
  String get firstRunRuleIdentifyText =>
      'Pl@ntNet recognises plants from photos, but it can be wrong. Toxicity warnings are to be checked.';

  @override
  String get firstRunRulePrivacyTitle => 'Your photos and your location';

  @override
  String get firstRunRulePrivacyText =>
      'Photos go to Pl@ntNet only to recognise the plant. The location of your Stations stays on your phone: it is never shown or shared.';

  @override
  String get firstRunTermsFooter =>
      'By tapping I agree you confirm you have read these rules and will play carefully and respectfully.';

  @override
  String get firstRunAccept => 'I agree';

  @override
  String get firstRunCameraTitle => 'Photos of plants';

  @override
  String get firstRunCameraText =>
      'To Meet a plant you photograph it with the app\'s camera: the whole plant, a leaf and the flower if there is one. Pl@ntNet recognises it and your photo goes into the Herbarium.';

  @override
  String get firstRunCameraAllow => 'Allow';

  @override
  String get firstRunCameraDenied =>
      'Without the camera you can\'t Meet plants. You can grant the permission at any time in Android settings, under App permissions.';

  @override
  String get firstRunLocationTitle => 'Location';

  @override
  String get firstRunLocationText =>
      'Where you photograph a plant a Station is born: you can come back there to Draw. The app needs your precise location, only while you use it. Your Stations stay on your phone: they are never shown or shared.';

  @override
  String get firstRunLocationAllow => 'Turn on';

  @override
  String get firstRunLocationDenied =>
      'Without location Encounters count, but no Stations are born. You can turn it on at any time in Android settings, under App permissions.';

  @override
  String get firstRunLocationApproximate =>
      'With approximate location Stations are not precise. You can choose precise location in Android settings, under App permissions.';

  @override
  String get firstRunOpenSettings => 'Open settings';

  @override
  String get firstRunNext => 'Next';

  @override
  String get firstRunReadyTitle => 'You\'re ready to play';

  @override
  String get firstRunReadyText =>
      'The tutorial guides you through your first round, all from home: you photograph a kitchen herb, study it and brew your first potion.';

  @override
  String get firstRunStartTutorial => 'Play the tutorial';

  @override
  String get firstRunLater => 'Later';

  @override
  String get firstRunLaterNote =>
      'The tutorial stays on Home: play it whenever you like.';

  @override
  String firstRunProgress(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get rankCurious => 'Curious';

  @override
  String get nextRankCurious =>
      'Next Rank: Apprentice, at the end of the tutorial';

  @override
  String tutorialLabel(int step, int total) {
    return 'Tutorial · step $step of $total';
  }

  @override
  String get tutorialIntroTitle => 'The tutorial';

  @override
  String get tutorialIntroBody =>
      'A round of the game all from home, with kitchen herbs: sage, rosemary, bay or basil, even in a pot or from the supermarket. At the end you become an Apprentice.';

  @override
  String get tutorialStart => 'Start';

  @override
  String get tutorialSkip => 'Skip the tutorial';

  @override
  String get tutorialPhotographTitle => 'Photograph a herb';

  @override
  String get tutorialPhotographBody =>
      'Tap Draw in the middle of the bar and photograph sage, rosemary, bay or basil, even in a pot or from the supermarket. Pl@ntNet recognises it: you Meet it, its Station is born and you Draw its first Essence. Photograph, don\'t pick.';

  @override
  String get tutorialStudyTitle => 'Study your herb';

  @override
  String get tutorialStudyBody =>
      'Every plant is studied in Levels, with questions that teach even when you get them wrong. Pass Level 1 of the plant you photographed: you learn its Common Recipe. Meanwhile the Herbarium has lit up in the bar.';

  @override
  String get tutorialSecondPhotographTitle => 'Photograph another herb';

  @override
  String get tutorialSecondPhotographBody =>
      'The Common Recipe needs the plant and any other species: photograph another herb and Draw a second Essence.';

  @override
  String get tutorialBrewTitle => 'Brew your first potion';

  @override
  String get tutorialBrewBody =>
      'The Laboratory has lit up in the bar: open Ready recipes and brew the Common Recipe with your two Essences. Potions are fantasy.';

  @override
  String get tutorialTroveTitle => 'The Trove of Experience';

  @override
  String get tutorialTroveBody =>
      'With XP you buy Troves of Experience: inside are the Plates of other Recipes. The Trove has lit up in the bar: open it, there\'s a gift for you.';

  @override
  String get tutorialApprenticeTitle => 'You\'re an Apprentice';

  @override
  String get tutorialApprenticeBody =>
      'You did your first round: photograph, study, Draw, brew. Now go out: the plants of your Area are waiting in the Herbarium, under To find.';

  @override
  String get tutorialActionCapture => 'Draw';

  @override
  String get tutorialActionStudy => 'Study';

  @override
  String get tutorialActionLaboratory => 'Open the Laboratory';

  @override
  String get tutorialActionTrove => 'Open the Trove';

  @override
  String get tutorialActionFinish => 'Continue';

  @override
  String get erbarioKitchen => 'From the kitchen';

  @override
  String get kitchenHint =>
      'A kitchen herb: you\'ll find it in a pot, on the balcony or at the supermarket. Photograph it from home, even just a leaf.';

  @override
  String get sectionOrigin => 'Where it comes from';
}
