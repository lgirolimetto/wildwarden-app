import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/rules/recipes/affixes.dart';
import 'package:druid_app/user_interface/common_widgets/potion_vessel.dart';
import 'package:druid_app/user_interface/theme/app_theme.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/liveries/feltro_livery.dart';
import 'package:druid_app/user_interface/theme/liveries/potion_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('un colore del liquido per ogni tratto, di giorno e di sera', () {
    for (final brightness in Brightness.values) {
      expect(potionTraitColors(brightness), hasLength(Trait.values.length));
      final tokens = buildTheme(const FeltroLivery(), brightness).extension<DruidTokens>()!;
      expect(tokens.traitColor(Trait.frost.index), potionTraitColors(brightness)[Trait.frost.index]);
    }
  });

  test('ogni base ha il suo recipiente, diverso dalle altre e da quello delle Mitiche', () {
    final shapes = RecipeBase.values.map(VesselShape.of).toSet();
    expect(shapes, hasLength(RecipeBase.values.length));
    expect(shapes, isNot(contains(VesselShape.starred)));
  });

  testWidgets('tutti i recipienti si disegnano pieni (uno o due strati) e vuoti', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(const FeltroLivery(), Brightness.light),
        home: Scaffold(
          body: Wrap(
            children: [
              for (final shape in VesselShape.values) ...[
                PotionVessel(shape: shape, liquids: const [Colors.blue], size: 48),
                PotionVessel(shape: shape, liquids: const [Colors.blue, Colors.amber], size: 48),
                PotionVessel(shape: shape, size: 48, semanticLabel: 'vuoto'),
              ],
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(PotionVessel), findsNWidgets(VesselShape.values.length * 3));
  });
}
