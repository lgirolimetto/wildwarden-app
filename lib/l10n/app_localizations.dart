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
  /// **'Essenze Attinte: {done}/{total} · Qualia diverse: {traits}/{needed}'**
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
  /// **'Nessuna Qualia'**
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
  /// **'☀️ Sole'**
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
  /// **'Negli erbari e tra i collezionisti, l\'elenco degli esemplari che si desidera trovare. Qui sono le specie che hai scelto di cercare, quante vuoi.'**
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
  /// **'Qualia'**
  String get glossTrattoTerm;

  /// No description provided for @glossTrattoText.
  ///
  /// In it, this message translates to:
  /// **'Una condizione del momento in cui Attingi un\'Essenza (Sole, Luna piena, Pioggia, Nebbia, Rugiada…): un\'Essenza le porta tutte. Le Ricette chiedono Qualia diverse: la stessa pianta in giorni diversi dà Essenze diverse. Si dice «una Qualia», «le Qualia», come la Vis.'**
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
  /// **'L\'ultimo Livello di una specie: richiede di ricordare ciò che hai imparato a distanza di giorni e di aver Attinto la specie sul campo in condizioni diverse. Va mantenuta: dopo 30 giorni senza domande della specie si assopisce e si risveglia con un mini-quiz.'**
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
  /// **'La prossima volta che attingi con la Luna piena ha una Qualia in più (effetto di gioco).'**
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
  /// **'Qualia delle Essenze'**
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
  /// **'Ciò che Attingi da una Stazione: ha le sue Vis, una Purezza, che cresce con la conoscenza della specie, e delle Qualia, date dalle condizioni del momento.'**
  String get glossEssenzaText;

  /// No description provided for @glossVisTerm.
  ///
  /// In it, this message translates to:
  /// **'Vis'**
  String get glossVisTerm;

  /// No description provided for @glossVisText.
  ///
  /// In it, this message translates to:
  /// **'La linfa sottile delle piante: l\'energia che immagazzini ogni volta che attingi. Le Ricette ne chiedono una quantità per Ingrediente.'**
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
  /// **'Mentre piove. Con il temporale non si attinge.'**
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
  /// **'Affinità'**
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
  /// **'Per 7 giorni un\'Essenza senza Qualia può prendere la prima Affinità della pianta (effetto di gioco).'**
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
  /// **'Si riscatta dopo un\'Essenza: esci e Attingi da una Stazione.'**
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
  /// **'{count, plural, =1{Non si conosce ancora 1 Componente} other{Non si conoscono ancora {count} Componenti}}'**
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

  /// No description provided for @pantryEmpty.
  ///
  /// In it, this message translates to:
  /// **'La Dispensa è vuota: le Essenze che Attingi dalle Stazioni restano qui, con le loro Vis, la purezza e le Qualia. Per ora si Attinge con \"Simula Attingere\" nella scheda della specie.'**
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

  /// No description provided for @labTabShelf.
  ///
  /// In it, this message translates to:
  /// **'Scaffale'**
  String get labTabShelf;

  /// No description provided for @shelfCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 pozione} other{{count} pozioni}}'**
  String shelfCount(int count);

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

  /// No description provided for @recipeReady.
  ///
  /// In it, this message translates to:
  /// **'Preparabile'**
  String get recipeReady;

  /// No description provided for @recipeBookOnlyReady.
  ///
  /// In it, this message translates to:
  /// **'Mostra solo preparabili'**
  String get recipeBookOnlyReady;

  /// No description provided for @recipeBookNoneReady.
  ///
  /// In it, this message translates to:
  /// **'Nessuna Tavola preparabile adesso. Apri una Tavola per vedere quali Essenze ti mancano.'**
  String get recipeBookNoneReady;

  /// No description provided for @brewTouchEffect.
  ///
  /// In it, this message translates to:
  /// **'{effect}, forza {strength}: {relation}'**
  String brewTouchEffect(String effect, int strength, String relation);

  /// No description provided for @brewTouchStrengthens.
  ///
  /// In it, this message translates to:
  /// **'rafforza l\'effetto della pozione'**
  String get brewTouchStrengthens;

  /// No description provided for @brewTouchAdds.
  ///
  /// In it, this message translates to:
  /// **'un piccolo effetto in più'**
  String get brewTouchAdds;

  /// No description provided for @brewNoTouch.
  ///
  /// In it, this message translates to:
  /// **'Nessun Tocco'**
  String get brewNoTouch;

  /// No description provided for @brewConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Prepari questa pozione?'**
  String get brewConfirmTitle;

  /// No description provided for @brewConfirmSpends.
  ///
  /// In it, this message translates to:
  /// **'Spendi'**
  String get brewConfirmSpends;

  /// No description provided for @brewCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get brewCancel;

  /// No description provided for @brewConfirm.
  ///
  /// In it, this message translates to:
  /// **'Conferma'**
  String get brewConfirm;

  /// No description provided for @glossPreparabileTerm.
  ///
  /// In it, this message translates to:
  /// **'Preparabile'**
  String get glossPreparabileTerm;

  /// No description provided for @glossPreparabileText.
  ///
  /// In it, this message translates to:
  /// **'Una Tavola che puoi preparare adesso con le Vis della Dispensa: nel Ricettario ha l\'icona \"pronta\" e si trova con il filtro \"Mostra solo preparabili\".'**
  String get glossPreparabileText;

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
  /// **'La tua base, il capanno-serra ai margini del bosco: dentro si lavora, con Ricettario, Dispensa e Scaffale.'**
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
  /// **'Le Essenze attinte, ognuna con le sue Vis, la purezza (dal livello di studio della pianta quando l\'hai attinta) e le sue Qualia.'**
  String get glossDispensaText;

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
  /// **'Il recipiente dice la base della ricetta (Infuso, Tintura, Filtro…), il colore del liquido le Qualia: uno strato per Qualia. Grigio se la Tavola è incompleta.'**
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
  /// **'Più studi una pianta, più sono pure le Essenze che ne attingi: la purezza va dal 40 % (pianta mai studiata) al 100 % (pianta di cui hai la Maestria).'**
  String get tip01;

  /// No description provided for @tip02.
  ///
  /// In it, this message translates to:
  /// **'Nella Potenza di una pozione conta soprattutto la purezza delle Essenze che usi: più conosci le piante delle ricette, più le tue pozioni sono potenti.'**
  String get tip02;

  /// No description provided for @tip03.
  ///
  /// In it, this message translates to:
  /// **'Le Tavole Comuni del Ricettario si imparano studiando: quando superi il livello 1 di una specie, la Tavola Comune di quella pianta entra nel tuo Ricettario.'**
  String get tip03;

  /// No description provided for @tip04.
  ///
  /// In it, this message translates to:
  /// **'Le Tavole Non comuni, Rare e Mitiche escono dal Bottino dell\'Esperienza incomplete, con il nome a pezzi: ogni pezzo che manca è un Componente, e lo trovi aprendo altri Bottino dell\'Esperienza.'**
  String get tip04;

  /// No description provided for @tip05.
  ///
  /// In it, this message translates to:
  /// **'Le Tavole Mitiche si trovano solo aprendo il Bottino dell\'Esperienza di grado mitico.'**
  String get tip05;

  /// No description provided for @tip06.
  ///
  /// In it, this message translates to:
  /// **'Se il Bottino dell\'Esperienza ti dà una Tavola o un Componente che hai già, è un doppione: lo ricicli con un po\' di Vis. 3 Riciclati fanno un Componente dello stesso grado, 9 un Componente del grado sopra.'**
  String get tip06;

  /// No description provided for @tip07.
  ///
  /// In it, this message translates to:
  /// **'Riciclare un doppione costa un po\' di Vis, presa dalle tue Essenze: si usano prima le Essenze meno preziose, così quelle con le Qualia restano per le ricette.'**
  String get tip07;

  /// No description provided for @tip08.
  ///
  /// In it, this message translates to:
  /// **'Ogni ricetta ha uno slot libero, «qualsiasi specie»: la pianta che ci metti dà alla pozione il suo Tocco (Rigogliosa, Limpida, Presaga o Copiosa).'**
  String get tip08;

  /// No description provided for @tip09.
  ///
  /// In it, this message translates to:
  /// **'Attenzione allo slot libero delle ricette da bere: con una pianta tossica la pozione si guasta e perdi la Vis usata, ma impari che quella pianta è tossica.'**
  String get tip09;

  /// No description provided for @tip10.
  ///
  /// In it, this message translates to:
  /// **'Nel Ricettario, il filtro \"Mostra solo preparabili\" lascia le Tavole che puoi preparare adesso; aprendo le altre vedi quali Essenze ti mancano: è la lista delle piante da cercare alla prossima uscita.'**
  String get tip10;

  /// No description provided for @tip11.
  ///
  /// In it, this message translates to:
  /// **'Quando usi una pozione dello Scaffale, il suo effetto dura 7 giorni ed è tanto più forte quanto più alta è la sua Potenza.'**
  String get tip11;

  /// No description provided for @tip12.
  ///
  /// In it, this message translates to:
  /// **'Le Qualia di un\'Essenza dicono in che condizioni l\'hai attinta (meteo, ora del giorno, luna); il nome di una ricetta dice quali Qualia servono: «Plenilunare» chiede un\'Essenza attinta con la Luna piena.'**
  String get tip12;

  /// No description provided for @tip13.
  ///
  /// In it, this message translates to:
  /// **'I PE che guadagni studiando una specie restano da Incassare finché non attingi la prima Essenza di quella specie: solo allora diventano PE veri.'**
  String get tip13;

  /// No description provided for @tip14.
  ///
  /// In it, this message translates to:
  /// **'Il significato di simboli, colori e gradi è nella Legenda: Impostazioni → Legenda e glossario.'**
  String get tip14;

  /// No description provided for @tip15.
  ///
  /// In it, this message translates to:
  /// **'Nel gioco una pianta non si raccoglie mai: la si fotografa e se ne attinge la Vis. Le piante restano dove sono, intatte.'**
  String get tip15;

  /// No description provided for @viewToFind.
  ///
  /// In it, this message translates to:
  /// **'Da trovare'**
  String get viewToFind;

  /// No description provided for @levelMasteryDormant.
  ///
  /// In it, this message translates to:
  /// **'Maestria sopita'**
  String get levelMasteryDormant;

  /// No description provided for @masteryToAwaken.
  ///
  /// In it, this message translates to:
  /// **'Maestria da risvegliare'**
  String get masteryToAwaken;

  /// No description provided for @awakenButton.
  ///
  /// In it, this message translates to:
  /// **'Risveglia'**
  String get awakenButton;

  /// No description provided for @awakenMasteryButton.
  ///
  /// In it, this message translates to:
  /// **'Risveglia la Maestria'**
  String get awakenMasteryButton;

  /// No description provided for @masteryKeepHint.
  ///
  /// In it, this message translates to:
  /// **'La Maestria si mantiene rispondendo ogni tanto a una domanda di questa specie: dopo {days} giorni senza, si assopisce.'**
  String masteryKeepHint(int days);

  /// No description provided for @masteryDormantText.
  ///
  /// In it, this message translates to:
  /// **'Dopo {days} giorni senza domande su questa specie la Maestria si è assopita: le nuove Essenze sono pure al {dormant} % invece che al {full} %. Risvegliala con {questions} domande su tutti i Livelli: ne bastano {needed} giuste.'**
  String masteryDormantText(
    int days,
    int dormant,
    int full,
    int questions,
    int needed,
  );

  /// No description provided for @awakeningTheme.
  ///
  /// In it, this message translates to:
  /// **'Risveglio della Maestria'**
  String get awakeningTheme;

  /// No description provided for @summaryAwakened.
  ///
  /// In it, this message translates to:
  /// **'Maestria risvegliata: le Essenze di {name} tornano pure al {full} %.'**
  String summaryAwakened(String name, int full);

  /// No description provided for @summaryStillDormant.
  ///
  /// In it, this message translates to:
  /// **'Ancora sopita: servono almeno {needed} risposte giuste su {total}. Puoi riprovare subito.'**
  String summaryStillDormant(int needed, int total);

  /// No description provided for @tip16.
  ///
  /// In it, this message translates to:
  /// **'La Maestria di una specie va mantenuta: se per 30 giorni non rispondi a domande su quella specie, la Maestria si assopisce. La risvegli con 5 domande, dalla scheda della specie o da «Le tue specie» in Home.'**
  String get tip16;

  /// No description provided for @simulateMastery.
  ///
  /// In it, this message translates to:
  /// **'Simula Maestria'**
  String get simulateMastery;

  /// No description provided for @debugFieldTest.
  ///
  /// In it, this message translates to:
  /// **'Prova sul campo'**
  String get debugFieldTest;

  /// No description provided for @fieldTestIntro.
  ///
  /// In it, this message translates to:
  /// **'Ogni prova scatta una foto, la manda a Pl@ntNet e misura il GPS dal tocco per almeno 20 secondi (e 10 dopo la foto). Le prove finiscono in un CSV da scaricare con adb.'**
  String get fieldTestIntro;

  /// No description provided for @fieldTestExpected.
  ///
  /// In it, this message translates to:
  /// **'Pianta attesa'**
  String get fieldTestExpected;

  /// No description provided for @fieldTestExpectedHint.
  ///
  /// In it, this message translates to:
  /// **'es. elleboro verde, Helleborus viridis'**
  String get fieldTestExpectedHint;

  /// No description provided for @fieldTestPlace.
  ///
  /// In it, this message translates to:
  /// **'Luogo'**
  String get fieldTestPlace;

  /// No description provided for @fieldTestPlaceHint.
  ///
  /// In it, this message translates to:
  /// **'sole, ombra degli alberi, città…'**
  String get fieldTestPlaceHint;

  /// No description provided for @fieldTestRun.
  ///
  /// In it, this message translates to:
  /// **'Scatta e misura'**
  String get fieldTestRun;

  /// No description provided for @fieldTestPhasePhoto.
  ///
  /// In it, this message translates to:
  /// **'Fotocamera…'**
  String get fieldTestPhasePhoto;

  /// No description provided for @fieldTestPhaseIdentifying.
  ///
  /// In it, this message translates to:
  /// **'Pl@ntNet sta guardando la foto…'**
  String get fieldTestPhaseIdentifying;

  /// No description provided for @fieldTestPhaseLocating.
  ///
  /// In it, this message translates to:
  /// **'GPS: ancora qualche secondo…'**
  String get fieldTestPhaseLocating;

  /// No description provided for @fieldTestNoKey.
  ///
  /// In it, this message translates to:
  /// **'Manca la chiave Pl@ntNet (PLANTNET_API_KEY): la foto e il GPS si misurano, l\'identificazione no.'**
  String get fieldTestNoKey;

  /// No description provided for @fieldTestOutcome.
  ///
  /// In it, this message translates to:
  /// **'Esito: {outcome}'**
  String fieldTestOutcome(String outcome);

  /// No description provided for @fieldTestTimes.
  ///
  /// In it, this message translates to:
  /// **'Foto in {photo} s · Pl@ntNet in {plantnet} ms · {kb} KB'**
  String fieldTestTimes(String photo, String plantnet, String kb);

  /// No description provided for @fieldTestGps.
  ///
  /// In it, this message translates to:
  /// **'GPS: prima posizione dopo {first} s · precisione a 5 s {a5} m, a 10 s {a10} m, a 20 s {a20} m'**
  String fieldTestGps(String first, String a5, String a10, String a20);

  /// No description provided for @fieldTestGpsAfterPhoto.
  ///
  /// In it, this message translates to:
  /// **'Posizioni durante la foto: {during} · dopo la foto la prima in {first} s, precisione {accuracy} m'**
  String fieldTestGpsAfterPhoto(int during, String first, String accuracy);

  /// No description provided for @fieldTestRemaining.
  ///
  /// In it, this message translates to:
  /// **'Identificazioni rimaste oggi: {count}'**
  String fieldTestRemaining(String count);

  /// No description provided for @fieldTestRows.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Nessuna prova salvata} =1{1 prova salvata} other{{count} prove salvate}}'**
  String fieldTestRows(int count);

  /// No description provided for @fieldTestCopy.
  ///
  /// In it, this message translates to:
  /// **'Copia il CSV'**
  String get fieldTestCopy;

  /// No description provided for @fieldTestCopied.
  ///
  /// In it, this message translates to:
  /// **'CSV copiato'**
  String get fieldTestCopied;

  /// No description provided for @fieldTestClear.
  ///
  /// In it, this message translates to:
  /// **'Cancella le prove'**
  String get fieldTestClear;

  /// No description provided for @fieldTestClearConfirm.
  ///
  /// In it, this message translates to:
  /// **'Tocca di nuovo per cancellarle'**
  String get fieldTestClearConfirm;

  /// No description provided for @cameraClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi la fotocamera'**
  String get cameraClose;

  /// No description provided for @cameraShutter.
  ///
  /// In it, this message translates to:
  /// **'Scatta'**
  String get cameraShutter;

  /// No description provided for @cameraGps.
  ///
  /// In it, this message translates to:
  /// **'GPS ±{metres} m'**
  String cameraGps(int metres);

  /// No description provided for @cameraGpsSearching.
  ///
  /// In it, this message translates to:
  /// **'GPS…'**
  String get cameraGpsSearching;

  /// No description provided for @cameraGpsOff.
  ///
  /// In it, this message translates to:
  /// **'GPS spento'**
  String get cameraGpsOff;

  /// No description provided for @cameraDenied.
  ///
  /// In it, this message translates to:
  /// **'Per fotografare le piante serve il permesso della fotocamera: lo dai dalle impostazioni di Android, alla voce Autorizzazioni dell\'app.'**
  String get cameraDenied;

  /// No description provided for @cameraError.
  ///
  /// In it, this message translates to:
  /// **'La fotocamera non si è aperta ({error}).'**
  String cameraError(String error);

  /// No description provided for @cameraDebug.
  ///
  /// In it, this message translates to:
  /// **'{size} · {received} fps · analizzati {analyzed}/s · {ms} ms · nitidezza {sharpness} · movimento {motion}'**
  String cameraDebug(
    String size,
    String received,
    String analyzed,
    String ms,
    String sharpness,
    String motion,
  );

  /// No description provided for @fieldTestSystemCamera.
  ///
  /// In it, this message translates to:
  /// **'Fotocamera di sistema (per confronto)'**
  String get fieldTestSystemCamera;

  /// No description provided for @fieldTestCamera.
  ///
  /// In it, this message translates to:
  /// **'Fotocamera: {fps} fps, analizzati {analyzed}/s in {ms} ms · scatto {capture} ms · riduzione {resize} ms'**
  String fieldTestCamera(
    String fps,
    String analyzed,
    String ms,
    String capture,
    String resize,
  );

  /// No description provided for @cameraFlashOff.
  ///
  /// In it, this message translates to:
  /// **'Flash spento'**
  String get cameraFlashOff;

  /// No description provided for @cameraFlashAuto.
  ///
  /// In it, this message translates to:
  /// **'Flash automatico'**
  String get cameraFlashAuto;

  /// No description provided for @cameraFlashOn.
  ///
  /// In it, this message translates to:
  /// **'Flash acceso'**
  String get cameraFlashOn;

  /// No description provided for @cameraZoom.
  ///
  /// In it, this message translates to:
  /// **'Zoom {zoom}'**
  String cameraZoom(String zoom);

  /// No description provided for @cameraGatherHint.
  ///
  /// In it, this message translates to:
  /// **'Inquadra tutta la pianta: la Vis sale mentre la fotografi, più in fretta se ti muovi'**
  String get cameraGatherHint;

  /// No description provided for @cameraShutterLocked.
  ///
  /// In it, this message translates to:
  /// **'Ancora un attimo: la Vis comincia a salire'**
  String get cameraShutterLocked;

  /// No description provided for @cameraLeafHint.
  ///
  /// In it, this message translates to:
  /// **'Ora avvicinati a una foglia'**
  String get cameraLeafHint;

  /// No description provided for @cameraFlowerHint.
  ///
  /// In it, this message translates to:
  /// **'E un fiore, se c\'è'**
  String get cameraFlowerHint;

  /// No description provided for @cameraNoFlower.
  ///
  /// In it, this message translates to:
  /// **'Non ha fiori'**
  String get cameraNoFlower;

  /// No description provided for @cameraOrganWhole.
  ///
  /// In it, this message translates to:
  /// **'Pianta intera'**
  String get cameraOrganWhole;

  /// No description provided for @cameraOrganLeaf.
  ///
  /// In it, this message translates to:
  /// **'Foglia'**
  String get cameraOrganLeaf;

  /// No description provided for @cameraOrganFlower.
  ///
  /// In it, this message translates to:
  /// **'Fiore'**
  String get cameraOrganFlower;

  /// No description provided for @fieldTestRegional.
  ///
  /// In it, this message translates to:
  /// **'Confronta con la flora regionale (2 identificazioni)'**
  String get fieldTestRegional;

  /// No description provided for @fieldTestRegionalResult.
  ///
  /// In it, this message translates to:
  /// **'Flora regionale (Europa sudorientale)'**
  String get fieldTestRegionalResult;

  /// No description provided for @cameraZoomSlower.
  ///
  /// In it, this message translates to:
  /// **'Senza zoom la Vis sale più in fretta'**
  String get cameraZoomSlower;

  /// No description provided for @tip17.
  ///
  /// In it, this message translates to:
  /// **'Quando fotografi una pianta, la sua Vis sale finché la inquadri: prenditi il tuo tempo e muoviti piano intorno, dalla pianta intera alla foglia al fiore. Chi ha pazienza raccoglie più Vis.'**
  String get tip17;

  /// No description provided for @captureNoKey.
  ///
  /// In it, this message translates to:
  /// **'Manca la chiave di Pl@ntNet (PLANTNET_API_KEY): per ora l\'Incontro si prova con Simula Incontro.'**
  String get captureNoKey;

  /// No description provided for @captureLimitTitle.
  ///
  /// In it, this message translates to:
  /// **'Per oggi basta Stazioni nuove'**
  String get captureLimitTitle;

  /// No description provided for @captureLimitText.
  ///
  /// In it, this message translates to:
  /// **'Oggi è già nata una Stazione nuova: domani potrai fotografare un\'altra pianta. Le Stazioni hanno bisogno del loro tempo.'**
  String get captureLimitText;

  /// No description provided for @captureGuessTitle.
  ///
  /// In it, this message translates to:
  /// **'Che pianta pensi che sia?'**
  String get captureGuessTitle;

  /// No description provided for @captureGuessHint.
  ///
  /// In it, this message translates to:
  /// **'Nome comune o scientifico'**
  String get captureGuessHint;

  /// No description provided for @captureGuessConfirm.
  ///
  /// In it, this message translates to:
  /// **'Ecco la mia ipotesi'**
  String get captureGuessConfirm;

  /// No description provided for @captureGuessSkip.
  ///
  /// In it, this message translates to:
  /// **'Non lo so'**
  String get captureGuessSkip;

  /// No description provided for @captureIdentifying.
  ///
  /// In it, this message translates to:
  /// **'Pl@ntNet sta guardando le foto…'**
  String get captureIdentifying;

  /// No description provided for @captureFailed.
  ///
  /// In it, this message translates to:
  /// **'Pl@ntNet non ha risposto ({error}).'**
  String captureFailed(String error);

  /// No description provided for @captureRetry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get captureRetry;

  /// No description provided for @captureNone.
  ///
  /// In it, this message translates to:
  /// **'Pl@ntNet non riconosce questa pianta: riprova più vicino, con la luce sulla pianta, e fotografa anche una foglia o un fiore.'**
  String get captureNone;

  /// No description provided for @captureContested.
  ///
  /// In it, this message translates to:
  /// **'Pl@ntNet è indeciso: quale hai davanti?'**
  String get captureContested;

  /// No description provided for @captureProposed.
  ///
  /// In it, this message translates to:
  /// **'Pl@ntNet pensa che sia:'**
  String get captureProposed;

  /// No description provided for @captureConfirm.
  ///
  /// In it, this message translates to:
  /// **'È questa'**
  String get captureConfirm;

  /// No description provided for @captureKindDiscovery.
  ///
  /// In it, this message translates to:
  /// **'Scoperta'**
  String get captureKindDiscovery;

  /// No description provided for @captureKindGuest.
  ///
  /// In it, this message translates to:
  /// **'Ospite'**
  String get captureKindGuest;

  /// No description provided for @captureGuestText.
  ///
  /// In it, this message translates to:
  /// **'Non è originaria dei tuoi luoghi: è un\'Ospite, e la sua Vis qui è molto debole.'**
  String get captureGuestText;

  /// No description provided for @captureDiscoveryText.
  ///
  /// In it, this message translates to:
  /// **'Nella tua Zona non risulta mai osservata: è una Scoperta, da confermare.'**
  String get captureDiscoveryText;

  /// No description provided for @captureGuessExact.
  ///
  /// In it, this message translates to:
  /// **'Ci hai preso!'**
  String get captureGuessExact;

  /// No description provided for @captureGuessGenus.
  ///
  /// In it, this message translates to:
  /// **'Quasi! È un {genus}.'**
  String captureGuessGenus(String genus);

  /// No description provided for @captureGuessWrong.
  ///
  /// In it, this message translates to:
  /// **'La tua ipotesi era «{guess}».'**
  String captureGuessWrong(String guess);

  /// No description provided for @captureStationCreated.
  ///
  /// In it, this message translates to:
  /// **'È nata una nuova Stazione.'**
  String get captureStationCreated;

  /// No description provided for @captureStationExisting.
  ///
  /// In it, this message translates to:
  /// **'Sei alla tua Stazione di questa pianta.'**
  String get captureStationExisting;

  /// No description provided for @captureStationNoPosition.
  ///
  /// In it, this message translates to:
  /// **'Senza posizione: l\'Incontro vale, la Stazione no.'**
  String get captureStationNoPosition;

  /// No description provided for @captureStationLimit.
  ///
  /// In it, this message translates to:
  /// **'Oggi è già nata una Stazione nuova: questa vale come Incontro.'**
  String get captureStationLimit;

  /// No description provided for @captureXp.
  ///
  /// In it, this message translates to:
  /// **'+{xp} PE'**
  String captureXp(int xp);

  /// No description provided for @captureDone.
  ///
  /// In it, this message translates to:
  /// **'Fatto'**
  String get captureDone;

  /// No description provided for @captureAction.
  ///
  /// In it, this message translates to:
  /// **'Attingi'**
  String get captureAction;

  /// No description provided for @captureTitle.
  ///
  /// In it, this message translates to:
  /// **'Attingi la Vis'**
  String get captureTitle;

  /// No description provided for @captureFromSpecies.
  ///
  /// In it, this message translates to:
  /// **'Attingi la sua Vis'**
  String get captureFromSpecies;

  /// No description provided for @captureFirstPhoto.
  ///
  /// In it, this message translates to:
  /// **'La tua foto prende il posto di quella dell\'Erbario, con il timbro di oggi.'**
  String get captureFirstPhoto;

  /// No description provided for @ownPhotoStamp.
  ///
  /// In it, this message translates to:
  /// **'La tua foto · {date}'**
  String ownPhotoStamp(String date);

  /// No description provided for @sectionStations.
  ///
  /// In it, this message translates to:
  /// **'Le tue Stazioni'**
  String get sectionStations;

  /// No description provided for @stationAccuracy.
  ///
  /// In it, this message translates to:
  /// **'± {meters} m'**
  String stationAccuracy(int meters);

  /// No description provided for @stationsNote.
  ///
  /// In it, this message translates to:
  /// **'Solo sul tuo telefono: il punto preciso non si mostra e non si condivide.'**
  String get stationsNote;

  /// No description provided for @firstRunWelcomeTitle.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto in Druid'**
  String get firstRunWelcomeTitle;

  /// No description provided for @firstRunWelcomeIntro.
  ///
  /// In it, this message translates to:
  /// **'Sei un erborista: trovi le piante vere, le fotografi, le studi e con le loro Essenze prepari pozioni di fantasia. Prima di cominciare, le regole del gioco nel mondo vero.'**
  String get firstRunWelcomeIntro;

  /// No description provided for @firstRunRuleNoPickTitle.
  ///
  /// In it, this message translates to:
  /// **'Fotografa, non raccogliere'**
  String get firstRunRuleNoPickTitle;

  /// No description provided for @firstRunRuleNoPickText.
  ///
  /// In it, this message translates to:
  /// **'Le piante non si raccolgono mai: si fotografano e restano dove sono. Non strappare foglie o fiori e non calpestarle.'**
  String get firstRunRuleNoPickText;

  /// No description provided for @firstRunRuleProtectedTitle.
  ///
  /// In it, this message translates to:
  /// **'Specie e aree protette'**
  String get firstRunRuleProtectedTitle;

  /// No description provided for @firstRunRuleProtectedText.
  ///
  /// In it, this message translates to:
  /// **'Alcune specie sono protette dalla legge. Nei parchi e nelle riserve resta sui sentieri e rispetta i loro regolamenti.'**
  String get firstRunRuleProtectedText;

  /// No description provided for @firstRunRulePrivateTitle.
  ///
  /// In it, this message translates to:
  /// **'Niente proprietà private'**
  String get firstRunRulePrivateTitle;

  /// No description provided for @firstRunRulePrivateText.
  ///
  /// In it, this message translates to:
  /// **'Non entrare in giardini, campi o terreni privati senza permesso: fotografa da dove puoi stare.'**
  String get firstRunRulePrivateText;

  /// No description provided for @firstRunRuleDaylightTitle.
  ///
  /// In it, this message translates to:
  /// **'Con la luce del giorno'**
  String get firstRunRuleDaylightTitle;

  /// No description provided for @firstRunRuleDaylightText.
  ///
  /// In it, this message translates to:
  /// **'Non uscire a giocare di notte o con poca luce. Le Qualia della luna valgono tutto il giorno: non serve mai.'**
  String get firstRunRuleDaylightText;

  /// No description provided for @firstRunRuleSafetyTitle.
  ///
  /// In it, this message translates to:
  /// **'Attenzione a dove metti i piedi'**
  String get firstRunRuleSafetyTitle;

  /// No description provided for @firstRunRuleSafetyText.
  ///
  /// In it, this message translates to:
  /// **'Guarda il terreno e il traffico: non fotografare mentre attraversi la strada o guidi. Se vai lontano, di\' a qualcuno dove vai.'**
  String get firstRunRuleSafetyText;

  /// No description provided for @firstRunRuleToxicTitle.
  ///
  /// In it, this message translates to:
  /// **'Le piante non si mangiano'**
  String get firstRunRuleToxicTitle;

  /// No description provided for @firstRunRuleToxicText.
  ///
  /// In it, this message translates to:
  /// **'Molte piante sono tossiche. Non mangiarle e non usarle per curarti: le pozioni del gioco sono di fantasia e non danno indicazioni d\'uso reali.'**
  String get firstRunRuleToxicText;

  /// No description provided for @firstRunRuleIdentifyTitle.
  ///
  /// In it, this message translates to:
  /// **'Il riconoscimento può sbagliare'**
  String get firstRunRuleIdentifyTitle;

  /// No description provided for @firstRunRuleIdentifyText.
  ///
  /// In it, this message translates to:
  /// **'Pl@ntNet riconosce le piante dalle foto, ma può sbagliare. Gli avvisi di tossicità sono da verificare.'**
  String get firstRunRuleIdentifyText;

  /// No description provided for @firstRunRulePrivacyTitle.
  ///
  /// In it, this message translates to:
  /// **'Le tue foto e la tua posizione'**
  String get firstRunRulePrivacyTitle;

  /// No description provided for @firstRunRulePrivacyText.
  ///
  /// In it, this message translates to:
  /// **'Le foto vanno a Pl@ntNet solo per riconoscere la pianta. La posizione delle tue Stazioni resta sul tuo telefono: non si mostra e non si condivide.'**
  String get firstRunRulePrivacyText;

  /// No description provided for @firstRunTermsFooter.
  ///
  /// In it, this message translates to:
  /// **'Toccando Accetto confermi di aver letto queste regole e di giocare con prudenza e rispetto.'**
  String get firstRunTermsFooter;

  /// No description provided for @firstRunAccept.
  ///
  /// In it, this message translates to:
  /// **'Accetto'**
  String get firstRunAccept;

  /// No description provided for @firstRunCameraTitle.
  ///
  /// In it, this message translates to:
  /// **'Le foto delle piante'**
  String get firstRunCameraTitle;

  /// No description provided for @firstRunCameraText.
  ///
  /// In it, this message translates to:
  /// **'Per Incontrare una pianta la fotografi con la fotocamera dell\'app: la pianta intera, una foglia e il fiore se c\'è. Così Pl@ntNet la riconosce e la tua foto entra nell\'Erbario.'**
  String get firstRunCameraText;

  /// No description provided for @firstRunCameraAllow.
  ///
  /// In it, this message translates to:
  /// **'Consenti'**
  String get firstRunCameraAllow;

  /// No description provided for @firstRunCameraDenied.
  ///
  /// In it, this message translates to:
  /// **'Senza fotocamera non puoi Incontrare le piante. Puoi dare il permesso quando vuoi dalle impostazioni di Android, alla voce Autorizzazioni dell\'app.'**
  String get firstRunCameraDenied;

  /// No description provided for @firstRunLocationTitle.
  ///
  /// In it, this message translates to:
  /// **'La posizione'**
  String get firstRunLocationTitle;

  /// No description provided for @firstRunLocationText.
  ///
  /// In it, this message translates to:
  /// **'Dove fotografi una pianta nasce una Stazione: lì potrai tornare ad Attingere. Serve la posizione precisa, solo mentre usi l\'app. Le tue Stazioni restano sul telefono: non si mostrano e non si condividono.'**
  String get firstRunLocationText;

  /// No description provided for @firstRunLocationAllow.
  ///
  /// In it, this message translates to:
  /// **'Attiva'**
  String get firstRunLocationAllow;

  /// No description provided for @firstRunLocationDenied.
  ///
  /// In it, this message translates to:
  /// **'Senza posizione gli Incontri valgono, ma non nascono Stazioni. Puoi attivarla quando vuoi dalle impostazioni di Android, alla voce Autorizzazioni dell\'app.'**
  String get firstRunLocationDenied;

  /// No description provided for @firstRunLocationApproximate.
  ///
  /// In it, this message translates to:
  /// **'Con la posizione approssimativa le Stazioni non sono precise. Puoi scegliere la posizione precisa dalle impostazioni di Android, alla voce Autorizzazioni dell\'app.'**
  String get firstRunLocationApproximate;

  /// No description provided for @firstRunOpenSettings.
  ///
  /// In it, this message translates to:
  /// **'Apri le impostazioni'**
  String get firstRunOpenSettings;

  /// No description provided for @firstRunNext.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get firstRunNext;

  /// No description provided for @firstRunReadyTitle.
  ///
  /// In it, this message translates to:
  /// **'Sei pronto a giocare'**
  String get firstRunReadyTitle;

  /// No description provided for @firstRunReadyText.
  ///
  /// In it, this message translates to:
  /// **'Il tutorial ti accompagna nel primo giro, tutto da casa: fotografi un\'aromatica di cucina, la studi e prepari la tua prima pozione.'**
  String get firstRunReadyText;

  /// No description provided for @firstRunStartTutorial.
  ///
  /// In it, this message translates to:
  /// **'Fai il tutorial'**
  String get firstRunStartTutorial;

  /// No description provided for @firstRunLater.
  ///
  /// In it, this message translates to:
  /// **'Più tardi'**
  String get firstRunLater;

  /// No description provided for @firstRunLaterNote.
  ///
  /// In it, this message translates to:
  /// **'Il tutorial resta in Home: lo fai quando vuoi.'**
  String get firstRunLaterNote;

  /// No description provided for @firstRunProgress.
  ///
  /// In it, this message translates to:
  /// **'Passo {step} di {total}'**
  String firstRunProgress(int step, int total);

  /// No description provided for @rankCurious.
  ///
  /// In it, this message translates to:
  /// **'Curioso'**
  String get rankCurious;

  /// No description provided for @nextRankCurious.
  ///
  /// In it, this message translates to:
  /// **'Prossimo Rango: Apprendista, alla fine del tutorial'**
  String get nextRankCurious;

  /// No description provided for @tutorialLabel.
  ///
  /// In it, this message translates to:
  /// **'Tutorial · passo {step} di {total}'**
  String tutorialLabel(int step, int total);

  /// No description provided for @tutorialIntroTitle.
  ///
  /// In it, this message translates to:
  /// **'Il tutorial'**
  String get tutorialIntroTitle;

  /// No description provided for @tutorialIntroBody.
  ///
  /// In it, this message translates to:
  /// **'Un giro del gioco tutto da casa, con le aromatiche di cucina: salvia, rosmarino, alloro o basilico, anche in vaso o dal supermercato. Alla fine diventi Apprendista.'**
  String get tutorialIntroBody;

  /// No description provided for @tutorialStart.
  ///
  /// In it, this message translates to:
  /// **'Inizia'**
  String get tutorialStart;

  /// No description provided for @tutorialSkip.
  ///
  /// In it, this message translates to:
  /// **'Salta il tutorial'**
  String get tutorialSkip;

  /// No description provided for @tutorialPhotographTitle.
  ///
  /// In it, this message translates to:
  /// **'Fotografa un\'aromatica'**
  String get tutorialPhotographTitle;

  /// No description provided for @tutorialPhotographBody.
  ///
  /// In it, this message translates to:
  /// **'Tocca Attingi al centro della barra e fotografa salvia, rosmarino, alloro o basilico, anche in vaso o dal supermercato. Pl@ntNet la riconosce: la Incontri, nasce la sua Stazione e ne Attingi la prima Essenza. Fotografa, non raccogliere.'**
  String get tutorialPhotographBody;

  /// No description provided for @tutorialStudyTitle.
  ///
  /// In it, this message translates to:
  /// **'Studia la tua aromatica'**
  String get tutorialStudyTitle;

  /// No description provided for @tutorialStudyBody.
  ///
  /// In it, this message translates to:
  /// **'Ogni pianta si studia a Livelli, con domande che fanno imparare anche quando sbagli. Supera il Livello 1 della pianta che hai fotografato: impari la sua Ricetta Comune. Intanto nella barra si è acceso l\'Erbario.'**
  String get tutorialStudyBody;

  /// No description provided for @tutorialSecondPhotographTitle.
  ///
  /// In it, this message translates to:
  /// **'Fotografa un\'altra aromatica'**
  String get tutorialSecondPhotographTitle;

  /// No description provided for @tutorialSecondPhotographBody.
  ///
  /// In it, this message translates to:
  /// **'La Ricetta Comune vuole la pianta e un\'altra specie qualsiasi: fotografa un\'altra aromatica e ne Attingi una seconda Essenza.'**
  String get tutorialSecondPhotographBody;

  /// No description provided for @tutorialBrewTitle.
  ///
  /// In it, this message translates to:
  /// **'Prepara la prima pozione'**
  String get tutorialBrewTitle;

  /// No description provided for @tutorialBrewBody.
  ///
  /// In it, this message translates to:
  /// **'Nella barra si è acceso il Laboratorio: nel Ricettario trovi la Ricetta Comune pronta, preparala con le tue due Essenze. Le pozioni sono di fantasia.'**
  String get tutorialBrewBody;

  /// No description provided for @tutorialTroveTitle.
  ///
  /// In it, this message translates to:
  /// **'Il Bottino dell\'Esperienza'**
  String get tutorialTroveTitle;

  /// No description provided for @tutorialTroveBody.
  ///
  /// In it, this message translates to:
  /// **'Con i PE compri Bottini dell\'Esperienza: dentro ci sono le Tavole di altre Ricette. Nella barra si è acceso il Bottino: aprilo, c\'è un regalo per te.'**
  String get tutorialTroveBody;

  /// No description provided for @tutorialApprenticeTitle.
  ///
  /// In it, this message translates to:
  /// **'Sei Apprendista'**
  String get tutorialApprenticeTitle;

  /// No description provided for @tutorialApprenticeBody.
  ///
  /// In it, this message translates to:
  /// **'Hai fatto il primo giro: fotografare, studiare, Attingere, preparare. Ora esci: le piante della tua Zona ti aspettano nell\'Erbario, alla voce Da trovare.'**
  String get tutorialApprenticeBody;

  /// No description provided for @tutorialActionCapture.
  ///
  /// In it, this message translates to:
  /// **'Attingi'**
  String get tutorialActionCapture;

  /// No description provided for @tutorialActionStudy.
  ///
  /// In it, this message translates to:
  /// **'Studia'**
  String get tutorialActionStudy;

  /// No description provided for @tutorialActionLaboratory.
  ///
  /// In it, this message translates to:
  /// **'Apri il Laboratorio'**
  String get tutorialActionLaboratory;

  /// No description provided for @tutorialActionTrove.
  ///
  /// In it, this message translates to:
  /// **'Apri il Bottino'**
  String get tutorialActionTrove;

  /// No description provided for @tutorialActionFinish.
  ///
  /// In it, this message translates to:
  /// **'Continua'**
  String get tutorialActionFinish;

  /// No description provided for @erbarioKitchen.
  ///
  /// In it, this message translates to:
  /// **'Dalla cucina'**
  String get erbarioKitchen;

  /// No description provided for @kitchenHint.
  ///
  /// In it, this message translates to:
  /// **'Un\'aromatica di cucina: la trovi in vaso, sul balcone o al supermercato. Fotografala da casa, anche solo una foglia.'**
  String get kitchenHint;

  /// No description provided for @sectionOrigin.
  ///
  /// In it, this message translates to:
  /// **'Da dove viene'**
  String get sectionOrigin;

  /// No description provided for @captureTutorialEssence.
  ///
  /// In it, this message translates to:
  /// **'Ne hai Attinto la prima Essenza, con le Qualia di questo momento: la trovi nella Dispensa del Laboratorio.'**
  String get captureTutorialEssence;

  /// No description provided for @sourcesLabel.
  ///
  /// In it, this message translates to:
  /// **'Fonte: '**
  String get sourcesLabel;

  /// No description provided for @cameraDrawHint.
  ///
  /// In it, this message translates to:
  /// **'Inquadra la tua pianta: la Vis sale mentre la guardi, più in fretta se ti muovi'**
  String get cameraDrawHint;

  /// No description provided for @captureLocating.
  ///
  /// In it, this message translates to:
  /// **'Cerco dove sei…'**
  String get captureLocating;

  /// No description provided for @captureAtStationTitle.
  ///
  /// In it, this message translates to:
  /// **'Sei alla tua Stazione'**
  String get captureAtStationTitle;

  /// No description provided for @captureAtStationText.
  ///
  /// In it, this message translates to:
  /// **'Qui Attingi senza mandare foto a Pl@ntNet: inquadra la pianta e raccogli la Vis.'**
  String get captureAtStationText;

  /// No description provided for @captureOtherPlant.
  ///
  /// In it, this message translates to:
  /// **'È un\'altra pianta'**
  String get captureOtherPlant;

  /// No description provided for @stationReady.
  ///
  /// In it, this message translates to:
  /// **'Pronta'**
  String get stationReady;

  /// No description provided for @stationExhausted.
  ///
  /// In it, this message translates to:
  /// **'Esaurita: torna pronta {when}'**
  String stationExhausted(String when);

  /// No description provided for @stationRegrowing.
  ///
  /// In it, this message translates to:
  /// **'In rigenerazione: torna pronta {when}'**
  String stationRegrowing(String when);

  /// No description provided for @stationSuspended.
  ///
  /// In it, this message translates to:
  /// **'Raccolta sospesa: {reason}, riprende {when}'**
  String stationSuspended(String reason, String when);

  /// No description provided for @suspendedStorm.
  ///
  /// In it, this message translates to:
  /// **'temporale'**
  String get suspendedStorm;

  /// No description provided for @suspendedHail.
  ///
  /// In it, this message translates to:
  /// **'grandine'**
  String get suspendedHail;

  /// No description provided for @suspendedWind.
  ///
  /// In it, this message translates to:
  /// **'vento forte'**
  String get suspendedWind;

  /// No description provided for @suspendedSnow.
  ///
  /// In it, this message translates to:
  /// **'neve forte'**
  String get suspendedSnow;

  /// No description provided for @whenToday.
  ///
  /// In it, this message translates to:
  /// **'alle {time}'**
  String whenToday(String time);

  /// No description provided for @whenOtherDay.
  ///
  /// In it, this message translates to:
  /// **'{day} alle {time}'**
  String whenOtherDay(String day, String time);

  /// No description provided for @captureDrawnTitle.
  ///
  /// In it, this message translates to:
  /// **'Hai Attinto un\'Essenza'**
  String get captureDrawnTitle;

  /// No description provided for @captureDrawnVis.
  ///
  /// In it, this message translates to:
  /// **'{vis} Vis · purezza {purity} %'**
  String captureDrawnVis(int vis, int purity);

  /// No description provided for @captureDrawnPantry.
  ///
  /// In it, this message translates to:
  /// **'La trovi nella Dispensa del Laboratorio, con le Qualia di questo momento.'**
  String get captureDrawnPantry;

  /// No description provided for @stationsTitle.
  ///
  /// In it, this message translates to:
  /// **'Le tue Stazioni'**
  String get stationsTitle;

  /// No description provided for @stationsSummary.
  ///
  /// In it, this message translates to:
  /// **'{ready} pronte su {total}'**
  String stationsSummary(int ready, int total);

  /// No description provided for @stationsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Non hai ancora Stazioni: nascono quando fotografi una pianta con Attingi.'**
  String get stationsEmpty;

  /// No description provided for @stationExpectedVis.
  ///
  /// In it, this message translates to:
  /// **'Fino a {vis} Vis'**
  String stationExpectedVis(int vis);

  /// No description provided for @stationStormSoon.
  ///
  /// In it, this message translates to:
  /// **'Previsto {reason}: al tuo arrivo la raccolta potrebbe essere sospesa, fino {when}'**
  String stationStormSoon(String reason, String when);

  /// No description provided for @homeStationsOpen.
  ///
  /// In it, this message translates to:
  /// **'Vedi'**
  String get homeStationsOpen;

  /// No description provided for @dykTitle.
  ///
  /// In it, this message translates to:
  /// **'Lo sapevi che…'**
  String get dykTitle;

  /// No description provided for @dykStorm.
  ///
  /// In it, this message translates to:
  /// **'Con il temporale e i fenomeni intensi previsti la raccolta è sospesa nei dintorni, da un\'ora prima a un\'ora dopo.'**
  String get dykStorm;

  /// No description provided for @dykDaylight.
  ///
  /// In it, this message translates to:
  /// **'Alba e Tramonto valgono solo con la luce: non serve mai Attingere al buio.'**
  String get dykDaylight;

  /// No description provided for @dykMoon.
  ///
  /// In it, this message translates to:
  /// **'Le Qualia della luna valgono tutto il giorno della fase: non serve uscire di notte.'**
  String get dykMoon;

  /// No description provided for @dykNoPicking.
  ///
  /// In it, this message translates to:
  /// **'Le piante non si raccolgono mai: si fotografano e se ne Attinge la Vis. Fotografa, non raccogliere.'**
  String get dykNoPicking;

  /// No description provided for @dykOneDrawPerDay.
  ///
  /// In it, this message translates to:
  /// **'Da ogni Stazione si Attinge una volta al giorno; le piante rare ci mettono giorni a rigenerarsi.'**
  String get dykOneDrawPerDay;

  /// No description provided for @dykIsolation.
  ///
  /// In it, this message translates to:
  /// **'Le Stazioni lontane tra loro rendono di più: tante piante nello stesso posto si dividono la Vis.'**
  String get dykIsolation;

  /// No description provided for @tip18.
  ///
  /// In it, this message translates to:
  /// **'Attingi con lune e meteo diversi: non sai mai quali Qualia ti serviranno.'**
  String get tip18;

  /// No description provided for @glossAffinitaTerm.
  ///
  /// In it, this message translates to:
  /// **'Affinità'**
  String get glossAffinitaTerm;

  /// No description provided for @glossAffinitaText.
  ///
  /// In it, this message translates to:
  /// **'Come vive una pianta: la luce, l\'umidità, la quota. Ogni pianta ha anche 3 Qualia sue, che le sue Tavole Non comuni e Rare chiedono: le scopri trovando le Tavole.'**
  String get glossAffinitaText;

  /// No description provided for @affinityLightFull.
  ///
  /// In it, this message translates to:
  /// **'Ama la luce piena.'**
  String get affinityLightFull;

  /// No description provided for @affinityLightHalf.
  ///
  /// In it, this message translates to:
  /// **'Sta bene a mezz\'ombra.'**
  String get affinityLightHalf;

  /// No description provided for @affinityLightShade.
  ///
  /// In it, this message translates to:
  /// **'Ama l\'ombra.'**
  String get affinityLightShade;

  /// No description provided for @affinityMoistureDry.
  ///
  /// In it, this message translates to:
  /// **'Preferisce i terreni asciutti.'**
  String get affinityMoistureDry;

  /// No description provided for @affinityMoistureDamp.
  ///
  /// In it, this message translates to:
  /// **'Preferisce i terreni umidi.'**
  String get affinityMoistureDamp;

  /// No description provided for @affinityBands.
  ///
  /// In it, this message translates to:
  /// **'Cresce {bands}.'**
  String affinityBands(String bands);

  /// No description provided for @affinityBandPlain.
  ///
  /// In it, this message translates to:
  /// **'in pianura'**
  String get affinityBandPlain;

  /// No description provided for @affinityBandHill.
  ///
  /// In it, this message translates to:
  /// **'in collina'**
  String get affinityBandHill;

  /// No description provided for @affinityBandMountain.
  ///
  /// In it, this message translates to:
  /// **'in montagna'**
  String get affinityBandMountain;

  /// No description provided for @affinityAnd.
  ///
  /// In it, this message translates to:
  /// **' e '**
  String get affinityAnd;

  /// No description provided for @recipePotionsLeast.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Prepari almeno 1 pozione} other{Prepari almeno {count} pozioni}}'**
  String recipePotionsLeast(int count);

  /// No description provided for @recipePotionsExact.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Prepari 1 pozione} other{Prepari {count} pozioni}}'**
  String recipePotionsExact(int count);

  /// No description provided for @incompleteInfoTitle.
  ///
  /// In it, this message translates to:
  /// **'La Tavola è incompleta'**
  String get incompleteInfoTitle;

  /// No description provided for @incompleteWhatTitle.
  ///
  /// In it, this message translates to:
  /// **'I «?»'**
  String get incompleteWhatTitle;

  /// No description provided for @incompleteWhatText.
  ///
  /// In it, this message translates to:
  /// **'Sono i pezzi del nome che non conosci ancora, i Componenti: alla Non comune manca l\'effetto, alla Rara l\'effetto e una Qualia, alla Mitica le sue parole.'**
  String get incompleteWhatText;

  /// No description provided for @incompleteBrewTitle.
  ///
  /// In it, this message translates to:
  /// **'Non si prepara ancora'**
  String get incompleteBrewTitle;

  /// No description provided for @incompleteBrewText.
  ///
  /// In it, this message translates to:
  /// **'Finché manca un Componente la Tavola resta nel Ricettario, ma non si prepara.'**
  String get incompleteBrewText;

  /// No description provided for @incompleteWhereTitle.
  ///
  /// In it, this message translates to:
  /// **'Dove si trovano'**
  String get incompleteWhereTitle;

  /// No description provided for @incompleteWhereText.
  ///
  /// In it, this message translates to:
  /// **'Nei Bottini dell\'Esperienza del suo Grado o più alti: a volte un Bottino dà un Componente invece di una Tavola nuova. Oppure con il Riciclo dei doppioni, in fondo alla pagina del Bottino.'**
  String get incompleteWhereText;

  /// No description provided for @incompleteInfoTooltip.
  ///
  /// In it, this message translates to:
  /// **'Che cosa manca'**
  String get incompleteInfoTooltip;

  /// No description provided for @recipeQualiaUnknown.
  ///
  /// In it, this message translates to:
  /// **'Una Qualia che non conosci ancora'**
  String get recipeQualiaUnknown;
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
