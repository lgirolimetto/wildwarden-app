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

  /// No description provided for @erbarioEncounteredSection.
  ///
  /// In it, this message translates to:
  /// **'Incontrate'**
  String get erbarioEncounteredSection;

  /// No description provided for @erbarioMissingSection.
  ///
  /// In it, this message translates to:
  /// **'Da trovare nel bolognese'**
  String get erbarioMissingSection;

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

  /// No description provided for @navRecipes.
  ///
  /// In it, this message translates to:
  /// **'Ricette'**
  String get navRecipes;

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

  /// No description provided for @summaryRecipeUnlocked.
  ///
  /// In it, this message translates to:
  /// **'Ricetta sbloccata: {recipe}'**
  String summaryRecipeUnlocked(String recipe);

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
  /// **'Niente da ripassare oggi. I Fatti imparati tornano dopo 1, 3, 7 e 21 giorni.'**
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

  /// No description provided for @desiderataCount.
  ///
  /// In it, this message translates to:
  /// **'{count} su {max}'**
  String desiderataCount(int count, int max);

  /// No description provided for @desiderataEmpty.
  ///
  /// In it, this message translates to:
  /// **'Scegli fino a 3 specie da cercare: vedrai foto e indicazioni su dove e quando trovarle.'**
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

  /// No description provided for @desiderataFull.
  ///
  /// In it, this message translates to:
  /// **'Hai già 3 Desiderata: completane o togline una.'**
  String get desiderataFull;

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

  /// No description provided for @recipeUnlocked.
  ///
  /// In it, this message translates to:
  /// **'Imparata'**
  String get recipeUnlocked;

  /// No description provided for @recipeLocked.
  ///
  /// In it, this message translates to:
  /// **'Da imparare'**
  String get recipeLocked;

  /// No description provided for @recipeKnownIngredients.
  ///
  /// In it, this message translates to:
  /// **'Ingredienti già Incontrati {known}/{total}'**
  String recipeKnownIngredients(int known, int total);

  /// No description provided for @recipeAnySpecies.
  ///
  /// In it, this message translates to:
  /// **'qualsiasi specie'**
  String get recipeAnySpecies;

  /// No description provided for @recipeCurrentLevel.
  ///
  /// In it, this message translates to:
  /// **'ora: Livello {level}'**
  String recipeCurrentLevel(int level);

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
  /// **'Scegli fino a 3 specie da cercare: per ognuna vedrai foto, periodo e quota. Comincia da una in stagione adesso.'**
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
  /// **'Porta una specie al Livello richiesto da una Ricetta per sbloccarla. Le Ricette chiedono specie e condizioni diverse: un motivo per uscire di nuovo.'**
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
  /// **'Vedi le Ricette'**
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

  /// No description provided for @recipeLearnByStudying.
  ///
  /// In it, this message translates to:
  /// **'Si impara studiando: {species}'**
  String recipeLearnByStudying(String species);

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

  /// No description provided for @recipesCount.
  ///
  /// In it, this message translates to:
  /// **'{learned} di {total}'**
  String recipesCount(int learned, int total);

  /// No description provided for @recipeIngredientCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 Ingrediente} other{{count} Ingredienti}}'**
  String recipeIngredientCount(num count);

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
  /// **'Il Bottino che si compra con i PE: scegli il Grado, il contenuto è a sorpresa (Ricette, Curiosità rare, indizi).'**
  String get glossBottinoText;

  /// No description provided for @glossFigurinaTerm.
  ///
  /// In it, this message translates to:
  /// **'Figurina'**
  String get glossFigurinaTerm;

  /// No description provided for @glossFigurinaText.
  ///
  /// In it, this message translates to:
  /// **'Una Ricetta o una Pozione nell\'Album. L\'Album delle Ricette mostra quelle che conosci; il contatore dice quante sono in tutto.'**
  String get glossFigurinaText;

  /// No description provided for @recipesEmpty.
  ///
  /// In it, this message translates to:
  /// **'Non conosci ancora nessuna Ricetta. Le Ricette Comuni si imparano studiando: supera il Livello 1 di una specie, dalla Home o dall\'Erbario.'**
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
