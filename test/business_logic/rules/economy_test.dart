import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/rules/economy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('il Bottino dell\'Esperienza costa di più a ogni grado', () {
    expect([for (final g in Grade.values) EconomyRules.troveCost(g)], [150, 500, 3000, 8000]);
  });

  test('il regalo "bentornato" fa pagare il raro quanto un non comune', () {
    expect(EconomyRules.welcomeTrovePrice, EconomyRules.troveCost(Grade.uncommon));
    expect(EconomyRules.welcomeTrovePrice, lessThan(EconomyRules.troveCost(Grade.rare)));
  });

  test('le pozioni valgono di più a ogni grado', () {
    expect([for (final g in Grade.values) EconomyRules.potionXp(g)], [15, 40, 100, 250]);
  });
}
