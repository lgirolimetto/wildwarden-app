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
  String get simulateEncounter => 'Simula Incontro';

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
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Prossimo Rango: $rank a $xpString PE';
  }

  @override
  String get maxRankReached => 'Hai raggiunto il Rango più alto';

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
    return 'Te lo ricordavi! Prossimo Ripasso tra $days giorni.';
  }

  @override
  String get answerForgotten => 'Dimenticato: tornerà nei Ripassi di domani.';

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
    return '$name · Livello $level';
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
    return 'Livello $level superato: $name entra nei Ripassi da domani.';
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
  String get summaryNewFunFacts =>
      'Nuove Curiosità in arrivo: le riceverai una al giorno.';

  @override
  String get saveToNotebook => 'Salva nel Taccuino';

  @override
  String get savedToNotebook => 'Nel Taccuino';

  @override
  String get notebookLocked => 'Salva nel Taccuino';

  @override
  String get diarioUpsell =>
      'Con il Diario dell\'Erborista salvi in un tocco ciò che impari e lo ritrovi quando ti serve, anche durante lo studio. Senza Diario puoi fare lo stesso con un quaderno vero e con le note per specie, che restano gratuite.';

  @override
  String get notebookTitle => 'Taccuino';

  @override
  String get notebookSearch => 'Cerca: famiglia, mese, specie, note…';

  @override
  String get notebookEmpty =>
      'Ancora vuoto: durante lo studio usa \"Salva nel Taccuino\".';

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
      'Incontra e studia una specie per ricevere ogni giorno una Curiosità su ciò che hai imparato.';

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
    return '$count Fatti da ripassare oggi';
  }

  @override
  String get reviewsNone =>
      'Niente da ripassare oggi. I Fatti imparati tornano dopo 1, 3, 7, 21, 60 e 180 giorni.';

  @override
  String get reviewsStart => 'Ripassa';

  @override
  String get desiderataTitle => 'Desiderata';

  @override
  String get desiderataEmpty =>
      'Scegli le specie da cercare: vedrai foto e indicazioni su dove e quando trovarle.';

  @override
  String get desiderataSuggestions => 'In stagione adesso';

  @override
  String get seasonalFirstHint =>
      'Tre specie facili da riconoscere, per cominciare subito: si studia anche da casa.';

  @override
  String get seasonalHint =>
      'Puoi studiarle subito o segnarle come Desiderata da cercare.';

  @override
  String get seasonalStudy => 'Studia';

  @override
  String get yourSpeciesMet => 'Incontrata';

  @override
  String get desiderataAdd => 'Aggiungi alle Desiderata';

  @override
  String get desiderataRemove => 'Togli dalle Desiderata';

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
    return 'Studia il Livello $level';
  }

  @override
  String get studyButton => 'Studia';

  @override
  String get studyComplete => 'Domande completate';

  @override
  String get levelsTitle => 'Livelli di studio';

  @override
  String lockedSection(int level, String name) {
    return 'Si rivela al Livello $level ($name)';
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
    return '$text · da verificare';
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
    return 'Essenze Attinte: $done/$total · Qualia diverse: $traits/$needed';
  }

  @override
  String get masteryOnlyField =>
      'Con il solo studio non si arriva alla Maestria: servono anche le Essenze Attinte sul campo.';

  @override
  String get masteryReached => 'Maestria raggiunta';

  @override
  String get simulateDraw => 'Simula Attingere';

  @override
  String get noTrait => 'Nessuna Qualia';

  @override
  String get traitFrost => '❄️ Gelo';

  @override
  String get traitRain => '🌧 Pioggia';

  @override
  String get traitFog => '🌫 Nebbia';

  @override
  String get traitSun => '☀️ Sole';

  @override
  String get traitMoon => '🌕 Luna piena';

  @override
  String get traitDew => '💧 Rugiada';

  @override
  String get traitDusk => '🌅 Tramonto';

  @override
  String get recipesTitle => 'Ricette';

  @override
  String get recipeAnySpecies => 'qualsiasi specie';

  @override
  String erbarioPages(int done, int total) {
    return 'Pagine compilate $done/$total';
  }

  @override
  String get apprenticeshipComplete => 'Apprendistato completato!';

  @override
  String get glossaryTitle => 'Legenda e glossario';

  @override
  String get glossErbarioTerm => 'Erbario';

  @override
  String get glossErbarioText =>
      'Collezione di piante, un tempo essiccate e annotate su fogli con data e luogo di raccolta. Qui si compila con le specie che Incontri e studi.';

  @override
  String get glossDesiderataTerm => 'Desiderata';

  @override
  String get glossDesiderataText =>
      'Negli erbari e tra i collezionisti, l\'elenco degli esemplari che si desidera trovare. Qui sono le specie che hai scelto di cercare, quante vuoi.';

  @override
  String get glossErborizzareTerm => 'Erborizzare';

  @override
  String get glossErborizzareText =>
      'Andare per campi e boschi a osservare e studiare le piante: è il verbo storico dei botanici in escursione.';

  @override
  String get glossStazioneTerm => 'Stazione';

  @override
  String get glossStazioneText =>
      'In botanica, il luogo preciso in cui cresce una popolazione di una specie, con le sue condizioni di suolo, esposizione e quota. Qui è il punto in cui hai Incontrato una specie e dove potrai tornare ad Attingere.';

  @override
  String get glossTrattoTerm => 'Qualia';

  @override
  String get glossTrattoText =>
      'Una condizione del momento in cui Attingi un\'Essenza (Sole, Luna piena, Pioggia, Nebbia, Rugiada…): un\'Essenza le porta tutte. Le Ricette chiedono Qualia diverse: la stessa pianta in giorni diversi dà Essenze diverse. Si dice «una Qualia», «le Qualia», come la Vis.';

  @override
  String get glossAttingereTerm => 'Attingere';

  @override
  String get glossAttingereText =>
      'Trarre l\'Essenza da una Stazione senza toccare la pianta: si fotografa e si osserva, non si raccoglie.';

  @override
  String get glossMaestriaTerm => 'Maestria';

  @override
  String get glossMaestriaText =>
      'L\'ultimo Livello di una specie: richiede di ricordare ciò che hai imparato a distanza di giorni e di aver Attinto la specie sul campo in condizioni diverse. Va mantenuta: dopo 30 giorni senza domande della specie si assopisce e si risveglia con un mini-quiz.';

  @override
  String get glossMissioneTerm => 'Missione';

  @override
  String get glossMissioneText =>
      'Un obiettivo da raggiungere nel mondo reale o nello studio: Incontrare una specie, superare un Livello, sbloccare una Ricetta.';

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
  String get notEncounteredYet => 'Non ancora Incontrata';

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
  String get sectionTraits => 'Com\'è e come vive';

  @override
  String xpToCash(int xp) {
    return '$xp PE da Incassare: si Incassano alla prima Essenza di ogni specie';
  }

  @override
  String speciesXpToCash(int xp) {
    return '$xp PE da Incassare: Attingi la prima Essenza di questa specie.';
  }

  @override
  String get summaryXpToCash =>
      'I PE dello studio di questa specie si Incassano quando ne Attingi la prima Essenza.';

  @override
  String visStored(int vis) {
    return 'Vis immagazzinate: $vis';
  }

  @override
  String get drawExhausted => 'Esaurita: torna pronta domani';

  @override
  String get drawNeedsEncounter =>
      'Per Attingere serve una Stazione: prima Incontrala';

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

  @override
  String summaryRecipeLearned(String name) {
    return 'Hai imparato una Ricetta: $name';
  }

  @override
  String get debugGradePreview => 'Anteprima dei Gradi';

  @override
  String get debugGradeSampleName => 'Elisir di Prova';

  @override
  String get debugGradeSampleIngredient => 'Erba d\'argento';

  @override
  String get debugGradeSampleEffect =>
      'La prossima volta che attingi con la Luna piena ha una Qualia in più (effetto di gioco).';

  @override
  String get badgeEncountered => 'Incontrata il';

  @override
  String get badgeProtected => 'Specie Protetta';

  @override
  String get legendTitle => 'Legenda';

  @override
  String get glossarySection => 'Glossario';

  @override
  String get legendGrades => 'Gradi (Ricette, Pozioni, Bottino)';

  @override
  String get legendBadges => 'Bollini';

  @override
  String get legendProtected =>
      'Specie Protetta dalla legge: si guarda e si fotografa';

  @override
  String get legendEncountered =>
      'Specie Incontrata, con la data dell\'Incontro';

  @override
  String get legendXpToCash =>
      'PE da Incassare alla prima Essenza della specie';

  @override
  String get legendLevels => 'Livelli di studio';

  @override
  String get legendTraits => 'Qualia delle Essenze';

  @override
  String get glossProtettaTerm => 'Protetta';

  @override
  String get glossProtettaText =>
      'Specie protetta dalla Direttiva Habitat o da una legge regionale. Si guarda e si fotografa: non si raccoglie, non si calpesta, si resta sul sentiero.';

  @override
  String get glossEssenzaTerm => 'Essenza';

  @override
  String get glossEssenzaText =>
      'Ciò che Attingi da una Stazione: ha le sue Vis, una Purezza, che cresce con la conoscenza della specie, e delle Qualia, date dalle condizioni del momento.';

  @override
  String get glossVisTerm => 'Vis';

  @override
  String get glossVisText =>
      'La linfa sottile delle piante: l\'energia che immagazzini ogni volta che attingi. Le Ricette ne chiedono una quantità per Ingrediente.';

  @override
  String get glossPeDaIncassareTerm => 'PE da Incassare';

  @override
  String get glossPeDaIncassareText =>
      'I Punti Esperienza dello studio di una specie che non hai ancora Attinto. Si Incassano alla prima Essenza di quella specie e da lì contano per il Rango.';

  @override
  String get glossGradoTerm => 'Grado';

  @override
  String get glossGradoText =>
      'Comune, Non comune, Rara, Mitica: bianco, argento, oro, oro rosso. Vale per Ingredienti, Ricette, Pozioni e Bottino dell\'Esperienza.';

  @override
  String get glossBottinoTerm => 'Bottino dell\'Esperienza';

  @override
  String get glossBottinoText =>
      'Il Bottino che si compra con i PE: scegli il grado e spendi il saldo; dentro c\'è una Tavola a sorpresa, spesso incompleta, o un componente di una che hai. Le Mitiche escono solo dal Bottino mitico.';

  @override
  String get recipesEmpty =>
      'Non conosci ancora nessuna Ricetta. Ogni pianta ha la sua Ricetta Comune: la impari superando il Livello 1 della specie, dalla Home o dall\'Erbario.';

  @override
  String get viewAll => 'Tutte';

  @override
  String get viewInSeason => 'In stagione adesso';

  @override
  String get viewDesiderata => 'Le mie Desiderata';

  @override
  String get viewProtected => 'Protette';

  @override
  String get viewNew => 'Nuova vista';

  @override
  String get viewName => 'Nome della vista';

  @override
  String get viewStatus => 'Stato';

  @override
  String get viewWhen => 'Quando e come';

  @override
  String get viewProtectedOnly => 'Solo Protette';

  @override
  String get viewBand => 'Quota';

  @override
  String get viewForm => 'Forma';

  @override
  String get viewFamily => 'Famiglia';

  @override
  String get viewSave => 'Salva la vista';

  @override
  String get viewRemove => 'Elimina la vista';

  @override
  String get viewEmpty => 'Nessuna specie in questa vista.';

  @override
  String get statusMet => 'Incontrate';

  @override
  String get statusToFind => 'Da trovare';

  @override
  String get statusDesiderata => 'Desiderata';

  @override
  String get statusStudying => 'In studio';

  @override
  String get traitDawn => '🌄 Alba';

  @override
  String get traitNewMoon => '🌑 Luna nuova';

  @override
  String get traitWaxingMoon => '🌓 Luna crescente';

  @override
  String get traitWaningMoon => '🌗 Luna calante';

  @override
  String get legendTraitsDaylight => 'Luce del giorno';

  @override
  String get legendTraitsMoon => 'Luna';

  @override
  String get legendTraitsWeather => 'Meteo';

  @override
  String get traitWhenFrost => 'Quando fa sotto zero: brina e ghiaccio.';

  @override
  String get traitWhenRain => 'Mentre piove. Con il temporale non si attinge.';

  @override
  String get traitWhenFog => 'Quando c\'è nebbia.';

  @override
  String get traitWhenSun => 'Con il sole e poche nuvole.';

  @override
  String get traitWhenMoon =>
      'Tutto il giorno della luna piena: non serve uscire di notte.';

  @override
  String get traitWhenDew =>
      'Dall\'alba a circa due ore dopo, se la notte è stata fresca e serena: l\'erba è ancora bagnata.';

  @override
  String get traitWhenDusk =>
      'Da circa un\'ora prima del tramonto fino al tramonto, mai a buio fatto.';

  @override
  String get traitWhenDawn =>
      'Dalle prime luci a circa un\'ora dopo il sorgere del sole.';

  @override
  String get traitWhenNewMoon =>
      'Tutto il giorno della luna nuova: non serve uscire di notte.';

  @override
  String get traitWhenWaxingMoon =>
      'Tutti i giorni in cui la luna cresce, tra la nuova e la piena: non serve uscire di notte.';

  @override
  String get traitWhenWaningMoon =>
      'Tutti i giorni in cui la luna cala, tra la piena e la nuova: non serve uscire di notte.';

  @override
  String get recipeBookTitle => 'Ricettario';

  @override
  String recipeBookPlates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tavole',
      one: '1 Tavola',
    );
    return '$_temp0';
  }

  @override
  String recipeBookPagesSummary(int pages, int total, int complete) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages Pagine',
      one: '1 Pagina',
    );
    String _temp1 = intl.Intl.pluralLogic(
      complete,
      locale: localeName,
      other: '$complete complete',
      one: '1 completa',
    );
    return '$_temp0 su $total · $_temp1';
  }

  @override
  String recipeBookPageCount(int known, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      known,
      locale: localeName,
      other: '$known Tavole',
      one: '1 Tavola',
    );
    return '$_temp0 su $total';
  }

  @override
  String get recipeBookFavouredTraits => 'Affinità';

  @override
  String get recipeBookVocation => 'Vocazione';

  @override
  String get recipeBookMissingPlate => 'Tavola da trovare';

  @override
  String get recipeBookSwipeHint => 'Scorri per sfogliare le Pagine';

  @override
  String recipeBookSpeciesLink(int known, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      known,
      locale: localeName,
      other: '$known Tavole',
      one: '1 Tavola',
    );
    return 'Ricettario · $_temp0 su $total';
  }

  @override
  String get recipeEffect => 'Effetto';

  @override
  String get effectRegrowth => 'Ricrescita';

  @override
  String get effectClarity => 'Limpidezza';

  @override
  String get effectOmen => 'Presagio';

  @override
  String get effectAbundance => 'Abbondanza';

  @override
  String get effectRegrowthText =>
      'Per 7 giorni le specie tornano pronte prima, fino a 12 ore dopo (effetto di gioco).';

  @override
  String get effectClarityText =>
      'Per 7 giorni purezza in più a ogni Essenza (effetto di gioco).';

  @override
  String get effectOmenText =>
      'Per 7 giorni un\'Essenza può prendere un\'Affinità della pianta che non ha; se le ha già tutte, purezza in più (effetto di gioco).';

  @override
  String get effectAbundanceText =>
      'Per 7 giorni Vis in più a ogni Essenza, fino a +50 % (effetto di gioco).';

  @override
  String mythicNumber(String number) {
    return 'Tavola n. $number';
  }

  @override
  String get mythicToFind => 'Da trovare';

  @override
  String mythicWindow(String from, String to) {
    return 'Solo dal $from al $to';
  }

  @override
  String get mythicAllYear => 'Tutto l\'anno';

  @override
  String get mythicsIntro =>
      'Le Mitiche della Zona: scritte a mano, legate ai suoi luoghi e alle sue feste. Si trovano solo nel Bottino dell\'Esperienza mitico.';

  @override
  String recipeBookMythicsRow(String zone) {
    return 'Mitiche · $zone';
  }

  @override
  String get debugSimulateRecipeBook => 'Simula un Ricettario';

  @override
  String debugSimulateRecipeBookDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tavole aggiunte',
      one: '1 Tavola aggiunta',
    );
    return '$_temp0 al Ricettario';
  }

  @override
  String get troveTitle => 'Bottino dell\'Esperienza';

  @override
  String get navTrove => 'Bottino';

  @override
  String get labBalance => 'Saldo';

  @override
  String labBalanceXp(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '$xpString PE da spendere';
  }

  @override
  String labTrovesLeft(int left, int total) {
    return '$left su $total oggi';
  }

  @override
  String troveName(String grade) {
    return 'Bottino dell\'Esperienza · $grade';
  }

  @override
  String get troveGradeCommon => 'comune';

  @override
  String get troveGradeUncommon => 'non comune';

  @override
  String get troveGradeRare => 'raro';

  @override
  String get troveGradeMythic => 'mitico';

  @override
  String get troveContentsCommon =>
      'Quasi sempre una Comune, a volte una Non comune';

  @override
  String get troveContentsUncommon =>
      'Per lo più Non comuni, a volte una Comune o una Rara';

  @override
  String get troveContentsRare => 'Per lo più Rare, a volte una Non comune';

  @override
  String get troveContentsMythic => 'Una Rara o una Mitica, metà e metà';

  @override
  String troveSpend(int cost) {
    final intl.NumberFormat costNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String costString = costNumberFormat.format(cost);

    return 'Spendi $costString PE';
  }

  @override
  String troveNeedXp(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Ti mancano $xpString PE';
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

    return 'Costa $costString PE: te ne mancano $xpString';
  }

  @override
  String troveDailyLimit(int total) {
    return 'Per oggi basta: $total Bottino dell\'Esperienza al giorno. Torna domani.';
  }

  @override
  String get troveRules =>
      'Le Tavole Non comuni, Rare e Mitiche escono incomplete: i componenti che mancano si trovano in altri Bottino dell\'Esperienza. Al primo comune e al primo non comune, in regalo una Tavola del grado sopra. Le Mitiche escono solo dal Bottino dell\'Esperienza mitico.';

  @override
  String labIncomplete(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tavole incomplete',
      one: '1 Tavola incompleta',
    );
    return '$_temp0';
  }

  @override
  String labRecycled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count riciclati',
      one: '1 riciclato',
    );
    return '$_temp0';
  }

  @override
  String get welcomeGiftTitle => 'Ehi, c\'è un regalo per te';

  @override
  String welcomeGiftBody(int full, int price) {
    final intl.NumberFormat fullNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String fullString = fullNumberFormat.format(full);
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    return 'Il tuo primo Bottino dell\'Esperienza · raro a prezzo di favore: $priceString PE invece di $fullString.';
  }

  @override
  String get welcomeGiftWaiting =>
      'Si riscatta dopo un\'Essenza: esci e Attingi da una Stazione.';

  @override
  String welcomeGiftRedeem(int price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    return 'Riscatta · $priceString PE';
  }

  @override
  String get troveTapToTurn => 'Tocca le Tavole per girarle';

  @override
  String get troveFindNew => 'Nuova Tavola';

  @override
  String get troveFindPiece => 'Un componente trovato';

  @override
  String get troveFindCompleted => 'Tavola completata';

  @override
  String troveFindRecycled(String grade) {
    return 'Doppione: 1 riciclato $grade';
  }

  @override
  String get troveFindTaste => 'Assaggio del grado sopra';

  @override
  String get troveNothing => 'Questa volta non è uscito niente di nuovo.';

  @override
  String get troveDone => 'Fatto';

  @override
  String recipeMissingPieces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Non si conoscono ancora $count Componenti',
      one: 'Non si conosce ancora 1 Componente',
    );
    return '$_temp0';
  }

  @override
  String get recipeEffectUnknown =>
      'Da scoprire: manca un componente del nome.';

  @override
  String get debugGrantXp => 'Aggiungi 5.000 PE';

  @override
  String get recycleTitle => 'Riciclo';

  @override
  String get recycleIntro =>
      'Ogni doppione è un riciclato del suo grado. 3 riciclati fanno un componente dello stesso grado, 9 uno del grado sopra, per una Tavola incompleta a tua scelta. Costa un po\' di Vis.';

  @override
  String recycleVis(int vis) {
    return '$vis Vis da spendere';
  }

  @override
  String recycleUse(int count, String grade, int vis) {
    return '$count riciclati $grade · $vis Vis';
  }

  @override
  String recycleNeedVis(int vis) {
    return 'Servono $vis Vis';
  }

  @override
  String get recycleNothing =>
      'Con i riciclati che hai non completi ancora nessun componente.';

  @override
  String recycleDone(String name) {
    return 'Componente aggiunto: $name';
  }

  @override
  String recycleCompleted(String name) {
    return 'Tavola completata: $name';
  }

  @override
  String get recycledGradeCommon => 'comuni';

  @override
  String get recycledGradeUncommon => 'non comuni';

  @override
  String get recycledGradeRare => 'rari';

  @override
  String get recycledGradeMythic => 'mitici';

  @override
  String get labTitle => 'Laboratorio';

  @override
  String get navLaboratory => 'Laboratorio';

  @override
  String get pantryTitle => 'Dispensa';

  @override
  String pantryEssences(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Essenze',
      one: '1 Essenza',
    );
    return '$_temp0';
  }

  @override
  String pantrySpeciesSummary(int count, int vis) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Essenze',
      one: '1 Essenza',
    );
    return '$_temp0 · $vis Vis';
  }

  @override
  String pantryPurity(int percent) {
    return 'Purezza $percent %';
  }

  @override
  String pantryVis(int vis) {
    return '$vis Vis';
  }

  @override
  String get pantryEmpty =>
      'La Dispensa è vuota: le Essenze che Attingi dalle Stazioni restano qui, con le loro Vis, la purezza e le Qualia. Per ora si Attinge con \"Simula Attingere\" nella scheda della specie.';

  @override
  String get debugSimulatePantry => 'Simula una Dispensa';

  @override
  String debugSimulatePantryDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Essenze aggiunte',
      one: '1 Essenza aggiunta',
    );
    return '$_temp0 alla Dispensa';
  }

  @override
  String get labTabShelf => 'Scaffale';

  @override
  String shelfCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pozioni',
      one: '1 pozione',
    );
    return '$_temp0';
  }

  @override
  String get readyAnyPlant => 'una pianta a scelta';

  @override
  String get brewButton => 'Prepara';

  @override
  String get brewChooseFree => 'Scegli la pianta dello slot libero';

  @override
  String get brewChooseFreeHint => 'Dà alla pozione il suo Tocco.';

  @override
  String brewFreeOption(int vis) {
    return '$vis Vis';
  }

  @override
  String get recipeReady => 'Preparabile';

  @override
  String get recipeBookOnlyReady => 'Mostra solo preparabili';

  @override
  String get recipeBookNoneReady =>
      'Nessuna Tavola preparabile adesso. Apri una Tavola per vedere quali Essenze ti mancano.';

  @override
  String brewTouchEffect(String effect, int strength, String relation) {
    return '$effect, forza $strength: $relation';
  }

  @override
  String get brewTouchStrengthens => 'rafforza l\'effetto della pozione';

  @override
  String get brewTouchAdds => 'un piccolo effetto in più';

  @override
  String get brewNoTouch => 'Nessun Tocco';

  @override
  String get brewConfirmTitle => 'Prepari questa pozione?';

  @override
  String get brewConfirmSpends => 'Spendi';

  @override
  String get brewCancel => 'Annulla';

  @override
  String get brewConfirm => 'Conferma';

  @override
  String get glossPreparabileTerm => 'Preparabile';

  @override
  String get glossPreparabileText =>
      'Una Tavola che puoi preparare adesso con le Vis della Dispensa: nel Ricettario ha l\'icona \"pronta\" e si trova con il filtro \"Mostra solo preparabili\".';

  @override
  String get potionTitle => 'Pozione';

  @override
  String potionPotency(int potency) {
    return 'Potenza $potency';
  }

  @override
  String potionTouch(String touch) {
    return 'Tocco: $touch';
  }

  @override
  String potionFirstBonus(int xp) {
    return 'Prima pozione di questa ricetta: +$xp PE';
  }

  @override
  String get potionSpoiledTitle => 'La pozione si è guastata';

  @override
  String potionSpoiledText(String name) {
    return '$name: pianta tossica. In una ricetta da bere guasta la pozione: le Vis sono perse, ma ora lo sai.';
  }

  @override
  String get shelfEmpty =>
      'Lo Scaffale è vuoto: le pozioni che prepari restano qui.';

  @override
  String recipeBestPotency(int potency) {
    return 'Potenza migliore: $potency';
  }

  @override
  String readyMissingVis(int vis) {
    return 'Ti mancano $vis Vis';
  }

  @override
  String get shelfUse => 'Usa';

  @override
  String get shelfHint =>
      'Tienila per la collezione o usala: l\'effetto vale 7 giorni, con la forza della sua potenza; il Tocco aggiunge un piccolo effetto in più.';

  @override
  String get shelfActive => 'Effetti in corso';

  @override
  String shelfActiveLine(String effect, int strength, String date) {
    return '$effect · forza $strength · fino al $date';
  }

  @override
  String shelfUsed(String effect) {
    return '$effect per 7 giorni';
  }

  @override
  String get glossTavolaTerm => 'Tavola';

  @override
  String get glossTavolaText =>
      'Una ricetta nel Ricettario, come le tavole illustrate degli erbari: \"1 Tavola su 3\". Nella Pagina di una pianta le Tavole che non hai sono slot vuoti con il cerchietto del grado.';

  @override
  String get glossLaboratorioTerm => 'Laboratorio';

  @override
  String get glossLaboratorioText =>
      'La tua base, il capanno-serra ai margini del bosco: dentro si lavora, con Ricettario, Dispensa e Scaffale.';

  @override
  String get glossRicettarioTerm => 'Ricettario';

  @override
  String get glossRicettarioText =>
      'La collezione delle Tavole, una per paese: una Pagina per pianta e, in cima, le Mitiche della Zona, numerate.';

  @override
  String get glossComponenteTerm => 'Componente';

  @override
  String get glossComponenteText =>
      'Un pezzo del nome di una Tavola incompleta (\"Tintura di Eranthis Brinata del…\"): le Non comuni, Rare e Mitiche escono dal Bottino dell\'Esperienza con dei componenti da trovare.';

  @override
  String get glossRiciclatoTerm => 'Riciclato';

  @override
  String get glossRiciclatoText =>
      'Un doppione uscito dal Bottino dell\'Esperienza: 3 riciclati di un grado fanno un componente dello stesso grado, 9 uno del grado sopra, con un po\' di Vis.';

  @override
  String get glossDispensaTerm => 'Dispensa';

  @override
  String get glossDispensaText =>
      'Le Essenze attinte, ognuna con le sue Vis, la purezza (dal livello di studio della pianta quando l\'hai attinta) e le sue Qualia.';

  @override
  String get glossPozioneTerm => 'Pozione';

  @override
  String get glossPozioneText =>
      'Si prepara da una ricetta con le Vis delle Essenze. Ha una potenza da 1 a 10, che viene soprattutto dalla purezza: più conosci le piante, più è potente. Si tiene sullo Scaffale o si usa.';

  @override
  String get glossToccoTerm => 'Tocco';

  @override
  String get glossToccoText =>
      'L\'aggettivo che la pianta dello slot libero dà alla pozione (Rigogliosa, Limpida, Presaga, Copiosa): quando la usi, aggiunge un piccolo effetto.';

  @override
  String get glossPozioneGuastataTerm => 'Pozione guastata';

  @override
  String get glossPozioneGuastataText =>
      'Una pozione da bere con una pianta tossica nello slot libero: le Vis sono perse, ma impari che la pianta è tossica.';

  @override
  String get glossScaffaleTerm => 'Scaffale';

  @override
  String get glossScaffaleText =>
      'Le pozioni che hai: tienile per la collezione o usale. L\'effetto vale 7 giorni, con la forza della potenza.';

  @override
  String get legendPotions => 'Pozioni';

  @override
  String get legendVessel =>
      'Il recipiente dice la base della ricetta (Infuso, Tintura, Filtro…), il colore del liquido le Qualia: uno strato per Qualia. Grigio se la Tavola è incompleta.';

  @override
  String get viewMet => 'Incontrate';

  @override
  String get erbarioSpecies => 'Specie';

  @override
  String get tipOfDayTitle => 'Consiglio del giorno';

  @override
  String get tip01 =>
      'Più studi una pianta, più sono pure le Essenze che ne attingi: la purezza va dal 40 % (pianta mai studiata) al 100 % (pianta di cui hai la Maestria).';

  @override
  String get tip02 =>
      'Nella Potenza di una pozione conta soprattutto la purezza delle Essenze che usi: più conosci le piante delle ricette, più le tue pozioni sono potenti.';

  @override
  String get tip03 =>
      'Le Tavole Comuni del Ricettario si imparano studiando: quando superi il livello 1 di una specie, la Tavola Comune di quella pianta entra nel tuo Ricettario.';

  @override
  String get tip04 =>
      'Le Tavole Non comuni, Rare e Mitiche escono dal Bottino dell\'Esperienza incomplete, con il nome a pezzi: ogni pezzo che manca è un Componente, e lo trovi aprendo altri Bottino dell\'Esperienza.';

  @override
  String get tip05 =>
      'Le Tavole Mitiche si trovano solo aprendo il Bottino dell\'Esperienza di grado mitico.';

  @override
  String get tip06 =>
      'Se il Bottino dell\'Esperienza ti dà una Tavola o un Componente che hai già, è un doppione: lo ricicli con un po\' di Vis. 3 Riciclati fanno un Componente dello stesso grado, 9 un Componente del grado sopra.';

  @override
  String get tip07 =>
      'Riciclare un doppione costa un po\' di Vis, presa dalle tue Essenze: si usano prima le Essenze meno preziose, così quelle con le Qualia restano per le ricette.';

  @override
  String get tip08 =>
      'Ogni ricetta ha uno slot libero, «qualsiasi specie»: la pianta che ci metti dà alla pozione il suo Tocco (Rigogliosa, Limpida, Presaga o Copiosa).';

  @override
  String get tip09 =>
      'Attenzione allo slot libero delle ricette da bere: con una pianta tossica la pozione si guasta e perdi la Vis usata, ma impari che quella pianta è tossica.';

  @override
  String get tip10 =>
      'Nel Ricettario, il filtro \"Mostra solo preparabili\" lascia le Tavole che puoi preparare adesso; aprendo le altre vedi quali Essenze ti mancano: è la lista delle piante da cercare alla prossima uscita.';

  @override
  String get tip11 =>
      'Quando usi una pozione dello Scaffale, il suo effetto dura 7 giorni ed è tanto più forte quanto più alta è la sua Potenza.';

  @override
  String get tip12 =>
      'Le Qualia di un\'Essenza dicono in che condizioni l\'hai attinta (meteo, ora del giorno, luna); il nome di una ricetta dice quali Qualia servono: «Plenilunare» chiede un\'Essenza attinta con la Luna piena.';

  @override
  String get tip13 =>
      'I PE che guadagni studiando una specie restano da Incassare finché non attingi la prima Essenza di quella specie: solo allora diventano PE veri.';

  @override
  String get tip14 =>
      'Il significato di simboli, colori e gradi è nella Legenda: Impostazioni → Legenda e glossario.';

  @override
  String get tip15 =>
      'Nel gioco una pianta non si raccoglie mai: la si fotografa e se ne attinge la Vis. Le piante restano dove sono, intatte.';

  @override
  String get viewToFind => 'Da trovare';

  @override
  String get levelMasteryDormant => 'Maestria sopita';

  @override
  String get masteryToAwaken => 'Maestria da risvegliare';

  @override
  String get awakenButton => 'Risveglia';

  @override
  String get awakenMasteryButton => 'Risveglia la Maestria';

  @override
  String masteryKeepHint(int days) {
    return 'La Maestria si mantiene rispondendo ogni tanto a una domanda di questa specie: dopo $days giorni senza, si assopisce.';
  }

  @override
  String masteryDormantText(
    int days,
    int dormant,
    int full,
    int questions,
    int needed,
  ) {
    return 'Dopo $days giorni senza domande su questa specie la Maestria si è assopita: le nuove Essenze sono pure al $dormant % invece che al $full %. Risvegliala con $questions domande su tutti i Livelli: ne bastano $needed giuste.';
  }

  @override
  String get awakeningTheme => 'Risveglio della Maestria';

  @override
  String summaryAwakened(String name, int full) {
    return 'Maestria risvegliata: le Essenze di $name tornano pure al $full %.';
  }

  @override
  String summaryStillDormant(int needed, int total) {
    return 'Ancora sopita: servono almeno $needed risposte giuste su $total. Puoi riprovare subito.';
  }

  @override
  String get tip16 =>
      'La Maestria di una specie va mantenuta: se per 30 giorni non rispondi a domande su quella specie, la Maestria si assopisce. La risvegli con 5 domande, dalla scheda della specie o da «Le tue specie» in Home.';

  @override
  String get simulateMastery => 'Simula Maestria';

  @override
  String get debugFieldTest => 'Prova sul campo';

  @override
  String get fieldTestIntro =>
      'Ogni prova scatta una foto, la manda a Pl@ntNet e misura il GPS dal tocco per almeno 20 secondi (e 10 dopo la foto). Le prove finiscono in un CSV da scaricare con adb.';

  @override
  String get fieldTestExpected => 'Pianta attesa';

  @override
  String get fieldTestExpectedHint => 'es. elleboro verde, Helleborus viridis';

  @override
  String get fieldTestPlace => 'Luogo';

  @override
  String get fieldTestPlaceHint => 'sole, ombra degli alberi, città…';

  @override
  String get fieldTestRun => 'Scatta e misura';

  @override
  String get fieldTestPhasePhoto => 'Fotocamera…';

  @override
  String get fieldTestPhaseIdentifying => 'Pl@ntNet sta guardando la foto…';

  @override
  String get fieldTestPhaseLocating => 'GPS: ancora qualche secondo…';

  @override
  String get fieldTestNoKey =>
      'Manca la chiave Pl@ntNet (PLANTNET_API_KEY): la foto e il GPS si misurano, l\'identificazione no.';

  @override
  String fieldTestOutcome(String outcome) {
    return 'Esito: $outcome';
  }

  @override
  String fieldTestTimes(String photo, String plantnet, String kb) {
    return 'Foto in $photo s · Pl@ntNet in $plantnet ms · $kb KB';
  }

  @override
  String fieldTestGps(String first, String a5, String a10, String a20) {
    return 'GPS: prima posizione dopo $first s · precisione a 5 s $a5 m, a 10 s $a10 m, a 20 s $a20 m';
  }

  @override
  String fieldTestGpsAfterPhoto(int during, String first, String accuracy) {
    return 'Posizioni durante la foto: $during · dopo la foto la prima in $first s, precisione $accuracy m';
  }

  @override
  String fieldTestRemaining(String count) {
    return 'Identificazioni rimaste oggi: $count';
  }

  @override
  String fieldTestRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prove salvate',
      one: '1 prova salvata',
      zero: 'Nessuna prova salvata',
    );
    return '$_temp0';
  }

  @override
  String get fieldTestCopy => 'Copia il CSV';

  @override
  String get fieldTestCopied => 'CSV copiato';

  @override
  String get fieldTestClear => 'Cancella le prove';

  @override
  String get fieldTestClearConfirm => 'Tocca di nuovo per cancellarle';

  @override
  String get cameraClose => 'Chiudi la fotocamera';

  @override
  String get cameraShutter => 'Scatta';

  @override
  String cameraGps(int metres) {
    return 'GPS ±$metres m';
  }

  @override
  String get cameraGpsSearching => 'GPS…';

  @override
  String get cameraGpsOff => 'GPS spento';

  @override
  String get cameraDenied =>
      'Per fotografare le piante serve il permesso della fotocamera: lo dai dalle impostazioni di Android, alla voce Autorizzazioni dell\'app.';

  @override
  String cameraError(String error) {
    return 'La fotocamera non si è aperta ($error).';
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
    return '$size · $received fps · analizzati $analyzed/s · $ms ms · nitidezza $sharpness · movimento $motion';
  }

  @override
  String get fieldTestSystemCamera => 'Fotocamera di sistema (per confronto)';

  @override
  String fieldTestCamera(
    String fps,
    String analyzed,
    String ms,
    String capture,
    String resize,
  ) {
    return 'Fotocamera: $fps fps, analizzati $analyzed/s in $ms ms · scatto $capture ms · riduzione $resize ms';
  }

  @override
  String get cameraFlashOff => 'Flash spento';

  @override
  String get cameraFlashAuto => 'Flash automatico';

  @override
  String get cameraFlashOn => 'Flash acceso';

  @override
  String cameraZoom(String zoom) {
    return 'Zoom $zoom';
  }

  @override
  String get cameraGatherHint =>
      'Inquadra tutta la pianta: la Vis sale mentre la fotografi, più in fretta se ti muovi';

  @override
  String get cameraShutterLocked =>
      'Ancora un attimo: la Vis comincia a salire';

  @override
  String get cameraLeafHint => 'Ora avvicinati a una foglia';

  @override
  String get cameraFlowerHint => 'E un fiore, se c\'è';

  @override
  String get cameraNoFlower => 'Non ha fiori';

  @override
  String get cameraOrganWhole => 'Pianta intera';

  @override
  String get cameraOrganLeaf => 'Foglia';

  @override
  String get cameraOrganFlower => 'Fiore';

  @override
  String get fieldTestRegional =>
      'Confronta con la flora regionale (2 identificazioni)';

  @override
  String get fieldTestRegionalResult => 'Flora regionale (Europa sudorientale)';

  @override
  String get cameraZoomSlower => 'Senza zoom la Vis sale più in fretta';

  @override
  String get tip17 =>
      'Quando fotografi una pianta, la sua Vis sale finché la inquadri: prenditi il tuo tempo e muoviti piano intorno, dalla pianta intera alla foglia al fiore. Chi ha pazienza raccoglie più Vis.';

  @override
  String get captureNoKey =>
      'Manca la chiave di Pl@ntNet (PLANTNET_API_KEY): per ora l\'Incontro si prova con Simula Incontro.';

  @override
  String get captureLimitTitle => 'Per oggi basta Stazioni nuove';

  @override
  String get captureLimitText =>
      'Oggi è già nata una Stazione nuova: domani potrai fotografare un\'altra pianta. Le Stazioni hanno bisogno del loro tempo.';

  @override
  String get captureGuessTitle => 'Che pianta pensi che sia?';

  @override
  String get captureGuessHint => 'Nome comune o scientifico';

  @override
  String get captureGuessConfirm => 'Ecco la mia ipotesi';

  @override
  String get captureGuessSkip => 'Non lo so';

  @override
  String get captureIdentifying => 'Pl@ntNet sta guardando le foto…';

  @override
  String captureFailed(String error) {
    return 'Pl@ntNet non ha risposto ($error).';
  }

  @override
  String get captureRetry => 'Riprova';

  @override
  String get captureNone =>
      'Pl@ntNet non riconosce questa pianta: riprova più vicino, con la luce sulla pianta, e fotografa anche una foglia o un fiore.';

  @override
  String get captureContested => 'Pl@ntNet è indeciso: quale hai davanti?';

  @override
  String get captureProposed => 'Pl@ntNet pensa che sia:';

  @override
  String get captureConfirm => 'È questa';

  @override
  String get captureKindDiscovery => 'Scoperta';

  @override
  String get captureKindGuest => 'Ospite';

  @override
  String get captureGuestText =>
      'Non è originaria dei tuoi luoghi: è un\'Ospite, e la sua Vis qui è molto debole.';

  @override
  String get captureDiscoveryText =>
      'Nella tua Zona non risulta mai osservata: è una Scoperta, da confermare.';

  @override
  String get captureGuessExact => 'Ci hai preso!';

  @override
  String captureGuessGenus(String genus) {
    return 'Quasi! È un $genus.';
  }

  @override
  String captureGuessWrong(String guess) {
    return 'La tua ipotesi era «$guess».';
  }

  @override
  String get captureStationCreated => 'È nata una nuova Stazione.';

  @override
  String get captureStationExisting =>
      'Sei alla tua Stazione di questa pianta.';

  @override
  String get captureStationNoPosition =>
      'Senza posizione: l\'Incontro vale, la Stazione no.';

  @override
  String get captureStationLimit =>
      'Oggi è già nata una Stazione nuova: questa vale come Incontro.';

  @override
  String captureXp(int xp) {
    return '+$xp PE';
  }

  @override
  String get captureDone => 'Fatto';

  @override
  String get captureAction => 'Attingi';

  @override
  String get captureTitle => 'Attingi la Vis';

  @override
  String get captureFromSpecies => 'Attingi la sua Vis';

  @override
  String get captureFirstPhoto =>
      'La tua foto prende il posto di quella dell\'Erbario, con il timbro di oggi.';

  @override
  String ownPhotoStamp(String date) {
    return 'La tua foto · $date';
  }

  @override
  String get sectionStations => 'Le tue Stazioni';

  @override
  String stationAccuracy(int meters) {
    return '± $meters m';
  }

  @override
  String get stationsNote =>
      'Solo sul tuo telefono: il punto preciso non si mostra e non si condivide.';

  @override
  String get firstRunWelcomeTitle => 'Benvenuto in Druid';

  @override
  String get firstRunWelcomeIntro =>
      'Sei un erborista: trovi le piante vere, le fotografi, le studi e con le loro Essenze prepari pozioni di fantasia. Prima di cominciare, le regole del gioco nel mondo vero.';

  @override
  String get firstRunRuleNoPickTitle => 'Fotografa, non raccogliere';

  @override
  String get firstRunRuleNoPickText =>
      'Le piante non si raccolgono mai: si fotografano e restano dove sono. Non strappare foglie o fiori e non calpestarle.';

  @override
  String get firstRunRuleProtectedTitle => 'Specie e aree protette';

  @override
  String get firstRunRuleProtectedText =>
      'Alcune specie sono protette dalla legge. Nei parchi e nelle riserve resta sui sentieri e rispetta i loro regolamenti.';

  @override
  String get firstRunRulePrivateTitle => 'Niente proprietà private';

  @override
  String get firstRunRulePrivateText =>
      'Non entrare in giardini, campi o terreni privati senza permesso: fotografa da dove puoi stare.';

  @override
  String get firstRunRuleDaylightTitle => 'Con la luce del giorno';

  @override
  String get firstRunRuleDaylightText =>
      'Non uscire a giocare di notte o con poca luce. Le Qualia della luna valgono tutto il giorno: non serve mai.';

  @override
  String get firstRunRuleSafetyTitle => 'Attenzione a dove metti i piedi';

  @override
  String get firstRunRuleSafetyText =>
      'Guarda il terreno e il traffico: non fotografare mentre attraversi la strada o guidi. Se vai lontano, di\' a qualcuno dove vai.';

  @override
  String get firstRunRuleToxicTitle => 'Le piante non si mangiano';

  @override
  String get firstRunRuleToxicText =>
      'Molte piante sono tossiche. Non mangiarle e non usarle per curarti: le pozioni del gioco sono di fantasia e non danno indicazioni d\'uso reali.';

  @override
  String get firstRunRuleIdentifyTitle => 'Il riconoscimento può sbagliare';

  @override
  String get firstRunRuleIdentifyText =>
      'Pl@ntNet riconosce le piante dalle foto, ma può sbagliare. Gli avvisi di tossicità sono da verificare.';

  @override
  String get firstRunRulePrivacyTitle => 'Le tue foto e la tua posizione';

  @override
  String get firstRunRulePrivacyText =>
      'Le foto vanno a Pl@ntNet solo per riconoscere la pianta. La posizione delle tue Stazioni resta sul tuo telefono: non si mostra e non si condivide.';

  @override
  String get firstRunTermsFooter =>
      'Toccando Accetto confermi di aver letto queste regole e di giocare con prudenza e rispetto.';

  @override
  String get firstRunAccept => 'Accetto';

  @override
  String get firstRunCameraTitle => 'Le foto delle piante';

  @override
  String get firstRunCameraText =>
      'Per Incontrare una pianta la fotografi con la fotocamera dell\'app: la pianta intera, una foglia e il fiore se c\'è. Così Pl@ntNet la riconosce e la tua foto entra nell\'Erbario.';

  @override
  String get firstRunCameraAllow => 'Consenti';

  @override
  String get firstRunCameraDenied =>
      'Senza fotocamera non puoi Incontrare le piante. Puoi dare il permesso quando vuoi dalle impostazioni di Android, alla voce Autorizzazioni dell\'app.';

  @override
  String get firstRunLocationTitle => 'La posizione';

  @override
  String get firstRunLocationText =>
      'Dove fotografi una pianta nasce una Stazione: lì potrai tornare ad Attingere. Serve la posizione precisa, solo mentre usi l\'app. Le tue Stazioni restano sul telefono: non si mostrano e non si condividono.';

  @override
  String get firstRunLocationAllow => 'Attiva';

  @override
  String get firstRunLocationDenied =>
      'Senza posizione gli Incontri valgono, ma non nascono Stazioni. Puoi attivarla quando vuoi dalle impostazioni di Android, alla voce Autorizzazioni dell\'app.';

  @override
  String get firstRunLocationApproximate =>
      'Con la posizione approssimativa le Stazioni non sono precise. Puoi scegliere la posizione precisa dalle impostazioni di Android, alla voce Autorizzazioni dell\'app.';

  @override
  String get firstRunOpenSettings => 'Apri le impostazioni';

  @override
  String get firstRunNext => 'Avanti';

  @override
  String get firstRunReadyTitle => 'Sei pronto a giocare';

  @override
  String get firstRunReadyText =>
      'Il tutorial ti accompagna nel primo giro, tutto da casa: fotografi un\'aromatica di cucina, la studi e prepari la tua prima pozione.';

  @override
  String get firstRunStartTutorial => 'Fai il tutorial';

  @override
  String get firstRunLater => 'Più tardi';

  @override
  String get firstRunLaterNote =>
      'Il tutorial resta in Home: lo fai quando vuoi.';

  @override
  String firstRunProgress(int step, int total) {
    return 'Passo $step di $total';
  }

  @override
  String get rankCurious => 'Curioso';

  @override
  String get nextRankCurious =>
      'Prossimo Rango: Apprendista, alla fine del tutorial';

  @override
  String tutorialLabel(int step, int total) {
    return 'Tutorial · passo $step di $total';
  }

  @override
  String get tutorialIntroTitle => 'Il tutorial';

  @override
  String get tutorialIntroBody =>
      'Un giro del gioco tutto da casa, con le aromatiche di cucina: salvia, rosmarino, alloro o basilico, anche in vaso o dal supermercato. Alla fine diventi Apprendista.';

  @override
  String get tutorialStart => 'Inizia';

  @override
  String get tutorialSkip => 'Salta il tutorial';

  @override
  String get tutorialPhotographTitle => 'Fotografa un\'aromatica';

  @override
  String get tutorialPhotographBody =>
      'Tocca Attingi al centro della barra e fotografa salvia, rosmarino, alloro o basilico, anche in vaso o dal supermercato. Pl@ntNet la riconosce: la Incontri, nasce la sua Stazione e ne Attingi la prima Essenza. Fotografa, non raccogliere.';

  @override
  String get tutorialStudyTitle => 'Studia la tua aromatica';

  @override
  String get tutorialStudyBody =>
      'Ogni pianta si studia a Livelli, con domande che fanno imparare anche quando sbagli. Supera il Livello 1 della pianta che hai fotografato: impari la sua Ricetta Comune. Intanto nella barra si è acceso l\'Erbario.';

  @override
  String get tutorialSecondPhotographTitle => 'Fotografa un\'altra aromatica';

  @override
  String get tutorialSecondPhotographBody =>
      'La Ricetta Comune vuole la pianta e un\'altra specie qualsiasi: fotografa un\'altra aromatica e ne Attingi una seconda Essenza.';

  @override
  String get tutorialBrewTitle => 'Prepara la prima pozione';

  @override
  String get tutorialBrewBody =>
      'Nella barra si è acceso il Laboratorio: nel Ricettario trovi la Ricetta Comune pronta, preparala con le tue due Essenze. Le pozioni sono di fantasia.';

  @override
  String get tutorialTroveTitle => 'Il Bottino dell\'Esperienza';

  @override
  String get tutorialTroveBody =>
      'Con i PE compri Bottini dell\'Esperienza: dentro ci sono le Tavole di altre Ricette. Nella barra si è acceso il Bottino: aprilo, c\'è un regalo per te.';

  @override
  String get tutorialApprenticeTitle => 'Sei Apprendista';

  @override
  String get tutorialApprenticeBody =>
      'Hai fatto il primo giro: fotografare, studiare, Attingere, preparare. Ora esci: le piante della tua Zona ti aspettano nell\'Erbario, alla voce Da trovare.';

  @override
  String get tutorialActionCapture => 'Attingi';

  @override
  String get tutorialActionStudy => 'Studia';

  @override
  String get tutorialActionLaboratory => 'Apri il Laboratorio';

  @override
  String get tutorialActionTrove => 'Apri il Bottino';

  @override
  String get tutorialActionFinish => 'Continua';

  @override
  String get erbarioKitchen => 'Dalla cucina';

  @override
  String get kitchenHint =>
      'Un\'aromatica di cucina: la trovi in vaso, sul balcone o al supermercato. Fotografala da casa, anche solo una foglia.';

  @override
  String get sectionOrigin => 'Da dove viene';

  @override
  String get captureTutorialEssence =>
      'Ne hai Attinto la prima Essenza, con le Qualia di questo momento: la trovi nella Dispensa del Laboratorio.';

  @override
  String get sourcesLabel => 'Fonte: ';

  @override
  String get cameraDrawHint =>
      'Inquadra la tua pianta: la Vis sale mentre la guardi, più in fretta se ti muovi';

  @override
  String get captureLocating => 'Cerco dove sei…';

  @override
  String get captureAtStationTitle => 'Sei alla tua Stazione';

  @override
  String get captureAtStationText =>
      'Qui Attingi senza mandare foto a Pl@ntNet: inquadra la pianta e raccogli la Vis.';

  @override
  String get captureOtherPlant => 'È un\'altra pianta';

  @override
  String get stationReady => 'Pronta';

  @override
  String stationExhausted(String when) {
    return 'Esaurita: torna pronta $when';
  }

  @override
  String stationRegrowing(String when) {
    return 'In rigenerazione: torna pronta $when';
  }

  @override
  String stationSuspended(String reason, String when) {
    return 'Raccolta sospesa: $reason, riprende $when';
  }

  @override
  String get suspendedStorm => 'temporale';

  @override
  String get suspendedHail => 'grandine';

  @override
  String get suspendedWind => 'vento forte';

  @override
  String get suspendedSnow => 'neve forte';

  @override
  String whenToday(String time) {
    return 'alle $time';
  }

  @override
  String whenOtherDay(String day, String time) {
    return '$day alle $time';
  }

  @override
  String get captureDrawnTitle => 'Hai Attinto un\'Essenza';

  @override
  String captureDrawnVis(int vis, int purity) {
    return '$vis Vis · purezza $purity %';
  }

  @override
  String get captureDrawnPantry =>
      'La trovi nella Dispensa del Laboratorio, con le Qualia di questo momento.';

  @override
  String get stationsTitle => 'Le tue Stazioni';

  @override
  String stationsSummary(int ready, int total) {
    return '$ready pronte su $total';
  }

  @override
  String get stationsEmpty =>
      'Non hai ancora Stazioni: nascono quando fotografi una pianta con Attingi.';

  @override
  String stationExpectedVis(int vis) {
    return 'Fino a $vis Vis';
  }

  @override
  String stationStormSoon(String reason, String when) {
    return 'Previsto $reason: al tuo arrivo la raccolta potrebbe essere sospesa, fino $when';
  }

  @override
  String get homeStationsOpen => 'Vedi';

  @override
  String get dykTitle => 'Lo sapevi che…';

  @override
  String get dykStorm =>
      'Con il temporale e i fenomeni intensi previsti la raccolta è sospesa nei dintorni, da un\'ora prima a un\'ora dopo.';

  @override
  String get dykDaylight =>
      'Alba e Tramonto valgono solo con la luce: non serve mai Attingere al buio.';

  @override
  String get dykMoon =>
      'Le Qualia della luna valgono tutto il giorno della fase: non serve uscire di notte.';

  @override
  String get dykNoPicking =>
      'Le piante non si raccolgono mai: si fotografano e se ne Attinge la Vis. Fotografa, non raccogliere.';

  @override
  String get dykOneDrawPerDay =>
      'Da ogni Stazione si Attinge una volta al giorno; le piante rare ci mettono giorni a rigenerarsi.';

  @override
  String get dykIsolation =>
      'Le Stazioni lontane tra loro rendono di più: tante piante nello stesso posto si dividono la Vis.';

  @override
  String get tip18 =>
      'Attingi con lune e meteo diversi: non sai mai quali Qualia ti serviranno.';

  @override
  String get glossAffinitaTerm => 'Affinità';

  @override
  String get glossAffinitaText =>
      'Come vive una pianta: la luce, l\'umidità, la quota. Ogni pianta ha anche 3 Qualia sue, che le sue Tavole Non comuni e Rare chiedono: le scopri trovando le Tavole.';

  @override
  String get affinityLightFull => 'Ama la luce piena.';

  @override
  String get affinityLightHalf => 'Sta bene a mezz\'ombra.';

  @override
  String get affinityLightShade => 'Ama l\'ombra.';

  @override
  String get affinityMoistureDry => 'Preferisce i terreni asciutti.';

  @override
  String get affinityMoistureDamp => 'Preferisce i terreni umidi.';

  @override
  String affinityBands(String bands) {
    return 'Cresce $bands.';
  }

  @override
  String get affinityBandPlain => 'in pianura';

  @override
  String get affinityBandHill => 'in collina';

  @override
  String get affinityBandMountain => 'in montagna';

  @override
  String get affinityAnd => ' e ';

  @override
  String recipePotionsLeast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Prepari almeno $count pozioni',
      one: 'Prepari almeno 1 pozione',
    );
    return '$_temp0';
  }

  @override
  String recipePotionsExact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Prepari $count pozioni',
      one: 'Prepari 1 pozione',
    );
    return '$_temp0';
  }

  @override
  String get incompleteInfoTitle => 'La Tavola è incompleta';

  @override
  String get incompleteWhatTitle => 'I «?»';

  @override
  String get incompleteWhatText =>
      'Sono i pezzi del nome che non conosci ancora, i Componenti: alla Non comune manca l\'effetto, alla Rara l\'effetto e una Qualia, alla Mitica le sue parole.';

  @override
  String get incompleteBrewTitle => 'Non si prepara ancora';

  @override
  String get incompleteBrewText =>
      'Finché manca un Componente la Tavola resta nel Ricettario, ma non si prepara.';

  @override
  String get incompleteWhereTitle => 'Dove si trovano';

  @override
  String get incompleteWhereText =>
      'Nei Bottini dell\'Esperienza del suo Grado o più alti: a volte un Bottino dà un Componente invece di una Tavola nuova. Oppure con il Riciclo dei doppioni, in fondo alla pagina del Bottino.';

  @override
  String get incompleteInfoTooltip => 'Che cosa manca';

  @override
  String get recipeQualiaUnknown => 'Una Qualia che non conosci ancora';

  @override
  String get intermediateIntroTitle => 'Il tutorial intermedio';

  @override
  String get intermediateIntroBody =>
      'Ancora da casa, con le aromatiche: Attingi alla tua Stazione, leggi le Qualia dell\'Essenza e prepari una Ricetta Non comune, con il Tocco dello slot libero.';

  @override
  String intermediateLabel(int step, int total) {
    return 'Tutorial intermedio · passo $step di $total';
  }

  @override
  String get intermediateSkip => 'Salta il tutorial intermedio';

  @override
  String get intermediateHerbTitle => 'Fotografa un\'aromatica';

  @override
  String get intermediateHerbBody =>
      'Il tutorial intermedio usa le aromatiche di cucina: salvia, rosmarino o basilico, anche in vaso.';

  @override
  String get intermediateStudyTitle => 'Studia il Livello 2';

  @override
  String intermediateStudyBody(String plant) {
    return 'Supera il Livello 2 di $plant: impari la sua Ricetta Non comune, che chiede la pianta attinta con il Sole.';
  }

  @override
  String get intermediateDrawSunTitle => 'Attingi con il Sole';

  @override
  String intermediateDrawSunBody(String plant) {
    return 'Torna alla Stazione di $plant e Attingi: uno scatto, senza Pl@ntNet. Le Qualia del momento entrano nell\'Essenza, e la Non comune vuole il Sole.';
  }

  @override
  String get intermediateCompanionTitle => 'Il compagno';

  @override
  String intermediateCompanionBody(String companion) {
    return 'La Non comune chiede anche $companion, il suo compagno: Attingi alla sua Stazione o fotografalo, se non l\'hai ancora.';
  }

  @override
  String get intermediateBrewTitle => 'La Non comune e il Tocco';

  @override
  String get intermediateBrewBody =>
      'Nel Laboratorio prepara la Non comune: nello slot libero metti una terza specie e guarda il Tocco che dà alla pozione.';

  @override
  String get intermediateFinishedTitle => 'Hai finito il tutorial intermedio';

  @override
  String get intermediateFinishedBody =>
      'Sai Attingere alla tua Stazione, leggere le Qualia e usare il Tocco. Fuori ti aspettano le piante della Zona.';

  @override
  String get intermediateActionFinish => 'Fatto';

  @override
  String get captureLentSun =>
      'Il tutorial ti presta il Sole. Fuori, le Qualia le decide il cielo: con le nuvole niente Sole.';

  @override
  String get potionTouchHint =>
      'La pianta che hai messo nello slot libero ha dato alla pozione il suo Tocco: quando la usi, aggiunge un piccolo effetto, il suo.';
}
