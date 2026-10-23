// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Druid';

  @override
  String get navErbario => 'Erbario';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get erbarioTitle => 'Erbario';

  @override
  String erbarioFound(int found, int total) {
    return '$found/$total trovate';
  }

  @override
  String get unknownSpecies => '???';

  @override
  String hintFamily(String family) {
    return 'Una pianta della famiglia $family';
  }

  @override
  String get hintSeasonWinter => 'che si fa notare soprattutto in inverno';

  @override
  String get hintSeasonSpring => 'che si fa notare soprattutto in primavera';

  @override
  String get hintSeasonSummer => 'che si fa notare soprattutto d\'estate';

  @override
  String get hintSeasonAutumn => 'che si fa notare soprattutto in autunno';

  @override
  String get hintBandPlain => 'in pianura';

  @override
  String get hintBandHill => 'in collina';

  @override
  String get hintBandMountain => 'in montagna';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get liveryLabel => 'Livrea';

  @override
  String get liveryErbario => 'Erbario';

  @override
  String get liveryNotturna => 'Notturna';

  @override
  String get themeModeLabel => 'Aspetto';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Chiaro';

  @override
  String get themeModeDark => 'Scuro';

  @override
  String get loadingError => 'Non è stato possibile caricare i dati';

  @override
  String get retry => 'Riprova';

  @override
  String get erbarioEncounteredSection => 'Incontrate';

  @override
  String get erbarioMissingSection => 'Da trovare nel bolognese';

  @override
  String get simulateEncounter => 'Simula incontro';

  @override
  String get levelToStudy => 'Da studiare';

  @override
  String get levelRecognise => 'Riconoscerla';

  @override
  String get levelKnow => 'Famiglia e vita';

  @override
  String get levelWhereWhen => 'Il suo ambiente';

  @override
  String get levelMastery => 'Maestria';

  @override
  String get navStudy => 'Home';

  @override
  String get navRecipes => 'Ricette';

  @override
  String get rankApprentice => 'Apprendista';

  @override
  String get rankWanderer => 'Viandante';

  @override
  String get rankSeeker => 'Cercatore';

  @override
  String get rankWarden => 'Custode';

  @override
  String get rankBotanomancer => 'Botanomante';

  @override
  String xpTotal(int xp) {
    return '$xp PE';
  }

  @override
  String nextRank(String rank, int xp) {
    return 'Prossimo titolo: $rank a $xp PE';
  }

  @override
  String get maxRankReached => 'Hai raggiunto il titolo più alto';

  @override
  String get seasonWinter => 'inverno';

  @override
  String get seasonSpring => 'primavera';

  @override
  String get seasonSummer => 'estate';

  @override
  String get seasonAutumn => 'autunno';

  @override
  String get bandPlain => 'Pianura (sotto i 150 m)';

  @override
  String get bandHill => 'Collina (150–600 m)';

  @override
  String get bandMountain => 'Montagna (oltre i 600 m)';

  @override
  String get qPhotoToName => 'Che pianta è questa?';

  @override
  String qNameToPhoto(String name) {
    return 'Quale di queste è $name?';
  }

  @override
  String qSciToCommon(String sci) {
    return 'Come si chiama comunemente $sci?';
  }

  @override
  String qCommonToSci(String name) {
    return 'Qual è il nome scientifico di: $name?';
  }

  @override
  String qFamilyFromCommon(String name) {
    return 'A quale famiglia appartiene: $name?';
  }

  @override
  String qFamilyFromSci(String sci) {
    return 'A quale famiglia appartiene $sci?';
  }

  @override
  String get qFamilyFromPhoto =>
      'A quale famiglia appartiene la pianta in foto?';

  @override
  String qRelativeOf(String name) {
    return 'Quale di queste piante è della stessa famiglia di: $name?';
  }

  @override
  String get qOddOneOut => 'Quale NON è della stessa famiglia delle altre?';

  @override
  String qBandOf(String name) {
    return 'Dove incontri più spesso $name, qui?';
  }

  @override
  String qWhichInBand(String band) {
    return 'Quale di queste piante trovi più facilmente $band?';
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
    return '$name appartiene alla famiglia $family.';
  }

  @override
  String factRelatives(String name, String relatives, String family) {
    return '$name è parente di: $relatives ($family).';
  }

  @override
  String factSeason(String name, String season, String months) {
    return '$name si fa notare soprattutto in $season. Mesi migliori: $months.';
  }

  @override
  String factAltitude(String name, String band, int meters) {
    return '$name si incontra soprattutto $band (quota mediana $meters m).';
  }

  @override
  String get answerRight => 'Giusto!';

  @override
  String get answerWrong => 'Non proprio.';

  @override
  String get answerWillReturn => 'Tornerà tra poco, in un\'altra forma.';

  @override
  String answerRemembered(int days) {
    return 'Te lo ricordavi! Prossimo ripasso tra $days giorni.';
  }

  @override
  String get answerForgotten => 'Dimenticato: tornerà nei ripassi di domani.';

  @override
  String xpGained(int xp) {
    return '+$xp PE';
  }

  @override
  String get next => 'Avanti';

  @override
  String get close => 'Chiudi';

  @override
  String studyLevelTitle(String name, int level) {
    return '$name · livello $level';
  }

  @override
  String get reviewTitle => 'Ripasso';

  @override
  String studyProgress(int done, int total) {
    return '$done di $total';
  }

  @override
  String get summaryTitle => 'Fine sessione';

  @override
  String summaryLevelPassed(int level, String name) {
    return 'Livello $level superato: $name entra nei ripassi da domani.';
  }

  @override
  String get summaryReviewDone => 'Ripassi completati.';

  @override
  String summaryAnswers(int correct, int answers) {
    return 'Risposte giuste: $correct su $answers';
  }

  @override
  String get summaryMastery => 'Maestria raggiunta!';

  @override
  String summaryRecipeUnlocked(String recipe) {
    return 'Ricetta sbloccata: $recipe';
  }

  @override
  String get summaryNewFunFacts =>
      'Nuove curiosità in arrivo: le riceverai una al giorno.';

  @override
  String get saveToNotebook => 'Salva nel taccuino';

  @override
  String get savedToNotebook => 'Nel taccuino';

  @override
  String get notebookLocked => 'Salva nel taccuino';

  @override
  String get diarioUpsell =>
      'Con il Diario dell\'Erborista salvi in un tocco ciò che impari e lo ritrovi quando ti serve, anche durante lo studio. Senza Diario puoi fare lo stesso con un quaderno vero e con le note per specie, che restano gratuite.';

  @override
  String get notebookTitle => 'Taccuino';

  @override
  String get notebookSearch => 'Cerca: famiglia, mese, specie, note…';

  @override
  String get notebookEmpty =>
      'Ancora vuoto: durante lo studio usa \"Salva nel taccuino\".';

  @override
  String get notebookNoResults => 'Nessun risultato.';

  @override
  String get notesTitle => 'Le tue note';

  @override
  String get notesHint => 'Dove l\'hai vista, come riconoscerla…';

  @override
  String get notesSave => 'Salva nota';

  @override
  String get notesSaved => 'Nota salvata';

  @override
  String get funOfDayTitle => 'Curiosità del giorno';

  @override
  String funOfDayCount(int seen, int total) {
    return '$seen scoperte su $total';
  }

  @override
  String get funOfDayEmpty =>
      'Incontra e studia una specie per ricevere ogni giorno una curiosità su ciò che hai imparato.';

  @override
  String get funToVerify => 'da verificare';

  @override
  String funRank(String name, int rank) {
    return '$name è al $rank° posto tra le piante spontanee più osservate della zona.';
  }

  @override
  String funHigh(String name, int meters) {
    return '$name è tra le 5 specie della zona che vivono più in alto: metà delle osservazioni supera i $meters m.';
  }

  @override
  String funLow(String name, int meters) {
    return '$name è tra le 5 specie più di pianura della zona: quota mediana $meters m.';
  }

  @override
  String funPeak(String name, String month) {
    return '$name si fa notare soprattutto a $month.';
  }

  @override
  String get reviewsTitle => 'Ripassi';

  @override
  String reviewsDue(int count) {
    return '$count fatti da ripassare oggi';
  }

  @override
  String get reviewsNone =>
      'Niente da ripassare oggi. I fatti imparati tornano dopo 1, 3, 7 e 21 giorni.';

  @override
  String get reviewsStart => 'Ripassa';

  @override
  String get desiderataTitle => 'Desiderata';

  @override
  String desiderataCount(int count, int max) {
    return '$count su $max';
  }

  @override
  String get desiderataEmpty =>
      'Scegli fino a 3 specie da cercare: vedrai foto e indicazioni su dove e quando trovarle.';

  @override
  String get desiderataSuggestions => 'In stagione adesso';

  @override
  String get seasonalFirstHint =>
      'Tre specie facili da riconoscere, per cominciare subito: si studia anche da casa.';

  @override
  String get seasonalHint =>
      'Puoi studiarle subito o segnarle come desiderata da cercare.';

  @override
  String get seasonalStudy => 'Studia';

  @override
  String get yourSpeciesMet => 'incontrata';

  @override
  String get desiderataAdd => 'Aggiungi alle desiderata';

  @override
  String get desiderataRemove => 'Togli dalle desiderata';

  @override
  String get desiderataFull =>
      'Hai già 3 desiderata: completane o togline una.';

  @override
  String desiderataWhere(String band) {
    return 'Dove: $band';
  }

  @override
  String desiderataWhen(String months) {
    return 'Quando: $months';
  }

  @override
  String desiderataFamily(String family) {
    return 'Famiglia: $family';
  }

  @override
  String get yourSpecies => 'Le tue specie';

  @override
  String get yourSpeciesEmpty =>
      'Nessuna specie in studio: comincia da una di quelle in stagione.';

  @override
  String studyLevelButton(int level) {
    return 'Studia il livello $level';
  }

  @override
  String get studyComplete => 'Domande completate';

  @override
  String get levelsTitle => 'Livelli di studio';

  @override
  String lockedSection(int level, String name) {
    return 'Si rivela al livello $level ($name)';
  }

  @override
  String get sectionSci => 'Nome scientifico';

  @override
  String get sectionFamily => 'Famiglia';

  @override
  String get sectionRelatives => 'Parenti nella zona';

  @override
  String get sectionWhen => 'Quando si osserva';

  @override
  String sectionWhere(int meters) {
    return 'Dove (quota mediana $meters m)';
  }

  @override
  String get sectionLore => 'Lore';

  @override
  String sectionFunFacts(int seen, int total) {
    return 'Curiosità $seen/$total';
  }

  @override
  String sectionFunFactsHidden(int count) {
    return '$count ancora da scoprire';
  }

  @override
  String safetyWarning(String text) {
    return '⚠️ $text · da verificare';
  }

  @override
  String protectedNote(String sources) {
    return 'Specie protetta ($sources). Guardala e fotografala: non raccoglierla, non calpestarla, non alterare l\'ambiente e resta sul sentiero.';
  }

  @override
  String get masteryTitle => 'Maestria';

  @override
  String masteryFacts(int done, int total) {
    return 'Fatti consolidati (ricordati a 1 e 3 giorni): $done/$total';
  }

  @override
  String masteryDraws(int done, int total, int traits, int needed) {
    return 'Essenze attinte: $done/$total · tratti diversi: $traits/$needed';
  }

  @override
  String get masteryOnlyField =>
      'Con il solo studio non si arriva alla maestria: servono anche le essenze attinte sul campo.';

  @override
  String get masteryReached => 'Maestria raggiunta';

  @override
  String get simulateDraw => 'Simula attingere';

  @override
  String get noTrait => 'Nessun tratto';

  @override
  String get traitFrost => '❄️ Gelo';

  @override
  String get traitRain => '🌧 Pioggia';

  @override
  String get traitFog => '🌫 Nebbia';

  @override
  String get traitSun => '☀️ Solare';

  @override
  String get traitMoon => '🌕 Lunare';

  @override
  String get traitDew => '💧 Rugiada';

  @override
  String get traitDusk => '🌅 Crepuscolo';

  @override
  String get recipesTitle => 'Ricette';

  @override
  String get recipeUnlocked => 'Sbloccata';

  @override
  String get recipeLocked => 'Bloccata';

  @override
  String recipeKnownIngredients(int known, int total) {
    return 'Ingredienti noti $known/$total';
  }

  @override
  String get recipeUnknownIngredient => '???';

  @override
  String recipeHint(String hint) {
    return 'Indizio: $hint';
  }

  @override
  String get recipeAnySpecies => 'qualsiasi specie';

  @override
  String recipeCurrentLevel(int level) {
    return 'ora: livello $level';
  }

  @override
  String erbarioPages(int done, int total) {
    return 'Pagine compilate $done/$total';
  }

  @override
  String missionLabel(int index, int total) {
    return 'Missione $index di $total';
  }

  @override
  String get missionVisitErbarioTitle => 'Apri l\'erbario';

  @override
  String get missionVisitErbarioBody =>
      'L\'erbario raccoglie le specie della zona, ognuna con foto e nome. Il resto si scopre studiandole e incontrandole.';

  @override
  String get missionMarkDesiderataTitle => 'Scegli le tue desiderata';

  @override
  String get missionMarkDesiderataBody =>
      'Scegli fino a 3 specie da cercare: per ognuna vedrai foto, periodo e quota. Comincia da una in stagione adesso.';

  @override
  String get missionFirstEncounterTitle => 'Incontra una specie';

  @override
  String get missionFirstEncounterBody =>
      'Esci a erborizzare e fotografa una delle tue desiderata: una volta riconosciuta comparirà nell\'erbario. Fotografa, non raccogliere.';

  @override
  String get missionFirstLevelTitle => 'Studia la tua prima specie';

  @override
  String get missionFirstLevelBody =>
      'Scegli una specie in stagione e supera il primo livello di studio: si comincia anche da casa. Anche gli errori insegnano e danno punti esperienza.';

  @override
  String get missionFirstRecipeTitle => 'La prima ricetta';

  @override
  String get missionFirstRecipeBody =>
      'Porta una specie al livello richiesto da una ricetta per sbloccarla. Le ricette chiedono specie e condizioni diverse: un motivo per uscire di nuovo.';

  @override
  String get missionSkip => 'Salta l\'apprendistato';

  @override
  String get missionActionOpenErbario => 'Apri l\'erbario';

  @override
  String get missionActionChooseDesiderata => 'Scegli nell\'erbario';

  @override
  String get missionActionStudy => 'Inizia a studiare';

  @override
  String get missionActionRecipes => 'Vedi le ricette';

  @override
  String get missionGlossary => 'Glossario';

  @override
  String get apprenticeshipComplete => 'Apprendistato completato!';

  @override
  String get glossaryTitle => 'Glossario';

  @override
  String get glossErbarioTerm => 'Erbario';

  @override
  String get glossErbarioText =>
      'Collezione di piante, un tempo essiccate e annotate su fogli con data e luogo di raccolta. Qui si compila con le specie che incontri e studi.';

  @override
  String get glossDesiderataTerm => 'Desiderata';

  @override
  String get glossDesiderataText =>
      'Negli erbari e tra i collezionisti, l\'elenco degli esemplari che si desidera trovare. Qui sono le specie (al massimo 3) che hai scelto di cercare.';

  @override
  String get glossErborizzareTerm => 'Erborizzare';

  @override
  String get glossErborizzareText =>
      'Andare per campi e boschi a osservare e studiare le piante: è il verbo storico dei botanici in escursione.';

  @override
  String get glossStazioneTerm => 'Stazione';

  @override
  String get glossStazioneText =>
      'In botanica, il luogo preciso in cui cresce una popolazione di una specie, con le sue condizioni di suolo, esposizione e quota. Qui è il punto in cui hai incontrato una specie e dove potrai tornare ad attingere.';

  @override
  String get glossTrattoTerm => 'Tratto';

  @override
  String get glossTrattoText =>
      'La condizione del momento in cui attingi un\'essenza (luna piena, pioggia, nebbia, rugiada…). Le ricette chiedono tratti diversi: la stessa pianta in giorni diversi dà essenze diverse.';

  @override
  String get glossAttingereTerm => 'Attingere';

  @override
  String get glossAttingereText =>
      'Trarre l\'essenza da una stazione senza toccare la pianta: si fotografa e si osserva, non si raccoglie.';

  @override
  String get glossMaestriaTerm => 'Maestria';

  @override
  String get glossMaestriaText =>
      'L\'ultimo livello di una specie: richiede di ricordare ciò che hai imparato a distanza di giorni e di aver attinto la specie sul campo in condizioni diverse.';

  @override
  String get glossMissioneTerm => 'Missione';

  @override
  String get glossMissioneText =>
      'Un obiettivo da raggiungere nel mondo reale o nello studio: incontrare una specie, superare un livello, sbloccare una ricetta.';

  @override
  String get debugTitle => 'Strumenti di prova';

  @override
  String debugDays(int days) {
    return 'Giorno simulato: +$days';
  }

  @override
  String debugAdvance(int days) {
    return '+$days g';
  }

  @override
  String get debugDiario => 'Diario dell\'Erborista (abbonamento simulato)';

  @override
  String get debugReset => 'Azzera i progressi';

  @override
  String get debugResetConfirm => 'Tocca di nuovo per cancellare tutto';

  @override
  String get debugResetDone => 'Progressi azzerati';

  @override
  String get notEncounteredYet => 'Non ancora incontrata';

  @override
  String get desiderataAddShort => 'Aggiungi';

  @override
  String get simulateShort => 'Simula';

  @override
  String get liverySottobosco => 'Sottobosco';

  @override
  String get dayTimeDawn => 'all\'alba';

  @override
  String get dayTimeDay => 'di giorno';

  @override
  String get dayTimeDusk => 'al tramonto';

  @override
  String get dayTimeNight => 'di notte';

  @override
  String get liveryFeltro => 'Feltro';

  @override
  String studyThemeProgress(String theme, int done, int total) {
    return '$theme · $done di $total';
  }

  @override
  String qOrderOf(String name) {
    return 'A quale ordine appartiene $name?';
  }

  @override
  String qCommonnessOf(String name) {
    return 'Quanto è comune $name in questa zona?';
  }

  @override
  String get optionYes => 'Sì';

  @override
  String get optionNo => 'No';

  @override
  String get commonnessVeryCommon => 'Tra le più comuni';

  @override
  String get commonnessCommon => 'Comune';

  @override
  String get commonnessUncommon => 'Meno comune';

  @override
  String get commonnessRare => 'Tra le meno osservate';

  @override
  String factScientificName(String name, String sci) {
    return 'Il nome scientifico di $name è $sci: la prima parola è il genere, la seconda la specie.';
  }

  @override
  String factCongeners(String genus, String names) {
    return 'Altre specie del genere $genus in Italia: $names.';
  }

  @override
  String factOrder(String name, String order, String family) {
    return '$name appartiene all\'ordine $order, di cui fa parte la famiglia $family.';
  }

  @override
  String factWarning(String name, String warning) {
    return '$name: $warning. Guardala e fotografala, non assaggiarla. Avviso da verificare.';
  }

  @override
  String factCommonness(String name, String commonness) {
    return 'In questa zona $name è: $commonness (dalle osservazioni GBIF).';
  }

  @override
  String qGrowthFormOf(String name) {
    return 'Che forma ha $name?';
  }

  @override
  String qLifeCycleOf(String name) {
    return 'Quanto vive $name?';
  }

  @override
  String qSeedDispersalOf(String name) {
    return 'Come viaggiano i semi di $name?';
  }

  @override
  String qOriginOf(String name) {
    return '$name è arrivata in Italia da fuori, portata dall\'uomo?';
  }

  @override
  String qLightOf(String name) {
    return 'Quanta luce ama $name?';
  }

  @override
  String qMoistureOf(String name) {
    return 'Che terreno preferisce $name?';
  }

  @override
  String get growthTree => 'Albero';

  @override
  String get growthShrub => 'Arbusto';

  @override
  String get growthHerb => 'Erba';

  @override
  String get growthClimber => 'Rampicante';

  @override
  String get cycleAnnual => 'Un anno (annuale)';

  @override
  String get cycleBiennial => 'Due anni (biennale)';

  @override
  String get cyclePerennial => 'Molti anni (perenne)';

  @override
  String get seedsEatenByAnimals => 'Nei frutti mangiati dagli animali';

  @override
  String get seedsStuckToAnimals => 'Attaccati al pelo degli animali';

  @override
  String get seedsHoardedByAnimals => 'Nascosti dagli animali come scorte';

  @override
  String get seedsAnts => 'Portati dalle formiche';

  @override
  String get seedsWind => 'Col vento';

  @override
  String get seedsWater => 'Con l\'acqua';

  @override
  String get seedsLaunched => 'Lanciati dalla pianta';

  @override
  String get seedsNearby => 'Cadono vicino, senza aiuti';

  @override
  String get lightShade => 'Ombra';

  @override
  String get lightHalfShade => 'Mezz\'ombra';

  @override
  String get lightSun => 'Pieno sole';

  @override
  String get moistureDry => 'Secco';

  @override
  String get moistureFresh => 'Fresco';

  @override
  String get moistureMoist => 'Umido';

  @override
  String factGrowthForm(String name, String form) {
    return 'Forma di $name: $form.';
  }

  @override
  String factLifeCycle(String name, String cycle) {
    return '$name vive $cycle.';
  }

  @override
  String factSeedDispersal(String name, String modes) {
    return 'I semi di $name: $modes.';
  }

  @override
  String factOriginNative(String name) {
    return '$name è autoctona: in Italia cresce da sempre, senza l\'aiuto dell\'uomo.';
  }

  @override
  String factOriginIntroduced(String name) {
    return '$name è stata portata in Italia dall\'uomo: non è nata qui.';
  }

  @override
  String factLight(String name, String light) {
    return '$name ama: $light.';
  }

  @override
  String factMoisture(String name, String moisture) {
    return '$name preferisce un terreno $moisture.';
  }

  @override
  String get sourcesTraits => 'Tratti: WCVP (Kew), EIVE 1.0, EuDiS, CC BY 4.0';

  @override
  String get sectionTraits => 'Com\'è e come vive';

  @override
  String xpToCash(int xp) {
    return '$xp PE da incassare: si incassano alla prima essenza di ogni specie';
  }

  @override
  String speciesXpToCash(int xp) {
    return '$xp PE da incassare: attingi la prima essenza di questa specie.';
  }

  @override
  String get summaryXpToCash =>
      'I PE dello studio di questa specie si incassano quando ne attingi la prima essenza.';

  @override
  String visStored(int vis) {
    return 'Vis immagazzinate: $vis';
  }

  @override
  String get drawExhausted => 'Esaurita: torna pronta domani';

  @override
  String get drawNeedsEncounter =>
      'Per attingere serve una stazione: prima incontrala';

  @override
  String get gradeCommon => 'Comune';

  @override
  String get gradeUncommon => 'Non comune';

  @override
  String get gradeRare => 'Rara';

  @override
  String get gradeMythic => 'Mitica';

  @override
  String get protectionEmiliaRomagna => 'L.R. Emilia-Romagna 2/1977';

  @override
  String protectionHabitats(String annex) {
    return 'Direttiva Habitat, allegato $annex';
  }
}
