import 'dart:math';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_permissions.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/interfaces/i_plant_identifier.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/first_run.dart';
import 'package:druid_app/business_logic/services/dependencies.dart';
import 'package:druid_app/business_logic/rules/study/questions.dart';
import 'package:druid_app/controllers/study/study_controller.dart';
import 'package:druid_app/l10n/app_localizations_it.dart';
import 'package:druid_app/user_interface/druid_app.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'fakes.dart';

const testConfig = AppConfig(flavor: 'test', plantNetApiKey: '', logHttp: false, showDebugTools: true);

/// Registra le dipendenze con implementazioni finte. Va chiamata in `setUp`, con `Get.reset()` in `tearDown`.
({InMemoryPreferences preferences, FakeCatalogRepository catalog, InMemoryGameEventStore events, FakeClock clock})
registerTestDependencies({
  Validation<Catalog>? catalog,
  Map<String, String>? preferences,
  List<GameEvent>? events,
  AppConfig config = testConfig,
  int seed = 1,
  IPhotoSource? photoSource,
  IPlantIdentifier? plantIdentifier,
  IPermissions? permissions,
  bool firstRunDone = true,
}) {
  // Di solito l'onboarding di primo avvio è già fatto: i test partono dalla Home.
  final prefs = InMemoryPreferences({
    if (firstRunDone) ...{termsAcceptedKey: '$termsVersion', firstRunDoneKey: '1'},
    ...?preferences,
  });
  final repository = FakeCatalogRepository(catalog ?? Valid(smallCatalog()));
  final eventStore = InMemoryGameEventStore(events);
  final clock = FakeClock();
  registerDependencies(
    config: config,
    preferences: prefs,
    photoStore: FakePhotoStore(),
    catalogRepository: repository,
    eventStore: eventStore,
    clock: clock,
    random: Random(seed),
    imageFactory: const FakeImageFactory(),
    fieldTestLog: InMemoryFieldTestLog(),
    photoSource: photoSource,
    plantIdentifier: plantIdentifier,
    permissions: permissions ?? FakePermissions(),
  );
  return (preferences: prefs, catalog: repository, events: eventStore, clock: clock);
}

/// Avvia l'app intera in italiano e attende il primo frame stabile.
Future<void> pumpDruidApp(WidgetTester tester, {Locale locale = const Locale('it')}) async {
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  // Schermo da telefono (412×915 punti), come un Pixel recente.
  tester.view.physicalSize = const Size(1236, 2745);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const DruidApp());
  await tester.pumpAndSettle();
}

/// Tocca una voce della barra di navigazione in basso.
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(of: find.byType(ClayNavBar), matching: find.text(label)));
  await tester.pumpAndSettle();
}

/// Apre le Impostazioni dal pulsante in alto nella Home. Il pulsante sta nella testata del diorama, che scorrendo
/// esce dallo schermo: si usa la sua azione invece di toccarlo.
Future<void> openSettings(WidgetTester tester) async {
  await openTab(tester, 'Home');
  final list = find.descendant(of: find.byKey(const ValueKey('study-home-list')), matching: find.byType(Scrollable));
  tester.state<ScrollableState>(list.first).position.jumpTo(0);
  await tester.pump();
  tester.widget<ClayIconButton>(find.byKey(const ValueKey('open-settings'), skipOffstage: false)).onPressed();
  await tester.pumpAndSettle();
}

/// Torna indietro dalla pagina aperta sopra la Home.
Future<void> goBack(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('clay-back')).last);
  await tester.pumpAndSettle();
}

/// Risponde alla domanda corrente della sessione di studio toccando l'opzione giusta (o una sbagliata).
Future<void> answerCurrentQuestion(WidgetTester tester, {bool correctly = true}) async {
  final question = Get.find<StudyController>().question!;
  final option = correctly ? question.answer : question.options.firstWhere((o) => o != question.answer);
  final finder = question.form == QuestionForm.nameToPhoto
      ? find.byKey(ValueKey('photo-option-${(option as SpeciesOption).species.sci}'))
      : find.byKey(ValueKey('option-${GameTexts(AppLocalizationsIt(), 'it').option(question, option)}'));
  await scrollTo(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Passa alla domanda successiva (o al riepilogo).
Future<void> goToNextQuestion(WidgetTester tester) async {
  final next = find.byKey(const ValueKey('next-question'));
  await scrollTo(tester, next);
  await tester.tap(next);
  await tester.pumpAndSettle();
}

/// Risponde correttamente a tutta la sessione fino al riepilogo.
Future<void> completeSession(WidgetTester tester) async {
  final study = Get.find<StudyController>();
  if (study.lastOutcome != null) await goToNextQuestion(tester);
  while (study.question != null) {
    await answerCurrentQuestion(tester);
    await goToNextQuestion(tester);
  }
}

/// Scorre la pagina (verticalmente) finché [finder] non è costruito e visibile.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: _topVerticalScrollable());
  await tester.pumpAndSettle();
}

/// Torna in cima alla pagina in primo piano.
Future<void> scrollToTop(WidgetTester tester) async {
  await tester.drag(_topVerticalScrollable(), const Offset(0, 5000));
  await tester.pumpAndSettle();
}

/// La lista verticale della pagina in primo piano: con una pagina aperta sopra un'altra, quella sotto resta
/// nell'albero dei widget, e la sua lista viene prima. Solo quelle che si toccano: le schede della Home non scelte
/// restano nell'albero (`IndexedStack`) ma non si vedono.
Finder _topVerticalScrollable() =>
    find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).hitTestable().last;

/// Scorre fino a [finder] e lo tocca.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await scrollTo(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
