import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nessun tratto premia uscite rischiose: niente Notte né Dopo il temporale', () {
    final names = Trait.values.map((t) => t.name);
    expect(names, isNot(contains('night')));
    expect(names, isNot(contains('afterStorm')));
  });

  test('tratti per tipo: luce nell\'ordine del giorno, luna in quello del ciclo, poi il meteo', () {
    expect(TraitGroup.daylight.traits, [Trait.dawn, Trait.dusk]);
    expect(TraitGroup.moon.traits, [Trait.waxingMoon, Trait.moon, Trait.waningMoon, Trait.newMoon]);
    expect(TraitGroup.weather.traits, [Trait.sun, Trait.rain, Trait.fog, Trait.dew, Trait.frost]);
    // Ogni tratto sta in un gruppo, e l'ordine dei valori segue i gruppi.
    expect([for (final g in TraitGroup.values) ...g.traits], Trait.values);
  });

  test('gli id salvati negli eventi non cambiano', () {
    for (final name in ['frost', 'rain', 'fog', 'sun', 'moon', 'dew', 'dusk', 'dawn', 'newMoon']) {
      expect(Trait.values.byName(name).name, name);
    }
  });
}
