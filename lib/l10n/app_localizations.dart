import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'Druid'**
  String get appTitle;

  /// No description provided for @navErbario.
  ///
  /// In it, this message translates to:
  /// **'Erbario'**
  String get navErbario;

  /// No description provided for @navSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get navSettings;

  /// No description provided for @erbarioTitle.
  ///
  /// In it, this message translates to:
  /// **'Erbario'**
  String get erbarioTitle;

  /// No description provided for @erbarioFound.
  ///
  /// In it, this message translates to:
  /// **'{found}/{total} trovate'**
  String erbarioFound(int found, int total);

  /// No description provided for @unknownSpecies.
  ///
  /// In it, this message translates to:
  /// **'???'**
  String get unknownSpecies;

  /// No description provided for @hintFamily.
  ///
  /// In it, this message translates to:
  /// **'Una pianta della famiglia {family}'**
  String hintFamily(String family);

  /// No description provided for @hintSeasonWinter.
  ///
  /// In it, this message translates to:
  /// **'che si fa notare soprattutto in inverno'**
  String get hintSeasonWinter;

  /// No description provided for @hintSeasonSpring.
  ///
  /// In it, this message translates to:
  /// **'che si fa notare soprattutto in primavera'**
  String get hintSeasonSpring;

  /// No description provided for @hintSeasonSummer.
  ///
  /// In it, this message translates to:
  /// **'che si fa notare soprattutto d\'estate'**
  String get hintSeasonSummer;

  /// No description provided for @hintSeasonAutumn.
  ///
  /// In it, this message translates to:
  /// **'che si fa notare soprattutto in autunno'**
  String get hintSeasonAutumn;

  /// No description provided for @hintBandPlain.
  ///
  /// In it, this message translates to:
  /// **'in pianura'**
  String get hintBandPlain;

  /// No description provided for @hintBandHill.
  ///
  /// In it, this message translates to:
  /// **'in collina'**
  String get hintBandHill;

  /// No description provided for @hintBandMountain.
  ///
  /// In it, this message translates to:
  /// **'in montagna'**
  String get hintBandMountain;

  /// No description provided for @settingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settingsTitle;

  /// No description provided for @liveryLabel.
  ///
  /// In it, this message translates to:
  /// **'Livrea'**
  String get liveryLabel;

  /// No description provided for @liveryErbario.
  ///
  /// In it, this message translates to:
  /// **'Erbario'**
  String get liveryErbario;

  /// No description provided for @liveryNotturna.
  ///
  /// In it, this message translates to:
  /// **'Notturna'**
  String get liveryNotturna;

  /// No description provided for @themeModeLabel.
  ///
  /// In it, this message translates to:
  /// **'Aspetto'**
  String get themeModeLabel;

  /// No description provided for @themeModeSystem.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In it, this message translates to:
  /// **'Chiaro'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In it, this message translates to:
  /// **'Scuro'**
  String get themeModeDark;

  /// No description provided for @loadingError.
  ///
  /// In it, this message translates to:
  /// **'Non è stato possibile caricare i dati'**
  String get loadingError;

  /// No description provided for @retry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get retry;

  /// No description provided for @simulateEncounter.
  ///
  /// In it, this message translates to:
  /// **'Simula Incontro'**
  String get simulateEncounter;

  /// No description provided for @levelToStudy.
  ///
  /// In it, this message translates to:
  /// **'Da studiare'**
  String get levelToStudy;

  /// No description provided for @levelRecognise.
  ///
  /// In it, this message translates to:
  /// **'Riconoscerla'**
  String get levelRecognise;

  /// No description provided for @levelKnow.
  ///
  /// In it, this message translates to:
  /// **'Famiglia e vita'**
  String get levelKnow;

  /// No description provided for @levelWhereWhen.
  ///
  /// In it, this message translates to:
  /// **'Il suo ambiente'**
  String get levelWhereWhen;

  /// No description provided for @levelMastery.
  ///
  /// In it, this message translates to:
  /// **'Maestria'**
  String get levelMastery;

  /// No description provided for @navStudy.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get navStudy;

  /// No description provided for @rankApprentice.
  ///
  /// In it, this message translates to:
  /// **'Apprendista'**
  String get rankApprentice;

  /// No description provided for @rankWanderer.
  ///
  /// In it, this message translates to:
  /// **'Viandante'**
  String get rankWanderer;

  /// No description provided for @rankSeeker.
  ///
  /// In it, this message translates to:
  /// **'Cercatore'**
  String get rankSeeker;

  /// No description provided for @rankWarden.
  ///
  /// In it, this message translates to:
  /// **'Custode'**
  String get rankWarden;

  /// No description provided for @rankBotanomancer.
  ///
  /// In it, this message translates to:
  /// **'Botanomante'**
  String get rankBotanomancer;

  /// No description provided for @xpTotal.
  ///
  /// In it, this message translates to:
  /// **'{xp} PE'**
  String xpTotal(int xp);

  /// No description provided for @nextRank.
  ///
  /// In it, this message translates to:
  /// **'Prossimo Rango: {rank} a {xp} PE'**
  String nextRank(String rank, int xp);

  /// No description provided for @maxRankReached.
  ///
  /// In it, this message translates to:
  /// **'Hai raggiunto il Rango più alto'**
  String get maxRankReached;

  /// No description provided for @seasonWinter.
  ///
  /// In it, this message translates to:
  /// **'inverno'**
  String get seasonWinter;

  /// No description provided for @seasonSpring.
  ///
  /// In it, this message translates to:
  /// **'primavera'**
  String get seasonSpring;

  /// No description provided for @seasonSummer.
  ///
  /// In it, this message translates to:
  /// **'estate'**
  String get seasonSummer;

  /// No description provided for @seasonAutumn.
  ///
  /// In it, this message translates to:
  /// **'autunno'**
  String get seasonAutumn;

  /// No description provided for @bandPlain.
  ///
  /// In it, this message translates to:
  /// **'Pianura (sotto i 150 m)'**
  String get bandPlain;

  /// No description provided for @bandHill.
  ///
  /// In it, this message translates to:
  /// **'Collina (150–600 m)'**
  String get bandHill;

  /// No description provided for @bandMountain.
  ///
  /// In it, this message translates to:
  /// **'Montagna (oltre i 600 m)'**
  String get bandMountain;

  /// No description provided for @qPhotoToName.
  ///
  /// In it, this message translates to:
  /// **'Che pianta è questa?'**
  String get qPhotoToName;

  /// No description provided for @qNameToPhoto.
  ///
  /// In it, this message translates to:
  /// **'Quale di queste è {name}?'**
  String qNameToPhoto(String name);

  /// No description provided for @qSciToCommon.
  ///
  /// In it, this message translates to:
  /// **'Come si chiama comunemente {sci}?'**
  String qSciToCommon(String sci);

  /// No description provided for @qCommonToSci.
  ///
  /// In it, this message translates to:
  /// **'Qual è il nome scientifico di: {name}?'**
  String qCommonToSci(String name);

  /// No description provided for @qFamilyFromCommon.
  ///
  /// In it, this message translates to:
  /// **'A quale famiglia appartiene: {name}?'**
  String qFamilyFromCommon(String name);

  /// No description provided for @qFamilyFromSci.
  ///
  /// In it, this message translates to:
  /// **'A quale famiglia appartiene {sci}?'**
  String qFamilyFromSci(String sci);

  /// No description provided for @qFamilyFromPhoto.
  ///
  /// In it, this message translates to:
  /// **'A quale famiglia appartiene la pianta in foto?'**
  String get qFamilyFromPhoto;

  /// No description provided for @qRelativeOf.
  ///
  /// In it, this message translates to:
  /// **'Quale di queste piante è della stessa famiglia di: {name}?'**
  String qRelativeOf(String name);

  /// No description provided for @qOddOneOut.
  ///
  /// In it, this message translates to:
  /// **'Quale NON è della stessa famiglia delle altre?'**
  String get qOddOneOut;

  /// No description provided for @qBandOf.
  ///
  /// In it, this message translates to:
  /// **'Dove incontri più spesso {name}, qui?'**
  String qBandOf(String name);

  /// No description provided for @qWhichInBand.
  ///
  /// In it, this message translates to:
  /// **'Quale di queste piante trovi più facilmente {band}?'**
  String qWhichInBand(String band);

  /// No description provided for @factAppearance.
  ///
  /// In it, this message translates to:
  /// **'{name} ({sci})'**
  String factAppearance(String name, String sci);

  /// No description provided for @factName.
  ///
  /// In it, this message translates to:
  /// **'{name} = {sci}'**
  String factName(String name, String sci);

  /// No description provided for @factFamily.
  ///
  /// In it, this message translates to:
  /// **'{name} appartiene alla famiglia {family}.'**
  String factFamily(String name, String family);

  /// No description provided for @factRelatives.
  ///
  /// In it, this message translates to:
  /// **'{name} è parente di: {relatives} ({family}).'**
  String factRelatives(String name, String relatives, String family);

  /// No description provided for @factSeason.
  ///
  /// In it, this message translates to:
  /// **'{name} si fa notare soprattutto in {season}. Mesi migliori: {months}.'**
  String factSeason(String name, String season, String months);

  /// No description provided for @factAltitude.
  ///
  /// In it, this message translates to:
  /// **'{name} si incontra soprattutto {band} (quota mediana {meters} m).'**
  String factAltitude(String name, String band, int meters);

  /// No description provided for @answerRight.
  ///
  /// In it, this message translates to:
  /// **'Giusto!'**
  String get answerRight;

  /// No description provided for @answerWrong.
  ///
  /// In it, this message translates to:
  /// **'Non proprio.'**
  String get answerWrong;

  /// No description provided for @answerWillReturn.
  ///
  /// In it, this message translates to:
  /// **'Tornerà tra poco, in un\'altra forma.'**
  String get answerWillReturn;

  /// No description provided for @answerRemembered.
  ///
  /// In it, this message translates to:
  /// **'Te lo ricordavi! Prossimo Ripasso tra {days} giorni.'**
  String answerRemembered(int days);

  /// No description provided for @answerForgotten.
  ///
  /// In it, this message translates to:
  /// **'Dimenticato: tornerà nei Ripassi di domani.'**
  String get answerForgotten;

  /// No description provided for @xpGained.
  ///
  /// In it, this message translates to:
  /// **'+{xp} PE'**
  String xpGained(int xp);

  /// No description provided for @next.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get next;

  /// No description provided for @close.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get close;

  /// No description provided for @studyLevelTitle.
  ///
  /// In it, this message translates to:
  /// **'{name} · Livello {level}'**
  String studyLevelTitle(String name, int level);

  /// No description provided for @reviewTitle.
  ///
  /// In it, this message translates to:
  /// **'Ripasso'**
  String get reviewTitle;

  /// No description provided for @studyProgress.
  ///
  /// In it, this message translates to:
  /// **'{done} di {total}'**
  String studyProgress(int done, int total);

  /// No description provided for @summaryTitle.
  ///
  /// In it, this message translates to:
  /// **'Fine sessione'**
  String get summaryTitle;

  /// No description provided for @summaryLevelPassed.
  ///
  /// In it, this message translates to:
  /// **'Livello {level} superato: {name} entra nei Ripassi da domani.'**
  String summaryLevelPassed(int level, String name);

  /// No description provided for @summaryReviewDone.
  ///
  /// In it, this message translates to:
  /// **'Ripassi completati.'**
  String get summaryReviewDone;

  /// No description provided for @summaryAnswers.
  ///
  /// In it, this message translates to:
  /// **'Risposte giuste: {correct} su {answers}'**
  String summaryAnswers(int correct, int answers);

  /// No description provided for @summaryMastery.
  ///
  /// In it, this message translates to:
  /// **'Maestria raggiunta!'**
  String get summaryMastery;

  /// No description provided for @summaryNewFunFacts.
  ///
  /// In it, this message translates to:
  /// **'Nuove Curiosità in arrivo: le riceverai una al giorno.'**
  String get summaryNewFunFacts;

  /// No description provided for @saveToNotebook.
  ///
  /// In it, this message translates to:
  /// **'Salva nel Taccuino'**
  String get saveToNotebook;

  /// No description provided for @savedToNotebook.
  ///
  /// In it, this message translates to:
  /// **'Nel Taccuino'**
  String get savedToNotebook;

  /// No description provided for @notebookLocked.
  ///
  /// In it, this message translates to:
  /// **'Salva nel Taccuino'**
  String get notebookLocked;

  /// No description provided for @diarioUpsell.
  ///
  /// In it, this message translates to:
  /// **'Con il Diario dell\'Erborista salvi in un tocco ciò che impari e lo ritrovi quando ti serve, anche durante lo studio. Senza Diario puoi fare lo stesso con un quaderno vero e con le note per specie, che restano gratuite.'**
  String get diarioUpsell;

  /// No description provided for @notebookTitle.
  ///
  /// In it, this message translates to:
  /// **'Taccuino'**
  String get notebookTitle;

  /// No description provided for @notebookSearch.
  ///
  /// In it, this message translates to:
  /// **'Cerca: famiglia, mese, specie, note…'**
  String get notebookSearch;

  /// No description provided for @notebookEmpty.
  ///
  /// In it, this message translates to:
  /// **'Ancora vuoto: durante lo studio usa \"Salva nel Taccuino\".'**
  String get notebookEmpty;

  /// No description provided for @notebookNoResults.
  ///
  /// In it, this message translates to:
  /// **'Nessun risultato.'**
  String get notebookNoResults;

  /// No description provided for @notesTitle.
  ///
  /// In it, this message translates to:
  /// **'Le tue note'**
  String get notesTitle;

  /// No description provided for @notesHint.
  ///
  /// In it, this message translates to:
  /// **'Dove l\'hai vista, come riconoscerla…'**
  String get notesHint;

  /// No description provided for @notesSave.
  ///
  /// In it, this message translates to:
  /// **'Salva nota'**
  String get notesSave;

  /// No description provided for @notesSaved.
  ///
  /// In it, this message translates to:
  /// **'Nota salvata'**
  String get notesSaved;

  /// No description provided for @funOfDayTitle.
  ///
  /// In it, this message translates to:
  /// **'Curiosità del giorno'**
  String get funOfDayTitle;

  /// No description provided for @funOfDayCount.
  ///
  /// In it, this message translates to:
  /// **'{seen} scoperte su {total}'**
  String funOfDayCount(int seen, int total);

  /// No description provided for @funOfDayEmpty.
  ///
  /// In it, this message translates to:
  /// **'Incontra e studia una specie per ricevere ogni giorno una Curiosità su ciò che hai imparato.'**
  String get funOfDayEmpty;

  /// No description provided for @funToVerify.
  ///
  /// In it, this message translates to:
  /// **'da verificare'**
  String get funToVerify;

  /// No description provided for @funRank.
  ///
  /// In it, this message translates to:
  /// **'{name} è al {rank}° posto tra le piante spontanee più osservate della zona.'**
  String funRank(String name, int rank);

  /// No description provided for @funHigh.
  ///
  /// In it, this message translates to:
  /// **'{name} è tra le 5 specie della zona che vivono più in alto: metà delle osservazioni supera i {meters} m.'**
  String funHigh(String name, int meters);

  /// No description provided for @funLow.
  ///
  /// In it, this message translates to:
  /// **'{name} è tra le 5 specie più di pianura della zona: quota mediana {meters} m.'**
  String funLow(String name, int meters);

  /// No description provided for @funPeak.
  ///
  /// In it, this message translates to:
  /// **'{name} si fa notare soprattutto a {month}.'**
  String funPeak(String name, String month);

  /// No description provided for @reviewsTitle.
  ///
  /// In it, this message translates to:
  /// **'Ripassi'**
  String get reviewsTitle;

  /// No description provided for @reviewsDue.
  ///
  /// In it, this message translates to:
  /// **'{count} Fatti da ripassare oggi'**
  String reviewsDue(int count);

  /// No description provided for @reviewsNone.
  ///
  /// In it, this message translates to:
  /// **'Niente da ripassare oggi. I Fatti imparati tornano dopo 1, 3, 7, 21, 60 e 180 giorni.'**
  String get reviewsNone;

  /// No description provided for @reviewsStart.
  ///
  /// In it, this message translates to:
  /// **'Ripassa'**
  String get reviewsStart;

  /// No description provided for @desiderataTitle.
  ///
  /// In it, this message translates to:
  /// **'Desiderata'**
  String get desiderataTitle;

  /// No description provided for @desiderataEmpty.
  ///
  /// In it, this message translates to:
  /// **'Scegli le specie da cercare: vedrai foto e indicazioni su dove e quando trovarle.'**
  String get desiderataEmpty;

  /// No description provided for @desiderataSuggestions.
  ///
  /// In it, this message translates to:
  /// **'In stagione adesso'**
  String get desiderataSuggestions;

  /// No description provided for @seasonalFirstHint.
  ///
  /// In it, this message translates to:
  /// **'Tre specie facili da riconoscere, per cominciare subito: si studia anche da casa.'**
  String get seasonalFirstHint;

  /// No description provided for @seasonalHint.
  ///
  /// In it, this message translates to:
  /// **'Puoi studiarle subito o segnarle come Desiderata da cercare.'**
  String get seasonalHint;

  /// No description provided for @seasonalStudy.
  ///
  /// In it, this message translates to:
  /// **'Studia'**
  String get seasonalStudy;

  /// No description provided for @yourSpeciesMet.
  ///
  /// In it, this message translates to:
  /// **'Incontrata'**
  String get yourSpeciesMet;

  /// No description provided for @desiderataAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi alle Desiderata'**
  String get desiderataAdd;

  /// No description provided for @desiderataRemove.
  ///
  /// In it, this message translates to:
  /// **'Togli dalle Desiderata'**
  String get desiderataRemove;

  /// No description provided for @desiderataWhere.
  ///
  /// In it, this message translates to:
  /// **'Dove: {band}'**
  String desiderataWhere(String band);

  /// No description provided for @desiderataWhen.
  ///
  /// In it, this message translates to:
  /// **'Quando: {months}'**
  String desiderataWhen(String months);

  /// No description provided for @desiderataFamily.
  ///
  /// In it, this message translates to:
  /// **'Famiglia: {family}'**
  String desiderataFamily(String family);

  /// No description provided for @yourSpecies.
  ///
  /// In it, this message translates to:
  /// **'Le tue specie'**
  String get yourSpecies;

  /// No description provided for @yourSpeciesEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna specie in studio: comincia da una di quelle in stagione.'**
  String get yourSpeciesEmpty;

  /// No description provided for @studyLevelButton.
  ///
  /// In it, this message translates to:
  /// **'Studia il Livello {level}'**
  String studyLevelButton(int level);

  /// No description provided for @studyButton.
  ///
  /// In it, this message translates to:
  /// **'Studia'**
  String get studyButton;

  /// No description provided for @studyComplete.
  ///
  /// In it, this message translates to:
  /// **'Domande completate'**
  String get studyComplete;

  /// No description provided for @levelsTitle.
  ///
  /// In it, this message translates to:
  /// **'Livelli di studio'**
  String get levelsTitle;

  /// No description provided for @lockedSection.
  ///
  /// In it, this message translates to:
  /// **'Si rivela al Livello {level} ({name})'**
  String lockedSection(int level, String name);

  /// No description provided for @sectionSci.
  ///
  /// In it, this message translates to:
  /// **'Nome scientifico'**
  String get sectionSci;

  /// No description provided for @sectionFamily.
  ///
  /// In it, this message translates to:
  /// **'Famiglia'**
  String get sectionFamily;

  /// No description provided for @sectionRelatives.
  ///
  /// In it, this message translates to:
  /// **'Parenti nella zona'**
  String get sectionRelatives;

  /// No description provided for @sectionWhen.
  ///
  /// In it, this message translates to:
  /// **'Quando si osserva'**
  String get sectionWhen;

  /// No description provided for @sectionWhere.
  ///
  /// In it, this message translates to:
  /// **'Dove (quota mediana {meters} m)'**
  String sectionWhere(int meters);

  /// No description provided for @sectionLore.
  ///
  /// In it, this message translates to:
  /// **'Lore'**
  String get sectionLore;

  /// No description provided for @sectionFunFacts.
  ///
  /// In it, this message translates to:
  /// **'Curiosità {seen}/{total}'**
  String sectionFunFacts(int seen, int total);

  /// No description provided for @sectionFunFactsHidden.
  ///
  /// In it, this message translates to:
  /// **'{count} ancora da scoprire'**
  String sectionFunFactsHidden(int count);

  /// No description provided for @safetyWarning.
  ///
  /// In it, this message translates to:
  /// **'{text} · da verificare'**
  String safetyWarning(String text);

  /// No description provided for @protectedNote.
  ///
  /// In it, this message translates to:
  /// **'Specie protetta ({sources}). Guardala e fotografala: non raccoglierla, non calpestarla, non alterare l\'ambiente e resta sul sentiero.'**
  String protectedNote(String sources);

  /// No description provided for @masteryTitle.
  ///
  /// In it, this message translates to:
  /// **'Maestria'**
  String get masteryTitle;

  /// No description provided for @masteryFacts.
  ///
  /// In it, this message translates to:
  /// **'Fatti consolidati (ricordati a 1 e 3 giorni): {done}/{total}'**
  String masteryFacts(int done, int total);

  /// No description provided for @masteryDraws.
  ///
  /// In it, this message translates to:
  /// **'Essenze Attinte: {done}/{total} · Tratti diversi: {traits}/{needed}'**
  String masteryDraws(int done, int total, int traits, int needed);

  /// No description provided for @masteryOnlyField.
  ///
  /// In it, this message translates to:
  /// **'Con il solo studio non si arriva alla Maestria: servono anche le Essenze Attinte sul campo.'**
  String get masteryOnlyField;

  /// No description provided for @masteryReached.
  ///
  /// In it, this message translates to:
  /// **'Maestria raggiunta'**
  String get masteryReached;

  /// No description provided for @simulateDraw.
  ///
  /// In it, this message translates to:
  /// **'Simula Attingere'**
  String get simulateDraw;

  /// No description provided for @noTrait.
  ///
  /// In it, this message translates to:
  /// **'Nessun Tratto'**
  String get noTrait;

  /// No description provided for @traitFrost.
  ///
  /// In it, this message translates to:
  /// **'❄️ Gelo'**
  String get traitFrost;

  /// No description provided for @traitRain.
  ///
  /// In it, this message translates to:
  /// **'🌧 Pioggia'**
  String get traitRain;

  /// No description provided for @traitFog.
  ///
  /// In it, this message translates to:
  /// **'🌫 Nebbia'**
  String get traitFog;

  /// No description provided for @traitSun.
  ///
  /// In it, this message translates to:
  /// **'☀️ Solare'**
  String get traitSun;

  /// No description provided for @traitMoon.
  ///
  /// In it, this message translates to:
  /// **'🌕 Luna piena'**
  String get traitMoon;

  /// No description provided for @traitDew.
  ///
  /// In it, this message translates to:
  /// **'💧 Rugiada'**
  String get traitDew;

  /// No description provided for @traitDusk.
  ///
  /// In it, this message translates to:
  /// **'🌅 Tramonto'**
  String get traitDusk;

  /// No description provided for @recipesTitle.
  ///
  /// In it, this message translates to:
  /// **'Ricette'**
  String get recipesTitle;

  /// No description provided for @recipeAnySpecies.
  ///
  /// In it, this message translates to:
  /// **'qualsiasi specie'**
  String get recipeAnySpecies;

  /// No description provided for @erbarioPages.
  ///
  /// In it, this message translates to:
  /// **'Pagine compilate {done}/{total}'**
  String erbarioPages(int done, int total);

  /// No description provided for @missionLabel.
  ///
  /// In it, this message translates to:
  /// **'Missione {index} di {total}'**
  String missionLabel(int index, int total);

  /// No description provided for @missionVisitErbarioTitle.
  ///
  /// In it, this message translates to:
  /// **'Apri l\'Erbario'**
  String get missionVisitErbarioTitle;

  /// No description provided for @missionVisitErbarioBody.
  ///
  /// In it, this message translates to:
  /// **'L\'Erbario raccoglie le specie della zona, ognuna con foto e nome. Il resto si scopre studiandole e Incontrandole.'**
  String get missionVisitErbarioBody;

  /// No description provided for @missionMarkDesiderataTitle.
  ///
  /// In it, this message translates to:
  /// **'Scegli le tue Desiderata'**
  String get missionMarkDesiderataTitle;

  /// No description provided for @missionMarkDesiderataBody.
  ///
  /// In it, this message translates to:
  /// **'Scegli le specie da cercare: per ognuna vedrai foto, periodo e quota. Comincia da una in stagione adesso.'**
  String get missionMarkDesiderataBody;

  /// No description provided for @missionFirstEncounterTitle.
  ///
  /// In it, this message translates to:
  /// **'Incontra una specie'**
  String get missionFirstEncounterTitle;

  /// No description provided for @missionFirstEncounterBody.
  ///
  /// In it, this message translates to:
  /// **'Esci a Erborizzare e fotografa una delle tue Desiderata: una volta riconosciuta comparirà nell\'Erbario. Fotografa, non raccogliere.'**
  String get missionFirstEncounterBody;

  /// No description provided for @missionFirstLevelTitle.
  ///
  /// In it, this message translates to:
  /// **'Studia la tua prima specie'**
  String get missionFirstLevelTitle;

  /// No description provided for @missionFirstLevelBody.
  ///
  /// In it, this message translates to:
  /// **'Scegli una specie in stagione e supera il primo Livello di studio: si comincia anche da casa. Anche gli errori insegnano e danno Punti Esperienza.'**
  String get missionFirstLevelBody;

  /// No description provided for @missionFirstRecipeTitle.
  ///
  /// In it, this message translates to:
  /// **'La prima Ricetta'**
  String get missionFirstRecipeTitle;

  /// No description provided for @missionFirstRecipeBody.
  ///
  /// In it, this message translates to:
  /// **'Studiando una specie impari la sua Ricetta Comune: la trovi nel Ricettario, sulla Pagina della pianta. Le altre Tavole della Pagina si trovano nel Bottino dell\'Esperienza.'**
  String get missionFirstRecipeBody;

  /// No description provided for @missionSkip.
  ///
  /// In it, this message translates to:
  /// **'Salta l\'Apprendistato'**
  String get missionSkip;

  /// No description provided for @missionActionOpenErbario.
  ///
  /// In it, this message translates to:
  /// **'Apri l\'Erbario'**
  String get missionActionOpenErbario;

  /// No description provided for @missionActionChooseDesiderata.
  ///
  /// In it, this message translates to:
  /// **'Scegli nell\'Erbario'**
  String get missionActionChooseDesiderata;

  /// No description provided for @missionActionStudy.
  ///
  /// In it, this message translates to:
  /// **'Inizia a studiare'**
  String get missionActionStudy;

  /// No description provided for @missionActionRecipes.
  ///
  /// In it, this message translates to:
  /// **'Apri il Ricettario'**
  String get missionActionRecipes;

  /// No description provided for @missionGlossary.
  ///
  /// In it, this message translates to:
  /// **'Glossario'**
  String get missionGlossary;

  /// No description provided for @apprenticeshipComplete.
  ///
  /// In it, this message translates to:
  /// **'Apprendistato completato!'**
  String get apprenticeshipComplete;

  /// No description provided for @glossaryTitle.
  ///
  /// In it, this message translates to:
  /// **'Legenda e glossario'**
  String get glossaryTitle;

  /// No description provided for @glossErbarioTerm.
  ///
  /// In it, this message translates to:
  /// **'Erbario'**
  String get glossErbarioTerm;

  /// No description provided for @glossErbarioText.
  ///
  /// In it, this message translates to:
  /// **'Collezione di piante, un tempo essiccate e annotate su fogli con data e luogo di raccolta. Qui si compila con le specie che Incontri e studi.'**
  String get glossErbarioText;

  /// No description provided for @glossDesiderataTerm.
  ///
  /// In it, this message translates to:
  /// **'Desiderata'**
  String get glossDesiderataTerm;

  /// No description provided for @glossDesiderataText.
  ///
  /// In it, this message translates to:
  /// **'Negli erbari e tra i collezionisti, l\'elenco degli esemplari che si desidera trovare. Qui sono le specie (al massimo 3) che hai scelto di cercare.'**
  String get glossDesiderataText;

  /// No description provided for @glossErborizzareTerm.
  ///
  /// In it, this message translates to:
  /// **'Erborizzare'**
  String get glossErborizzareTerm;

  /// No description provided for @glossErborizzareText.
  ///
  /// In it, this message translates to:
  /// **'Andare per campi e boschi a osservare e studiare le piante: è il verbo storico dei botanici in escursione.'**
  String get glossErborizzareText;

  /// No description provided for @glossStazioneTerm.
  ///
  /// In it, this message translates to:
  /// **'Stazione'**
  String get glossStazioneTerm;

  /// No description provided for @glossStazioneText.
  ///
  /// In it, this message translates to:
  /// **'In botanica, il luogo preciso in cui cresce una popolazione di una specie, con le sue condizioni di suolo, esposizione e quota. Qui è il punto in cui hai Incontrato una specie e dove potrai tornare ad Attingere.'**
  String get glossStazioneText;

  /// No description provided for @glossTrattoTerm.
  ///
  /// In it, this message translates to:
  /// **'Tratto'**
  String get glossTrattoTerm;

  /// No description provided for @glossTrattoText.
  ///
  /// In it, this message translates to:
  /// **'Una condizione del momento in cui Attingi un\'Essenza (Luna piena, Pioggia, Nebbia, Rugiada…): un\'Essenza le porta tutte. Le Ricette chiedono Tratti diversi: la stessa pianta in giorni diversi dà Essenze diverse.'**
  String get glossTrattoText;

  /// No description provided for @glossAttingereTerm.
  ///
  /// In it, this message translates to:
  /// **'Attingere'**
  String get glossAttingereTerm;

  /// No description provided for @glossAttingereText.
  ///
  /// In it, this message translates to:
  /// **'Trarre l\'Essenza da una Stazione senza toccare la pianta: si fotografa e si osserva, non si raccoglie.'**
  String get glossAttingereText;

  /// No description provided for @glossMaestriaTerm.
  ///
  /// In it, this message translates to:
  /// **'Maestria'**
  String get glossMaestriaTerm;

  /// No description provided for @glossMaestriaText.
  ///
  /// In it, this message translates to:
  /// **'L\'ultimo Livello di una specie: richiede di ricordare ciò che hai imparato a distanza di giorni e di aver Attinto la specie sul campo in condizioni diverse.'**
  String get glossMaestriaText;

  /// No description provided for @glossMissioneTerm.
  ///
  /// In it, this message translates to:
  /// **'Missione'**
  String get glossMissioneTerm;

  /// No description provided for @glossMissioneText.
  ///
  /// In it, this message translates to:
  /// **'Un obiettivo da raggiungere nel mondo reale o nello studio: Incontrare una specie, superare un Livello, sbloccare una Ricetta.'**
  String get glossMissioneText;

  /// No description provided for @debugTitle.
  ///
  /// In it, this message translates to:
  /// **'Strumenti di prova'**
  String get debugTitle;

  /// No description provided for @debugDays.
  ///
  /// In it, this message translates to:
  /// **'Giorno simulato: +{days}'**
  String debugDays(int days);

  /// No description provided for @debugAdvance.
  ///
  /// In it, this message translates to:
  /// **'+{days} g'**
  String debugAdvance(int days);

  /// No description provided for @debugDiario.
  ///
  /// In it, this message translates to:
  /// **'Diario dell\'Erborista (abbonamento simulato)'**
  String get debugDiario;

  /// No description provided for @debugReset.
  ///
  /// In it, this message translates to:
  /// **'Azzera i progressi'**
  String get debugReset;

  /// No description provided for @debugResetConfirm.
  ///
  /// In it, this message translates to:
  /// **'Tocca di nuovo per cancellare tutto'**
  String get debugResetConfirm;

  /// No description provided for @debugResetDone.
  ///
  /// In it, this message translates to:
  /// **'Progressi azzerati'**
  String get debugResetDone;

  /// No description provided for @notEncounteredYet.
  ///
  /// In it, this message translates to:
  /// **'Non ancora Incontrata'**
  String get notEncounteredYet;

  /// No description provided for @desiderataAddShort.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get desiderataAddShort;

  /// No description provided for @simulateShort.
  ///
  /// In it, this message translates to:
  /// **'Simula'**
  String get simulateShort;

  /// No description provided for @liverySottobosco.
  ///
  /// In it, this message translates to:
  /// **'Sottobosco'**
  String get liverySottobosco;

  /// No description provided for @dayTimeDawn.
  ///
  /// In it, this message translates to:
  /// **'all\'alba'**
  String get dayTimeDawn;

  /// No description provided for @dayTimeDay.
  ///
  /// In it, this message translates to:
  /// **'di giorno'**
  String get dayTimeDay;

  /// No description provided for @dayTimeDusk.
  ///
  /// In it, this message translates to:
  /// **'al tramonto'**
  String get dayTimeDusk;

  /// No description provided for @dayTimeNight.
  ///
  /// In it, this message translates to:
  /// **'di notte'**
  String get dayTimeNight;

  /// No description provided for @liveryFeltro.
  ///
  /// In it, this message translates to:
  /// **'Feltro'**
  String get liveryFeltro;

  /// No description provided for @studyThemeProgress.
  ///
  /// In it, this message translates to:
  /// **'{theme} · {done} di {total}'**
  String studyThemeProgress(String theme, int done, int total);

  /// No description provided for @qOrderOf.
  ///
  /// In it, this message translates to:
  /// **'A quale ordine appartiene {name}?'**
  String qOrderOf(String name);

  /// No description provided for @qCommonnessOf.
  ///
  /// In it, this message translates to:
  /// **'Quanto è comune {name} in questa zona?'**
  String qCommonnessOf(String name);

  /// No description provided for @optionYes.
  ///
  /// In it, this message translates to:
  /// **'Sì'**
  String get optionYes;

  /// No description provided for @optionNo.
  ///
  /// In it, this message translates to:
  /// **'No'**
  String get optionNo;

  /// No description provided for @commonnessVeryCommon.
  ///
  /// In it, this message translates to:
  /// **'Tra le più comuni'**
  String get commonnessVeryCommon;

  /// No description provided for @commonnessCommon.
  ///
  /// In it, this message translates to:
  /// **'Comune'**
  String get commonnessCommon;

  /// No description provided for @commonnessUncommon.
  ///
  /// In it, this message translates to:
  /// **'Meno comune'**
  String get commonnessUncommon;

  /// No description provided for @commonnessRare.
  ///
  /// In it, this message translates to:
  /// **'Tra le meno osservate'**
  String get commonnessRare;

  /// No description provided for @factScientificName.
  ///
  /// In it, this message translates to:
  /// **'Il nome scientifico di {name} è {sci}: la prima parola è il genere, la seconda la specie.'**
  String factScientificName(String name, String sci);

  /// No description provided for @factCongeners.
  ///
  /// In it, this message translates to:
  /// **'Altre specie del genere {genus} in Italia: {names}.'**
  String factCongeners(String genus, String names);

  /// No description provided for @factOrder.
  ///
  /// In it, this message translates to:
  /// **'{name} appartiene all\'ordine {order}, di cui fa parte la famiglia {family}.'**
  String factOrder(String name, String order, String family);

  /// No description provided for @factWarning.
  ///
  /// In it, this message translates to:
  /// **'{name}: {warning}. Guardala e fotografala, non assaggiarla. Avviso da verificare.'**
  String factWarning(String name, String warning);

  /// No description provided for @factCommonness.
  ///
  /// In it, this message translates to:
  /// **'In questa zona {name} è: {commonness} (dalle osservazioni GBIF).'**
  String factCommonness(String name, String commonness);

  /// No description provided for @qGrowthFormOf.
  ///
  /// In it, this message translates to:
  /// **'Che forma ha {name}?'**
  String qGrowthFormOf(String name);

  /// No description provided for @qLifeCycleOf.
  ///
  /// In it, this message translates to:
  /// **'Quanto vive {name}?'**
  String qLifeCycleOf(String name);

  /// No description provided for @qSeedDispersalOf.
  ///
  /// In it, this message translates to:
  /// **'Come viaggiano i semi di {name}?'**
  String qSeedDispersalOf(String name);

  /// No description provided for @qOriginOf.
  ///
  /// In it, this message translates to:
  /// **'{name} è arrivata in Italia da fuori, portata dall\'uomo?'**
  String qOriginOf(String name);

  /// No description provided for @qLightOf.
  ///
  /// In it, this message translates to:
  /// **'Quanta luce ama {name}?'**
  String qLightOf(String name);

  /// No description provided for @qMoistureOf.
  ///
  /// In it, this message translates to:
  /// **'Che terreno preferisce {name}?'**
  String qMoistureOf(String name);

  /// No description provided for @growthTree.
  ///
  /// In it, this message translates to:
  /// **'Albero'**
  String get growthTree;

  /// No description provided for @growthShrub.
  ///
  /// In it, this message translates to:
  /// **'Arbusto'**
  String get growthShrub;

  /// No description provided for @growthHerb.
  ///
  /// In it, this message translates to:
  /// **'Erba'**
  String get growthHerb;

  /// No description provided for @growthClimber.
  ///
  /// In it, this message translates to:
  /// **'Rampicante'**
  String get growthClimber;

  /// No description provided for @cycleAnnual.
  ///
  /// In it, this message translates to:
  /// **'Un anno (annuale)'**
  String get cycleAnnual;

  /// No description provided for @cycleBiennial.
  ///
  /// In it, this message translates to:
  /// **'Due anni (biennale)'**
  String get cycleBiennial;

  /// No description provided for @cyclePerennial.
  ///
  /// In it, this message translates to:
  /// **'Molti anni (perenne)'**
  String get cyclePerennial;

  /// No description provided for @seedsEatenByAnimals.
  ///
  /// In it, this message translates to:
  /// **'Nei frutti mangiati dagli animali'**
  String get seedsEatenByAnimals;

  /// No description provided for @seedsStuckToAnimals.
  ///
  /// In it, this message translates to:
  /// **'Attaccati al pelo degli animali'**
  String get seedsStuckToAnimals;

  /// No description provided for @seedsHoardedByAnimals.
  ///
  /// In it, this message translates to:
  /// **'Nascosti dagli animali come scorte'**
  String get seedsHoardedByAnimals;

  /// No description provided for @seedsAnts.
  ///
  /// In it, this message translates to:
  /// **'Portati dalle formiche'**
  String get seedsAnts;

  /// No description provided for @seedsWind.
  ///
  /// In it, this message translates to:
  /// **'Col vento'**
  String get seedsWind;

  /// No description provided for @seedsWater.
  ///
  /// In it, this message translates to:
  /// **'Con l\'acqua'**
  String get seedsWater;

  /// No description provided for @seedsLaunched.
  ///
  /// In it, this message translates to:
  /// **'Lanciati dalla pianta'**
  String get seedsLaunched;

  /// No description provided for @seedsNearby.
  ///
  /// In it, this message translates to:
  /// **'Cadono vicino, senza aiuti'**
  String get seedsNearby;

  /// No description provided for @lightShade.
  ///
  /// In it, this message translates to:
  /// **'Ombra'**
  String get lightShade;

  /// No description provided for @lightHalfShade.
  ///
  /// In it, this message translates to:
  /// **'Mezz\'ombra'**
  String get lightHalfShade;

  /// No description provided for @lightSun.
  ///
  /// In it, this message translates to:
  /// **'Pieno sole'**
  String get lightSun;

  /// No description provided for @moistureDry.
  ///
  /// In it, this message translates to:
  /// **'Secco'**
  String get moistureDry;

  /// No description provided for @moistureFresh.
  ///
  /// In it, this message translates to:
  /// **'Fresco'**
  String get moistureFresh;

  /// No description provided for @moistureMoist.
  ///
  /// In it, this message translates to:
  /// **'Umido'**
  String get moistureMoist;

  /// No description provided for @factGrowthForm.
  ///
  /// In it, this message translates to:
  /// **'Forma di {name}: {form}.'**
  String factGrowthForm(String name, String form);

  /// No description provided for @factLifeCycle.
  ///
  /// In it, this message translates to:
  /// **'{name} vive {cycle}.'**
  String factLifeCycle(String name, String cycle);

  /// No description provided for @factSeedDispersal.
  ///
  /// In it, this message translates to:
  /// **'I semi di {name}: {modes}.'**
  String factSeedDispersal(String name, String modes);

  /// No description provided for @factOriginNative.
  ///
  /// In it, this message translates to:
  /// **'{name} è autoctona: in Italia cresce da sempre, senza l\'aiuto dell\'uomo.'**
  String factOriginNative(String name);

  /// No description provided for @factOriginIntroduced.
  ///
  /// In it, this message translates to:
  /// **'{name} è stata portata in Italia dall\'uomo: non è nata qui.'**
  String factOriginIntroduced(String name);

  /// No description provided for @factLight.
  ///
  /// In it, this message translates to:
  /// **'{name} ama: {light}.'**
  String factLight(String name, String light);

  /// No description provided for @factMoisture.
  ///
  /// In it, this message translates to:
  /// **'{name} preferisce un terreno {moisture}.'**
  String factMoisture(String name, String moisture);

  /// No description provided for @sourcesTraits.
  ///
  /// In it, this message translates to:
  /// **'Tratti: WCVP (Kew), EIVE 1.0, EuDiS, CC BY 4.0'**
  String get sourcesTraits;

  /// No description provided for @sectionTraits.
  ///
  /// In it, this message translates to:
  /// **'Com\'è e come vive'**
  String get sectionTraits;

  /// No description provided for @xpToCash.
  ///
  /// In it, this message translates to:
  /// **'{xp} PE da Incassare: si Incassano alla prima Essenza di ogni specie'**
  String xpToCash(int xp);

  /// No description provided for @speciesXpToCash.
  ///
  /// In it, this message translates to:
  /// **'{xp} PE da Incassare: Attingi la prima Essenza di questa specie.'**
  String speciesXpToCash(int xp);

  /// No description provided for @summaryXpToCash.
  ///
  /// In it, this message translates to:
  /// **'I PE dello studio di questa specie si Incassano quando ne Attingi la prima Essenza.'**
  String get summaryXpToCash;

  /// No description provided for @visStored.
  ///
  /// In it, this message translates to:
  /// **'Vis immagazzinate: {vis}'**
  String visStored(int vis);

  /// No description provided for @drawExhausted.
  ///
  /// In it, this message translates to:
  /// **'Esaurita: torna pronta domani'**
  String get drawExhausted;

  /// No description provided for @drawNeedsEncounter.
  ///
  /// In it, this message translates to:
  /// **'Per Attingere serve una Stazione: prima Incontrala'**
  String get drawNeedsEncounter;

  /// No description provided for @gradeCommon.
  ///
  /// In it, this message translates to:
  /// **'Comune'**
  String get gradeCommon;

  /// No description provided for @gradeUncommon.
  ///
  /// In it, this message translates to:
  /// **'Non comune'**
  String get gradeUncommon;

  /// No description provided for @gradeRare.
  ///
  /// In it, this message translates to:
  /// **'Rara'**
  String get gradeRare;

  /// No description provided for @gradeMythic.
  ///
  /// In it, this message translates to:
  /// **'Mitica'**
  String get gradeMythic;

  /// No description provided for @protectionEmiliaRomagna.
  ///
  /// In it, this message translates to:
  /// **'L.R. Emilia-Romagna 2/1977'**
  String get protectionEmiliaRomagna;

  /// No description provided for @protectionHabitats.
  ///
  /// In it, this message translates to:
  /// **'Direttiva Habitat, allegato {annex}'**
  String protectionHabitats(String annex);

  /// No description provided for @summaryRecipeLearned.
  ///
  /// In it, this message translates to:
  /// **'Hai imparato una Ricetta: {name}'**
  String summaryRecipeLearned(String name);

  /// No description provided for @debugGradePreview.
  ///
  /// In it, this message translates to:
  /// **'Anteprima dei Gradi'**
  String get debugGradePreview;

  /// No description provided for @debugGradeSampleName.
  ///
  /// In it, this message translates to:
  /// **'Elisir di Prova'**
  String get debugGradeSampleName;

  /// No description provided for @debugGradeSampleIngredient.
  ///
  /// In it, this message translates to:
  /// **'Erba d\'argento'**
  String get debugGradeSampleIngredient;

  /// No description provided for @debugGradeSampleEffect.
  ///
  /// In it, this message translates to:
  /// **'La prossima Raccolta con la Luna piena ha un Tratto in più (effetto di gioco).'**
  String get debugGradeSampleEffect;

  /// No description provided for @badgeEncountered.
  ///
  /// In it, this message translates to:
  /// **'Incontrata il'**
  String get badgeEncountered;

  /// No description provided for @badgeProtected.
  ///
  /// In it, this message translates to:
  /// **'Specie Protetta'**
  String get badgeProtected;

  /// No description provided for @legendTitle.
  ///
  /// In it, this message translates to:
  /// **'Legenda'**
  String get legendTitle;

  /// No description provided for @glossarySection.
  ///
  /// In it, this message translates to:
  /// **'Glossario'**
  String get glossarySection;

  /// No description provided for @legendGrades.
  ///
  /// In it, this message translates to:
  /// **'Gradi (Ricette, Pozioni, Bottino)'**
  String get legendGrades;

  /// No description provided for @legendBadges.
  ///
  /// In it, this message translates to:
  /// **'Bollini'**
  String get legendBadges;

  /// No description provided for @legendProtected.
  ///
  /// In it, this message translates to:
  /// **'Specie Protetta dalla legge: si guarda e si fotografa'**
  String get legendProtected;

  /// No description provided for @legendEncountered.
  ///
  /// In it, this message translates to:
  /// **'Specie Incontrata, con la data dell\'Incontro'**
  String get legendEncountered;

  /// No description provided for @legendXpToCash.
  ///
  /// In it, this message translates to:
  /// **'PE da Incassare alla prima Essenza della specie'**
  String get legendXpToCash;

  /// No description provided for @legendLevels.
  ///
  /// In it, this message translates to:
  /// **'Livelli di studio'**
  String get legendLevels;

  /// No description provided for @legendTraits.
  ///
  /// In it, this message translates to:
  /// **'Tratti delle Essenze'**
  String get legendTraits;

  /// No description provided for @glossProtettaTerm.
  ///
  /// In it, this message translates to:
  /// **'Protetta'**
  String get glossProtettaTerm;

  /// No description provided for @glossProtettaText.
  ///
  /// In it, this message translates to:
  /// **'Specie protetta dalla Direttiva Habitat o da una legge regionale. Si guarda e si fotografa: non si raccoglie, non si calpesta, si resta sul sentiero.'**
  String get glossProtettaText;

  /// No description provided for @glossEssenzaTerm.
  ///
  /// In it, this message translates to:
  /// **'Essenza'**
  String get glossEssenzaTerm;

  /// No description provided for @glossEssenzaText.
  ///
  /// In it, this message translates to:
  /// **'Ciò che Attingi da una Stazione: ha una Purezza, che cresce con la conoscenza della specie, e dei Tratti, dati dalle condizioni del momento.'**
  String get glossEssenzaText;

  /// No description provided for @glossVisTerm.
  ///
  /// In it, this message translates to:
  /// **'Vis'**
  String get glossVisTerm;

  /// No description provided for @glossVisText.
  ///
  /// In it, this message translates to:
  /// **'La linfa sottile delle piante: l\'energia che immagazzini a ogni Raccolta. Le Ricette ne chiedono una quantità per Ingrediente.'**
  String get glossVisText;

  /// No description provided for @glossPeDaIncassareTerm.
  ///
  /// In it, this message translates to:
  /// **'PE da Incassare'**
  String get glossPeDaIncassareTerm;

  /// No description provided for @glossPeDaIncassareText.
  ///
  /// In it, this message translates to:
  /// **'I Punti Esperienza dello studio di una specie che non hai ancora Attinto. Si Incassano alla prima Essenza di quella specie e da lì contano per il Rango.'**
  String get glossPeDaIncassareText;

  /// No description provided for @glossGradoTerm.
  ///
  /// In it, this message translates to:
  /// **'Grado'**
  String get glossGradoTerm;

  /// No description provided for @glossGradoText.
  ///
  /// In it, this message translates to:
  /// **'Comune, Non comune, Rara, Mitica: bianco, argento, oro, oro rosso. Vale per Ingredienti, Ricette, Pozioni e Bottino dell\'Esperienza.'**
  String get glossGradoText;

  /// No description provided for @glossBottinoTerm.
  ///
  /// In it, this message translates to:
  /// **'Bottino dell\'Esperienza'**
  String get glossBottinoTerm;

  /// No description provided for @glossBottinoText.
  ///
  /// In it, this message translates to:
  /// **'Il Bottino che si compra con i PE: scegli il grado e spendi il saldo; dentro c\'è una Tavola a sorpresa, spesso incompleta, o un componente di una che hai. Le Mitiche escono solo dal Bottino mitico.'**
  String get glossBottinoText;

  /// No description provided for @recipesEmpty.
  ///
  /// In it, this message translates to:
  /// **'Non conosci ancora nessuna Ricetta. Ogni pianta ha la sua Ricetta Comune: la impari superando il Livello 1 della specie, dalla Home o dall\'Erbario.'**
  String get recipesEmpty;

  /// No description provided for @viewAll.
  ///
  /// In it, this message translates to:
  /// **'Tutte'**
  String get viewAll;

  /// No description provided for @viewInSeason.
  ///
  /// In it, this message translates to:
  /// **'In stagione adesso'**
  String get viewInSeason;

  /// No description provided for @viewDesiderata.
  ///
  /// In it, this message translates to:
  /// **'Le mie Desiderata'**
  String get viewDesiderata;

  /// No description provided for @viewProtected.
  ///
  /// In it, this message translates to:
  /// **'Protette'**
  String get viewProtected;

  /// No description provided for @viewNew.
  ///
  /// In it, this message translates to:
  /// **'Nuova vista'**
  String get viewNew;

  /// No description provided for @viewName.
  ///
  /// In it, this message translates to:
  /// **'Nome della vista'**
  String get viewName;

  /// No description provided for @viewStatus.
  ///
  /// In it, this message translates to:
  /// **'Stato'**
  String get viewStatus;

  /// No description provided for @viewWhen.
  ///
  /// In it, this message translates to:
  /// **'Quando e come'**
  String get viewWhen;

  /// No description provided for @viewProtectedOnly.
  ///
  /// In it, this message translates to:
  /// **'Solo Protette'**
  String get viewProtectedOnly;

  /// No description provided for @viewBand.
  ///
  /// In it, this message translates to:
  /// **'Quota'**
  String get viewBand;

  /// No description provided for @viewForm.
  ///
  /// In it, this message translates to:
  /// **'Forma'**
  String get viewForm;

  /// No description provided for @viewFamily.
  ///
  /// In it, this message translates to:
  /// **'Famiglia'**
  String get viewFamily;

  /// No description provided for @viewSave.
  ///
  /// In it, this message translates to:
  /// **'Salva la vista'**
  String get viewSave;

  /// No description provided for @viewRemove.
  ///
  /// In it, this message translates to:
  /// **'Elimina la vista'**
  String get viewRemove;

  /// No description provided for @viewEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna specie in questa vista.'**
  String get viewEmpty;

  /// No description provided for @statusMet.
  ///
  /// In it, this message translates to:
  /// **'Incontrate'**
  String get statusMet;

  /// No description provided for @statusToFind.
  ///
  /// In it, this message translates to:
  /// **'Da trovare'**
  String get statusToFind;

  /// No description provided for @statusDesiderata.
  ///
  /// In it, this message translates to:
  /// **'Desiderata'**
  String get statusDesiderata;

  /// No description provided for @statusStudying.
  ///
  /// In it, this message translates to:
  /// **'In studio'**
  String get statusStudying;

  /// No description provided for @traitDawn.
  ///
  /// In it, this message translates to:
  /// **'🌄 Alba'**
  String get traitDawn;

  /// No description provided for @traitNewMoon.
  ///
  /// In it, this message translates to:
  /// **'🌑 Luna nuova'**
  String get traitNewMoon;

  /// No description provided for @traitWaxingMoon.
  ///
  /// In it, this message translates to:
  /// **'🌓 Luna crescente'**
  String get traitWaxingMoon;

  /// No description provided for @traitWaningMoon.
  ///
  /// In it, this message translates to:
  /// **'🌗 Luna calante'**
  String get traitWaningMoon;

  /// No description provided for @legendTraitsDaylight.
  ///
  /// In it, this message translates to:
  /// **'Luce del giorno'**
  String get legendTraitsDaylight;

  /// No description provided for @legendTraitsMoon.
  ///
  /// In it, this message translates to:
  /// **'Luna'**
  String get legendTraitsMoon;

  /// No description provided for @legendTraitsWeather.
  ///
  /// In it, this message translates to:
  /// **'Meteo'**
  String get legendTraitsWeather;

  /// No description provided for @traitWhenFrost.
  ///
  /// In it, this message translates to:
  /// **'Quando fa sotto zero: brina e ghiaccio.'**
  String get traitWhenFrost;

  /// No description provided for @traitWhenRain.
  ///
  /// In it, this message translates to:
  /// **'Mentre piove. Con il temporale la Raccolta è sospesa.'**
  String get traitWhenRain;

  /// No description provided for @traitWhenFog.
  ///
  /// In it, this message translates to:
  /// **'Quando c\'è nebbia.'**
  String get traitWhenFog;

  /// No description provided for @traitWhenSun.
  ///
  /// In it, this message translates to:
  /// **'Con il sole e poche nuvole.'**
  String get traitWhenSun;

  /// No description provided for @traitWhenMoon.
  ///
  /// In it, this message translates to:
  /// **'Tutto il giorno della luna piena: non serve uscire di notte.'**
  String get traitWhenMoon;

  /// No description provided for @traitWhenDew.
  ///
  /// In it, this message translates to:
  /// **'Dall\'alba a circa due ore dopo, se la notte è stata fresca e serena: l\'erba è ancora bagnata.'**
  String get traitWhenDew;

  /// No description provided for @traitWhenDusk.
  ///
  /// In it, this message translates to:
  /// **'Da circa un\'ora prima del tramonto fino al tramonto, mai a buio fatto.'**
  String get traitWhenDusk;

  /// No description provided for @traitWhenDawn.
  ///
  /// In it, this message translates to:
  /// **'Dalle prime luci a circa un\'ora dopo il sorgere del sole.'**
  String get traitWhenDawn;

  /// No description provided for @traitWhenNewMoon.
  ///
  /// In it, this message translates to:
  /// **'Tutto il giorno della luna nuova: non serve uscire di notte.'**
  String get traitWhenNewMoon;

  /// No description provided for @traitWhenWaxingMoon.
  ///
  /// In it, this message translates to:
  /// **'Tutti i giorni in cui la luna cresce, tra la nuova e la piena: non serve uscire di notte.'**
  String get traitWhenWaxingMoon;

  /// No description provided for @traitWhenWaningMoon.
  ///
  /// In it, this message translates to:
  /// **'Tutti i giorni in cui la luna cala, tra la piena e la nuova: non serve uscire di notte.'**
  String get traitWhenWaningMoon;

  /// No description provided for @recipeBookTitle.
  ///
  /// In it, this message translates to:
  /// **'Ricettario'**
  String get recipeBookTitle;

  /// No description provided for @recipeBookPlates.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 Tavola} other{{count} Tavole}}'**
  String recipeBookPlates(int count);

  /// No description provided for @recipeBookPagesSummary.
  ///
  /// In it, this message translates to:
  /// **'{pages, plural, =1{1 Pagina} other{{pages} Pagine}} su {total} · {complete, plural, =1{1 completa} other{{complete} complete}}'**
  String recipeBookPagesSummary(int pages, int total, int complete);

  /// No description provided for @recipeBookPageCount.
  ///
  /// In it, this message translates to:
  /// **'{known, plural, =1{1 Tavola} other{{known} Tavole}} su {total}'**
  String recipeBookPageCount(int known, int total);

  /// No description provided for @recipeBookFavouredTraits.
  ///
  /// In it, this message translates to:
  /// **'Tratti d\'elezione'**
  String get recipeBookFavouredTraits;

  /// No description provided for @recipeBookVocation.
  ///
  /// In it, this message translates to:
  /// **'Vocazione'**
  String get recipeBookVocation;

  /// No description provided for @recipeBookMissingPlate.
  ///
  /// In it, this message translates to:
  /// **'Tavola da trovare'**
  String get recipeBookMissingPlate;

  /// No description provided for @recipeBookSwipeHint.
  ///
  /// In it, this message translates to:
  /// **'Scorri per sfogliare le Pagine'**
  String get recipeBookSwipeHint;

  /// No description provided for @recipeBookSpeciesLink.
  ///
  /// In it, this message translates to:
  /// **'Ricettario · {known, plural, =1{1 Tavola} other{{known} Tavole}} su {total}'**
  String recipeBookSpeciesLink(int known, int total);

  /// No description provided for @recipeMonths.
  ///
  /// In it, this message translates to:
  /// **'Quando si può fare'**
  String get recipeMonths;

  /// No description provided for @recipeNever.
  ///
  /// In it, this message translates to:
  /// **'Mai: gli ingredienti non si incontrano negli stessi mesi'**
  String get recipeNever;

  /// No description provided for @recipeEffect.
  ///
  /// In it, this message translates to:
  /// **'Effetto'**
  String get recipeEffect;

  /// No description provided for @effectRegrowth.
  ///
  /// In it, this message translates to:
  /// **'Ricrescita'**
  String get effectRegrowth;

  /// No description provided for @effectClarity.
  ///
  /// In it, this message translates to:
  /// **'Limpidezza'**
  String get effectClarity;

  /// No description provided for @effectOmen.
  ///
  /// In it, this message translates to:
  /// **'Presagio'**
  String get effectOmen;

  /// No description provided for @effectAbundance.
  ///
  /// In it, this message translates to:
  /// **'Abbondanza'**
  String get effectAbundance;

  /// No description provided for @effectRegrowthText.
  ///
  /// In it, this message translates to:
  /// **'Per 7 giorni le specie tornano pronte prima, fino a 12 ore dopo (effetto di gioco).'**
  String get effectRegrowthText;

  /// No description provided for @effectClarityText.
  ///
  /// In it, this message translates to:
  /// **'Per 7 giorni purezza in più a ogni Essenza (effetto di gioco).'**
  String get effectClarityText;

  /// No description provided for @effectOmenText.
  ///
  /// In it, this message translates to:
  /// **'Per 7 giorni un\'Essenza senza tratti può prendere il tratto d\'elezione della pianta (effetto di gioco).'**
  String get effectOmenText;

  /// No description provided for @effectAbundanceText.
  ///
  /// In it, this message translates to:
  /// **'Per 7 giorni Vis in più a ogni Essenza, fino a +50 % (effetto di gioco).'**
  String get effectAbundanceText;

  /// No description provided for @mythicNumber.
  ///
  /// In it, this message translates to:
  /// **'Tavola n. {number}'**
  String mythicNumber(String number);

  /// No description provided for @mythicToFind.
  ///
  /// In it, this message translates to:
  /// **'Da trovare'**
  String get mythicToFind;

  /// No description provided for @mythicWindow.
  ///
  /// In it, this message translates to:
  /// **'Solo dal {from} al {to}'**
  String mythicWindow(String from, String to);

  /// No description provided for @mythicAllYear.
  ///
  /// In it, this message translates to:
  /// **'Tutto l\'anno'**
  String get mythicAllYear;

  /// No description provided for @mythicsIntro.
  ///
  /// In it, this message translates to:
  /// **'Le Mitiche della Zona: scritte a mano, legate ai suoi luoghi e alle sue feste. Si trovano solo nel Bottino dell\'Esperienza mitico.'**
  String get mythicsIntro;

  /// No description provided for @recipeBookMythicsRow.
  ///
  /// In it, this message translates to:
  /// **'Mitiche · {zone}'**
  String recipeBookMythicsRow(String zone);

  /// No description provided for @recipeBookMythicsCount.
  ///
  /// In it, this message translates to:
  /// **'{known} su {total}'**
  String recipeBookMythicsCount(int known, int total);

  /// No description provided for @debugSimulateRecipeBook.
  ///
  /// In it, this message translates to:
  /// **'Simula un Ricettario'**
  String get debugSimulateRecipeBook;

  /// No description provided for @debugSimulateRecipeBookDone.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 Tavola aggiunta} other{{count} Tavole aggiunte}} al Ricettario'**
  String debugSimulateRecipeBookDone(int count);

  /// No description provided for @troveTitle.
  ///
  /// In it, this message translates to:
  /// **'Bottino dell\'Esperienza'**
  String get troveTitle;

  /// No description provided for @navTrove.
  ///
  /// In it, this message translates to:
  /// **'Bottino'**
  String get navTrove;

  /// No description provided for @labBalance.
  ///
  /// In it, this message translates to:
  /// **'Saldo'**
  String get labBalance;

  /// No description provided for @labBalanceXp.
  ///
  /// In it, this message translates to:
  /// **'{xp} PE da spendere'**
  String labBalanceXp(int xp);

  /// No description provided for @labTrovesLeft.
  ///
  /// In it, this message translates to:
  /// **'{left} su {total} oggi'**
  String labTrovesLeft(int left, int total);

  /// No description provided for @troveName.
  ///
  /// In it, this message translates to:
  /// **'Bottino dell\'Esperienza · {grade}'**
  String troveName(String grade);

  /// No description provided for @troveGradeCommon.
  ///
  /// In it, this message translates to:
  /// **'comune'**
  String get troveGradeCommon;

  /// No description provided for @troveGradeUncommon.
  ///
  /// In it, this message translates to:
  /// **'non comune'**
  String get troveGradeUncommon;

  /// No description provided for @troveGradeRare.
  ///
  /// In it, this message translates to:
  /// **'raro'**
  String get troveGradeRare;

  /// No description provided for @troveGradeMythic.
  ///
  /// In it, this message translates to:
  /// **'mitico'**
  String get troveGradeMythic;

  /// No description provided for @troveContentsCommon.
  ///
  /// In it, this message translates to:
  /// **'Quasi sempre una Comune, a volte una Non comune'**
  String get troveContentsCommon;

  /// No description provided for @troveContentsUncommon.
  ///
  /// In it, this message translates to:
  /// **'Per lo più Non comuni, a volte una Comune o una Rara'**
  String get troveContentsUncommon;

  /// No description provided for @troveContentsRare.
  ///
  /// In it, this message translates to:
  /// **'Per lo più Rare, a volte una Non comune'**
  String get troveContentsRare;

  /// No description provided for @troveContentsMythic.
  ///
  /// In it, this message translates to:
  /// **'Una Rara o una Mitica, metà e metà'**
  String get troveContentsMythic;

  /// No description provided for @troveSpend.
  ///
  /// In it, this message translates to:
  /// **'Spendi {cost} PE'**
  String troveSpend(int cost);

  /// No description provided for @troveNeedXp.
  ///
  /// In it, this message translates to:
  /// **'Ti mancano {xp} PE'**
  String troveNeedXp(int xp);

  /// No description provided for @troveCostMissing.
  ///
  /// In it, this message translates to:
  /// **'Costa {cost} PE: te ne mancano {xp}'**
  String troveCostMissing(int cost, int xp);

  /// No description provided for @troveDailyLimit.
  ///
  /// In it, this message translates to:
  /// **'Per oggi basta: {total} Bottino dell\'Esperienza al giorno. Torna domani.'**
  String troveDailyLimit(int total);

  /// No description provided for @troveRules.
  ///
  /// In it, this message translates to:
  /// **'Le Tavole Non comuni, Rare e Mitiche escono incomplete: i componenti che mancano si trovano in altri Bottino dell\'Esperienza. Al primo comune e al primo non comune, in regalo una Tavola del grado sopra. Le Mitiche escono solo dal Bottino dell\'Esperienza mitico.'**
  String get troveRules;

  /// No description provided for @labIncomplete.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 Tavola incompleta} other{{count} Tavole incomplete}}'**
  String labIncomplete(int count);

  /// No description provided for @labRecycled.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 riciclato} other{{count} riciclati}}'**
  String labRecycled(int count);

  /// No description provided for @welcomeGiftTitle.
  ///
  /// In it, this message translates to:
  /// **'Ehi, c\'è un regalo per te'**
  String get welcomeGiftTitle;

  /// No description provided for @welcomeGiftBody.
  ///
  /// In it, this message translates to:
  /// **'Il tuo primo Bottino dell\'Esperienza · raro a prezzo di favore: {price} PE invece di {full}.'**
  String welcomeGiftBody(int full, int price);

  /// No description provided for @welcomeGiftWaiting.
  ///
  /// In it, this message translates to:
  /// **'Si riscatta dopo un\'Essenza: esci e attingi da una stazione.'**
  String get welcomeGiftWaiting;

  /// No description provided for @welcomeGiftRedeem.
  ///
  /// In it, this message translates to:
  /// **'Riscatta · {price} PE'**
  String welcomeGiftRedeem(int price);

  /// No description provided for @troveTapToTurn.
  ///
  /// In it, this message translates to:
  /// **'Tocca le Tavole per girarle'**
  String get troveTapToTurn;

  /// No description provided for @troveFindNew.
  ///
  /// In it, this message translates to:
  /// **'Nuova Tavola'**
  String get troveFindNew;

  /// No description provided for @troveFindIncomplete.
  ///
  /// In it, this message translates to:
  /// **'Nuova Tavola · {count, plural, =1{manca 1 componente} other{mancano {count} componenti}}'**
  String troveFindIncomplete(int count);

  /// No description provided for @troveFindPiece.
  ///
  /// In it, this message translates to:
  /// **'Un componente trovato'**
  String get troveFindPiece;

  /// No description provided for @troveFindCompleted.
  ///
  /// In it, this message translates to:
  /// **'Tavola completata'**
  String get troveFindCompleted;

  /// No description provided for @troveFindRecycled.
  ///
  /// In it, this message translates to:
  /// **'Doppione: 1 riciclato {grade}'**
  String troveFindRecycled(String grade);

  /// No description provided for @troveFindTaste.
  ///
  /// In it, this message translates to:
  /// **'Assaggio del grado sopra'**
  String get troveFindTaste;

  /// No description provided for @troveNothing.
  ///
  /// In it, this message translates to:
  /// **'Questa volta non è uscito niente di nuovo.'**
  String get troveNothing;

  /// No description provided for @troveDone.
  ///
  /// In it, this message translates to:
  /// **'Fatto'**
  String get troveDone;

  /// No description provided for @recipeMissingPieces.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Manca 1 componente} other{Mancano {count} componenti}}'**
  String recipeMissingPieces(int count);

  /// No description provided for @recipeEffectUnknown.
  ///
  /// In it, this message translates to:
  /// **'Da scoprire: manca un componente del nome.'**
  String get recipeEffectUnknown;

  /// No description provided for @debugGrantXp.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi 5.000 PE'**
  String get debugGrantXp;

  /// No description provided for @recycleTitle.
  ///
  /// In it, this message translates to:
  /// **'Riciclo'**
  String get recycleTitle;

  /// No description provided for @recycleIntro.
  ///
  /// In it, this message translates to:
  /// **'Ogni doppione è un riciclato del suo grado. 3 riciclati fanno un componente dello stesso grado, 9 uno del grado sopra, per una Tavola incompleta a tua scelta. Costa un po\' di Vis.'**
  String get recycleIntro;

  /// No description provided for @recycleVis.
  ///
  /// In it, this message translates to:
  /// **'{vis} Vis da spendere'**
  String recycleVis(int vis);

  /// No description provided for @recycleUse.
  ///
  /// In it, this message translates to:
  /// **'{count} riciclati {grade} · {vis} Vis'**
  String recycleUse(int count, String grade, int vis);

  /// No description provided for @recycleNeedVis.
  ///
  /// In it, this message translates to:
  /// **'Servono {vis} Vis'**
  String recycleNeedVis(int vis);

  /// No description provided for @recycleNothing.
  ///
  /// In it, this message translates to:
  /// **'Con i riciclati che hai non completi ancora nessun componente.'**
  String get recycleNothing;

  /// No description provided for @recycleDone.
  ///
  /// In it, this message translates to:
  /// **'Componente aggiunto: {name}'**
  String recycleDone(String name);

  /// No description provided for @recycleCompleted.
  ///
  /// In it, this message translates to:
  /// **'Tavola completata: {name}'**
  String recycleCompleted(String name);

  /// No description provided for @recycledGradeCommon.
  ///
  /// In it, this message translates to:
  /// **'comuni'**
  String get recycledGradeCommon;

  /// No description provided for @recycledGradeUncommon.
  ///
  /// In it, this message translates to:
  /// **'non comuni'**
  String get recycledGradeUncommon;

  /// No description provided for @recycledGradeRare.
  ///
  /// In it, this message translates to:
  /// **'rari'**
  String get recycledGradeRare;

  /// No description provided for @recycledGradeMythic.
  ///
  /// In it, this message translates to:
  /// **'mitici'**
  String get recycledGradeMythic;

  /// No description provided for @labTitle.
  ///
  /// In it, this message translates to:
  /// **'Laboratorio'**
  String get labTitle;

  /// No description provided for @navLaboratory.
  ///
  /// In it, this message translates to:
  /// **'Laboratorio'**
  String get navLaboratory;

  /// No description provided for @pantryTitle.
  ///
  /// In it, this message translates to:
  /// **'Dispensa'**
  String get pantryTitle;

  /// No description provided for @pantryEssences.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 Essenza} other{{count} Essenze}}'**
  String pantryEssences(int count);

  /// No description provided for @pantrySpeciesSummary.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 Essenza} other{{count} Essenze}} · {vis} Vis'**
  String pantrySpeciesSummary(int count, int vis);

  /// No description provided for @pantryPurity.
  ///
  /// In it, this message translates to:
  /// **'Purezza {percent} %'**
  String pantryPurity(int percent);

  /// No description provided for @pantryVis.
  ///
  /// In it, this message translates to:
  /// **'{vis} Vis'**
  String pantryVis(int vis);

  /// No description provided for @pantryNoTraits.
  ///
  /// In it, this message translates to:
  /// **'Nessun tratto'**
  String get pantryNoTraits;

  /// No description provided for @pantryEmpty.
  ///
  /// In it, this message translates to:
  /// **'La Dispensa è vuota: le Essenze che attingi dalle stazioni restano qui, con i loro tratti, la purezza e le Vis. Per ora si attinge con \"Simula attingere\" nella scheda della specie.'**
  String get pantryEmpty;

  /// No description provided for @debugSimulatePantry.
  ///
  /// In it, this message translates to:
  /// **'Simula una Dispensa'**
  String get debugSimulatePantry;

  /// No description provided for @debugSimulatePantryDone.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 Essenza aggiunta} other{{count} Essenze aggiunte}} alla Dispensa'**
  String debugSimulatePantryDone(int count);

  /// No description provided for @labTabReady.
  ///
  /// In it, this message translates to:
  /// **'Ricette pronte'**
  String get labTabReady;

  /// No description provided for @labTabShelf.
  ///
  /// In it, this message translates to:
  /// **'Scaffale'**
  String get labTabShelf;

  /// No description provided for @readyCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 pronta} other{{count} pronte}}'**
  String readyCount(int count);

  /// No description provided for @shelfCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 pozione} other{{count} pozioni}}'**
  String shelfCount(int count);

  /// No description provided for @readySection.
  ///
  /// In it, this message translates to:
  /// **'Pronte da preparare'**
  String get readySection;

  /// No description provided for @readyAlmost.
  ///
  /// In it, this message translates to:
  /// **'Ti manca poco'**
  String get readyAlmost;

  /// No description provided for @readyOthers.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Un\'altra ricetta chiede} other{Altre {count} ricette chiedono}} più Essenze: le trovi nel Ricettario.'**
  String readyOthers(int count);

  /// No description provided for @readyEmpty.
  ///
  /// In it, this message translates to:
  /// **'Non conosci ancora ricette da preparare: le Comuni si imparano studiando, le altre nel Bottino dell\'Esperienza.'**
  String get readyEmpty;

  /// No description provided for @readyAnyPlant.
  ///
  /// In it, this message translates to:
  /// **'una pianta a scelta'**
  String get readyAnyPlant;

  /// No description provided for @brewButton.
  ///
  /// In it, this message translates to:
  /// **'Prepara'**
  String get brewButton;

  /// No description provided for @brewChooseFree.
  ///
  /// In it, this message translates to:
  /// **'Scegli la pianta dello slot libero'**
  String get brewChooseFree;

  /// No description provided for @brewChooseFreeHint.
  ///
  /// In it, this message translates to:
  /// **'Dà alla pozione il suo Tocco.'**
  String get brewChooseFreeHint;

  /// No description provided for @brewFreeOption.
  ///
  /// In it, this message translates to:
  /// **'{vis} Vis'**
  String brewFreeOption(int vis);

  /// No description provided for @potionTitle.
  ///
  /// In it, this message translates to:
  /// **'Pozione'**
  String get potionTitle;

  /// No description provided for @potionPotency.
  ///
  /// In it, this message translates to:
  /// **'Potenza {potency}'**
  String potionPotency(int potency);

  /// No description provided for @potionTouch.
  ///
  /// In it, this message translates to:
  /// **'Tocco: {touch}'**
  String potionTouch(String touch);

  /// No description provided for @potionFirstBonus.
  ///
  /// In it, this message translates to:
  /// **'Prima pozione di questa ricetta: +{xp} PE'**
  String potionFirstBonus(int xp);

  /// No description provided for @potionSpoiledTitle.
  ///
  /// In it, this message translates to:
  /// **'La pozione si è guastata'**
  String get potionSpoiledTitle;

  /// No description provided for @potionSpoiledText.
  ///
  /// In it, this message translates to:
  /// **'{name}: pianta tossica. In una ricetta da bere guasta la pozione: le Vis sono perse, ma ora lo sai.'**
  String potionSpoiledText(String name);

  /// No description provided for @shelfEmpty.
  ///
  /// In it, this message translates to:
  /// **'Lo Scaffale è vuoto: le pozioni che prepari restano qui.'**
  String get shelfEmpty;

  /// No description provided for @recipeBestPotency.
  ///
  /// In it, this message translates to:
  /// **'Potenza migliore: {potency}'**
  String recipeBestPotency(int potency);

  /// No description provided for @readyMissingVis.
  ///
  /// In it, this message translates to:
  /// **'Ti mancano {vis} Vis'**
  String readyMissingVis(int vis);

  /// No description provided for @shelfUse.
  ///
  /// In it, this message translates to:
  /// **'Usa'**
  String get shelfUse;

  /// No description provided for @shelfHint.
  ///
  /// In it, this message translates to:
  /// **'Tienila per la collezione o usala: l\'effetto vale 7 giorni, con la forza della sua potenza; il Tocco aggiunge un piccolo effetto in più.'**
  String get shelfHint;

  /// No description provided for @shelfActive.
  ///
  /// In it, this message translates to:
  /// **'Effetti in corso'**
  String get shelfActive;

  /// No description provided for @shelfActiveLine.
  ///
  /// In it, this message translates to:
  /// **'{effect} · forza {strength} · fino al {date}'**
  String shelfActiveLine(String effect, int strength, String date);

  /// No description provided for @shelfUsed.
  ///
  /// In it, this message translates to:
  /// **'{effect} per 7 giorni'**
  String shelfUsed(String effect);

  /// No description provided for @glossTavolaTerm.
  ///
  /// In it, this message translates to:
  /// **'Tavola'**
  String get glossTavolaTerm;

  /// No description provided for @glossTavolaText.
  ///
  /// In it, this message translates to:
  /// **'Una ricetta nel Ricettario, come le tavole illustrate degli erbari: \"1 Tavola su 3\". Nella Pagina di una pianta le Tavole che non hai sono slot vuoti con il cerchietto del grado.'**
  String get glossTavolaText;

  /// No description provided for @glossLaboratorioTerm.
  ///
  /// In it, this message translates to:
  /// **'Laboratorio'**
  String get glossLaboratorioTerm;

  /// No description provided for @glossLaboratorioText.
  ///
  /// In it, this message translates to:
  /// **'La tua base, il capanno-serra ai margini del bosco: dentro si lavora, con Ricettario, Dispensa, Ricette pronte e Scaffale.'**
  String get glossLaboratorioText;

  /// No description provided for @glossRicettarioTerm.
  ///
  /// In it, this message translates to:
  /// **'Ricettario'**
  String get glossRicettarioTerm;

  /// No description provided for @glossRicettarioText.
  ///
  /// In it, this message translates to:
  /// **'La collezione delle Tavole, una per paese: una Pagina per pianta e, in cima, le Mitiche della Zona, numerate.'**
  String get glossRicettarioText;

  /// No description provided for @glossComponenteTerm.
  ///
  /// In it, this message translates to:
  /// **'Componente'**
  String get glossComponenteTerm;

  /// No description provided for @glossComponenteText.
  ///
  /// In it, this message translates to:
  /// **'Un pezzo del nome di una Tavola incompleta (\"Tintura di Eranthis Brinata del…\"): le Non comuni, Rare e Mitiche escono dal Bottino dell\'Esperienza con dei componenti da trovare.'**
  String get glossComponenteText;

  /// No description provided for @glossRiciclatoTerm.
  ///
  /// In it, this message translates to:
  /// **'Riciclato'**
  String get glossRiciclatoTerm;

  /// No description provided for @glossRiciclatoText.
  ///
  /// In it, this message translates to:
  /// **'Un doppione uscito dal Bottino dell\'Esperienza: 3 riciclati di un grado fanno un componente dello stesso grado, 9 uno del grado sopra, con un po\' di Vis.'**
  String get glossRiciclatoText;

  /// No description provided for @glossDispensaTerm.
  ///
  /// In it, this message translates to:
  /// **'Dispensa'**
  String get glossDispensaTerm;

  /// No description provided for @glossDispensaText.
  ///
  /// In it, this message translates to:
  /// **'Le Essenze attinte, ognuna con i suoi tratti, la purezza (dal livello di studio della pianta quando l\'hai attinta) e le sue Vis.'**
  String get glossDispensaText;

  /// No description provided for @glossRicettePronteTerm.
  ///
  /// In it, this message translates to:
  /// **'Ricette pronte'**
  String get glossRicettePronteTerm;

  /// No description provided for @glossRicettePronteText.
  ///
  /// In it, this message translates to:
  /// **'Le ricette che puoi preparare adesso con la Dispensa, e quelle a cui manca poco, con cosa manca.'**
  String get glossRicettePronteText;

  /// No description provided for @glossPozioneTerm.
  ///
  /// In it, this message translates to:
  /// **'Pozione'**
  String get glossPozioneTerm;

  /// No description provided for @glossPozioneText.
  ///
  /// In it, this message translates to:
  /// **'Si prepara da una ricetta con le Vis delle Essenze. Ha una potenza da 1 a 10, che viene soprattutto dalla purezza: più conosci le piante, più è potente. Si tiene sullo Scaffale o si usa.'**
  String get glossPozioneText;

  /// No description provided for @glossToccoTerm.
  ///
  /// In it, this message translates to:
  /// **'Tocco'**
  String get glossToccoTerm;

  /// No description provided for @glossToccoText.
  ///
  /// In it, this message translates to:
  /// **'L\'aggettivo che la pianta dello slot libero dà alla pozione (Rigogliosa, Limpida, Presaga, Copiosa): quando la usi, aggiunge un piccolo effetto.'**
  String get glossToccoText;

  /// No description provided for @glossPozioneGuastataTerm.
  ///
  /// In it, this message translates to:
  /// **'Pozione guastata'**
  String get glossPozioneGuastataTerm;

  /// No description provided for @glossPozioneGuastataText.
  ///
  /// In it, this message translates to:
  /// **'Una pozione da bere con una pianta tossica nello slot libero: le Vis sono perse, ma impari che la pianta è tossica.'**
  String get glossPozioneGuastataText;

  /// No description provided for @glossScaffaleTerm.
  ///
  /// In it, this message translates to:
  /// **'Scaffale'**
  String get glossScaffaleTerm;

  /// No description provided for @glossScaffaleText.
  ///
  /// In it, this message translates to:
  /// **'Le pozioni che hai: tienile per la collezione o usale. L\'effetto vale 7 giorni, con la forza della potenza.'**
  String get glossScaffaleText;

  /// No description provided for @legendPotions.
  ///
  /// In it, this message translates to:
  /// **'Pozioni'**
  String get legendPotions;

  /// No description provided for @legendVessel.
  ///
  /// In it, this message translates to:
  /// **'Il recipiente dice la base della ricetta (Infuso, Tintura, Filtro…), il colore del liquido i tratti: uno strato per tratto. L\'icona in alto a destra è l\'effetto.'**
  String get legendVessel;

  /// No description provided for @viewMet.
  ///
  /// In it, this message translates to:
  /// **'Incontrate'**
  String get viewMet;

  /// No description provided for @erbarioSpecies.
  ///
  /// In it, this message translates to:
  /// **'Specie'**
  String get erbarioSpecies;

  /// No description provided for @tipOfDayTitle.
  ///
  /// In it, this message translates to:
  /// **'Consiglio del giorno'**
  String get tipOfDayTitle;

  /// No description provided for @tip01.
  ///
  /// In it, this message translates to:
  /// **'Studiando una pianta, le sue Essenze diventano più pure: dal 40 % senza studio al 100 % con la Maestria.'**
  String get tip01;

  /// No description provided for @tip02.
  ///
  /// In it, this message translates to:
  /// **'La purezza delle Essenze decide gran parte della Potenza delle pozioni: più conosci le piante, più sono potenti.'**
  String get tip02;

  /// No description provided for @tip03.
  ///
  /// In it, this message translates to:
  /// **'Le Comuni si imparano studiando: superato il livello 1 di una specie, la sua Comune è nel Ricettario.'**
  String get tip03;

  /// No description provided for @tip04.
  ///
  /// In it, this message translates to:
  /// **'Nel Bottino dell\'Esperienza le Tavole Non comuni, Rare e Mitiche escono incomplete: i Componenti che mancano si trovano in altri Bottino dell\'Esperienza.'**
  String get tip04;

  /// No description provided for @tip05.
  ///
  /// In it, this message translates to:
  /// **'Le Mitiche escono solo dal Bottino dell\'Esperienza mitico.'**
  String get tip05;

  /// No description provided for @tip06.
  ///
  /// In it, this message translates to:
  /// **'I doppioni del Bottino dell\'Esperienza diventano Riciclati: 3 fanno un Componente dello stesso grado, 9 uno del grado sopra.'**
  String get tip06;

  /// No description provided for @tip07.
  ///
  /// In it, this message translates to:
  /// **'Il Riciclo spende prima le Essenze meno preziose: quelle con i Tratti restano per le ricette.'**
  String get tip07;

  /// No description provided for @tip08.
  ///
  /// In it, this message translates to:
  /// **'Nello slot libero di una ricetta metti la pianta che vuoi: dà alla pozione il suo Tocco.'**
  String get tip08;

  /// No description provided for @tip09.
  ///
  /// In it, this message translates to:
  /// **'Attenzione alle piante tossiche nello slot libero di una ricetta da bere: la pozione si guasta.'**
  String get tip09;

  /// No description provided for @tip10.
  ///
  /// In it, this message translates to:
  /// **'Le Ricette pronte del Laboratorio dicono che cosa ti manca: è la lista per la prossima uscita.'**
  String get tip10;

  /// No description provided for @tip11.
  ///
  /// In it, this message translates to:
  /// **'Usare una pozione dà il suo effetto per 7 giorni, con la forza della sua Potenza.'**
  String get tip11;

  /// No description provided for @tip12.
  ///
  /// In it, this message translates to:
  /// **'I Tratti dicono in che condizioni hai attinto un\'Essenza; il nome di una ricetta li ricorda: \"Plenilunare\" vuole la Luna piena.'**
  String get tip12;

  /// No description provided for @tip13.
  ///
  /// In it, this message translates to:
  /// **'I PE dello studio restano da Incassare finché non attingi la prima Essenza di quella specie.'**
  String get tip13;

  /// No description provided for @tip14.
  ///
  /// In it, this message translates to:
  /// **'Nella Legenda (Impostazioni → Legenda e glossario) trovi il significato di simboli e colori.'**
  String get tip14;

  /// No description provided for @tip15.
  ///
  /// In it, this message translates to:
  /// **'\"Raccogliere\" nel gioco vuol dire fotografare: le piante restano dove sono.'**
  String get tip15;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
