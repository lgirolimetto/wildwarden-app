import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/rules/field/sky.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Bologna, Piazza Maggiore.
  const lat = 44.4937, lon = 11.3430;

  // Valori attesi dalle formule complete della NOAA (foglio di calcolo "NOAA Solar Calculations").
  Matcher near(DateTime expected, {int minutes = 3}) => predicate<DateTime>(
    (actual) => actual.difference(expected).inMinutes.abs() <= minutes,
    'entro $minutes minuti da $expected',
  );

  group('sole', () {
    test('solstizio d\'estate a Bologna: sorge alle 5:29 e tramonta alle 21:02 (ora legale)', () {
      final sun = sunTimes(DateTime(2026, 6, 21), lat, lon)!;
      expect(sun.sunrise, near(DateTime.utc(2026, 6, 21, 3, 29)));
      expect(sun.sunset, near(DateTime.utc(2026, 6, 21, 19, 2)));
      expect(sun.firstLight.isBefore(sun.sunrise), isTrue);
    });

    test('solstizio d\'inverno a Bologna: sorge alle 7:47 e tramonta alle 16:37', () {
      final sun = sunTimes(DateTime(2026, 12, 21), lat, lon)!;
      expect(sun.sunrise, near(DateTime.utc(2026, 12, 21, 6, 47)));
      expect(sun.sunset, near(DateTime.utc(2026, 12, 21, 15, 37)));
    });

    test('notte polare: niente alba né tramonto', () {
      expect(sunTimes(DateTime(2026, 12, 21), 80, 15), isNull);
    });
  });

  group('tratti della luce', () {
    final sun = sunTimes(DateTime(2026, 6, 21), lat, lon)!;

    test('Alba dalle prime luci a un\'ora dopo il sorgere', () {
      expect(daylightTrait(sun.firstLight.subtract(const Duration(minutes: 1)), lat, lon), isNull);
      expect(daylightTrait(sun.firstLight.add(const Duration(minutes: 1)), lat, lon), Trait.dawn);
      expect(daylightTrait(sun.sunrise.add(const Duration(minutes: 59)), lat, lon), Trait.dawn);
      expect(daylightTrait(sun.sunrise.add(const Duration(minutes: 61)), lat, lon), isNull);
    });

    test('Tramonto da un\'ora prima fino al tramonto, mai a buio fatto', () {
      expect(daylightTrait(sun.sunset.subtract(const Duration(minutes: 61)), lat, lon), isNull);
      expect(daylightTrait(sun.sunset.subtract(const Duration(minutes: 59)), lat, lon), Trait.dusk);
      expect(daylightTrait(sun.sunset.add(const Duration(minutes: 1)), lat, lon), isNull);
    });

    test('a mezzogiorno nessun tratto della luce', () {
      expect(daylightTrait(DateTime.utc(2026, 6, 21, 11), lat, lon), isNull);
    });
  });

  group('luna', () {
    test('luna piena il 3 gennaio 2026, nuova il 18 gennaio', () {
      expect(moonIllumination(DateTime.utc(2026, 1, 3, 10)), greaterThan(0.99));
      expect(moonIllumination(DateTime.utc(2026, 1, 18, 20)), lessThan(0.01));
      expect(moonTrait(DateTime(2026, 1, 3)), Trait.moon);
      expect(moonTrait(DateTime(2026, 1, 18)), Trait.newMoon);
    });

    test('tra nuova e piena crescente, tra piena e nuova calante', () {
      expect(moonTrait(DateTime(2026, 1, 25)), Trait.waxingMoon);
      expect(moonTrait(DateTime(2026, 1, 10)), Trait.waningMoon);
    });

    test('il tratto della luna vale per tutto il giorno', () {
      expect(moonTrait(DateTime(2026, 1, 3, 1)), moonTrait(DateTime(2026, 1, 3, 23)));
    });
  });

  test('tratti del cielo: la luce se c\'è, sempre la luna', () {
    expect(skyTraits(DateTime.utc(2026, 1, 3, 11), lat, lon), [Trait.moon]);
    final sun = sunTimes(DateTime(2026, 1, 3), lat, lon)!;
    expect(skyTraits(sun.sunset.subtract(const Duration(minutes: 30)), lat, lon), [Trait.dusk, Trait.moon]);
  });
}
