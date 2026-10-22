import 'package:druid_app/user_interface/common_widgets/mystery_cover.dart';
import 'package:druid_app/user_interface/theme/app_theme.dart';
import 'package:druid_app/user_interface/theme/liveries/sottobosco_livery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  Future<Color> pumpCover(WidgetTester tester, String sci) async {
    final species = smallCatalog().speciesBySci(sci)!;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(const SottoboscoLivery(), Brightness.light),
        home: Scaffold(
          body: SizedBox(width: 200, height: 160, child: MysteryCover(species: species)),
        ),
      ),
    );
    return tester
        .widget<ColoredBox>(find.descendant(of: find.byType(MysteryCover), matching: find.byType(ColoredBox)).first)
        .color;
  }

  testWidgets('la copertina usa la tinta della specie e mostra il "?"', (tester) async {
    expect(await pumpCover(tester, 'Helleborus viridis'), const Color(0xFFC9EBAD));
    expect(find.text('?'), findsOneWidget);
    expect(find.byType(Image), findsNothing, reason: 'nessuna foto da scaricare per le specie da trovare');
  });

  testWidgets('senza tinta nel catalogo usa un pastello stabile', (tester) async {
    final first = await pumpCover(tester, 'Fagus sylvatica');
    final second = await pumpCover(tester, 'Fagus sylvatica');
    expect(first, second);
    expect(HSLColor.fromColor(first).lightness, greaterThan(0.7));
  });
}
