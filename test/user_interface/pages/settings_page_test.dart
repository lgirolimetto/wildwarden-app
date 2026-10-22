import 'package:druid_app/controllers/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/test_app.dart';

void main() {
  tearDown(Get.reset);

  Future<void> openSettings(WidgetTester tester) async {
    await pumpDruidApp(tester);
    await openTab(tester, 'Impostazioni');
  }

  testWidgets('scegliere una livrea cambia il tema dell\'app e la salva', (tester) async {
    final deps = registerTestDependencies();
    await openSettings(tester);
    final before = Theme.of(tester.element(find.byType(Scaffold))).colorScheme.primary;

    await tester.tap(find.byKey(const ValueKey('livery-notturna')));
    await tester.pumpAndSettle();

    final after = Theme.of(tester.element(find.byType(Scaffold))).colorScheme.primary;
    expect(after, isNot(before));
    expect(deps.preferences.values[ThemeController.liveryKey], 'notturna');
  });

  testWidgets('scegliere "Scuro" attiva il tema scuro', (tester) async {
    registerTestDependencies();
    await openSettings(tester);

    await tester.tap(find.text('Scuro'));
    await tester.pumpAndSettle();

    expect(Theme.of(tester.element(find.byType(Scaffold))).brightness, Brightness.dark);
  });
}
