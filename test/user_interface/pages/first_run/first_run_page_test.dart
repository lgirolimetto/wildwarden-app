import 'package:druid_app/business_logic/interfaces/i_permissions.dart';
import 'package:druid_app/business_logic/rules/first_run.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

void main() {
  tearDown(Get.reset);

  Future<void> tap(WidgetTester tester, String key) => scrollAndTap(tester, find.byKey(ValueKey(key)));

  testWidgets('primo avvio: regole, fotocamera, posizione, pronto; poi la Home', (tester) async {
    final permissions = FakePermissions();
    final app = registerTestDependencies(firstRunDone: false, permissions: permissions);
    await pumpDruidApp(tester);

    expect(find.text('Benvenuto in Druid'), findsOneWidget);
    expect(find.byType(ClayNavBar), findsNothing);
    expect(find.text('Fotografa, non raccogliere'), findsOneWidget);
    await scrollTo(tester, find.text('Le piante non si mangiano'));
    await tap(tester, 'first-run-accept');
    expect(app.preferences.values[termsAcceptedKey], '$termsVersion');

    expect(find.text('Le foto delle piante'), findsOneWidget);
    await tap(tester, 'first-run-allow');
    expect(find.text('La posizione'), findsOneWidget);
    await tap(tester, 'first-run-allow');
    expect(permissions.requests, ['camera', 'location']);

    expect(find.text('Sei pronto a giocare'), findsOneWidget);
    expect(find.byKey(const ValueKey('first-run-tutorial')), findsOneWidget);
    await tap(tester, 'first-run-later');

    expect(app.preferences.values[firstRunDoneKey], '1');
    expect(find.byType(ClayNavBar), findsOneWidget);
    // "Più tardi": il tutorial resta proposto in Home.
    expect(find.byKey(const ValueKey('tutorial-intro')), findsOneWidget);
  });

  testWidgets('"Fai il tutorial": in Home il primo passo', (tester) async {
    registerTestDependencies(firstRunDone: false);
    await pumpDruidApp(tester);
    await tap(tester, 'first-run-accept');
    await tap(tester, 'first-run-allow');
    await tap(tester, 'first-run-allow');
    await tap(tester, 'first-run-tutorial');

    expect(find.byKey(const ValueKey('tutorial-photograph')), findsOneWidget);
  });

  testWidgets('permessi negati: si spiega che cosa non funziona, si aprono le impostazioni, si va avanti', (
    tester,
  ) async {
    final permissions = FakePermissions(
      camera: PermissionOutcome.deniedForever,
      location: PermissionOutcome.approximate,
    );
    registerTestDependencies(firstRunDone: false, permissions: permissions);
    await pumpDruidApp(tester);
    await tap(tester, 'first-run-accept');

    await tap(tester, 'first-run-allow');
    expect(find.textContaining('Senza fotocamera non puoi Incontrare le piante'), findsOneWidget);
    await tap(tester, 'first-run-settings');
    expect(permissions.requests, ['camera', 'settings']);
    await tap(tester, 'first-run-next');

    await tap(tester, 'first-run-allow');
    expect(find.textContaining('Con la posizione approssimativa'), findsOneWidget);
    await tap(tester, 'first-run-next');
    expect(find.text('Sei pronto a giocare'), findsOneWidget);
  });

  testWidgets('regole accettate ma onboarding interrotto: si riparte dalle regole', (tester) async {
    registerTestDependencies(firstRunDone: false, preferences: {termsAcceptedKey: '$termsVersion'});
    await pumpDruidApp(tester);
    expect(find.text('Benvenuto in Druid'), findsOneWidget);
  });
}
