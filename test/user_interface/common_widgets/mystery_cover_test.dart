import 'package:druid_app/user_interface/common_widgets/mystery_cover.dart';
import 'package:druid_app/user_interface/theme/app_theme.dart';
import 'package:druid_app/user_interface/theme/liveries/sottobosco_livery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<Color> pumpCover(WidgetTester tester, String seed, {int? tint}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(const SottoboscoLivery(), Brightness.light),
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 160,
            child: MysteryCover(seed: seed, tint: tint),
          ),
        ),
      ),
    );
    return tester
        .widget<ColoredBox>(find.descendant(of: find.byType(MysteryCover), matching: find.byType(ColoredBox)).first)
        .color;
  }

  testWidgets('la copertina usa la tinta imposta e mostra il "?"', (tester) async {
    expect(await pumpCover(tester, 'pozione-prova-comune', tint: 0xC9EBAD), const Color(0xFFC9EBAD));
    expect(find.text('?'), findsOneWidget);
    expect(find.byType(Image), findsNothing, reason: 'nessuna foto da scaricare');
  });

  testWidgets('senza tinta: un pastello stabile per id, diverso tra id diversi', (tester) async {
    final first = await pumpCover(tester, 'pozione-prova-comune');
    final again = await pumpCover(tester, 'pozione-prova-comune');
    final other = await pumpCover(tester, 'infuso-prova-faggio');
    expect(first, again);
    expect(first, isNot(other));
    expect(HSLColor.fromColor(first).lightness, greaterThan(0.7));
  });
}
