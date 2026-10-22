import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late Catalog catalog;

  setUp(() => catalog = smallCatalog());

  SpeciesHint hintOf(String sci) => catalog.speciesBySci(sci)!.hint;

  group('indizi delle specie non trovate', () {
    test('stagione e quota nette: entrambe nell\'indizio', () {
      expect(
        hintOf('Helleborus viridis'),
        const SpeciesHint(family: 'Ranunculaceae', season: Season.winter, band: AltitudeBand.hill),
      );
    });

    test('stagione non netta (35%): solo famiglia e quota', () {
      expect(hintOf('Malva sylvestris'), const SpeciesHint(family: 'Malvaceae', band: AltitudeBand.plain));
    });

    test('quota non netta (53%): solo famiglia e stagione', () {
      expect(hintOf('Eranthis hyemalis'), const SpeciesHint(family: 'Ranunculaceae', season: Season.winter));
    });

    test('montagna', () {
      expect(hintOf('Fagus sylvatica').band, AltitudeBand.mountain);
    });
  });

  test('mesi migliori: i 3 più osservati, in ordine di calendario', () {
    expect(catalog.speciesBySci('Eranthis hyemalis')!.topMonths(), [1, 2, 3]);
    expect(catalog.speciesBySci('Malva sylvestris')!.topMonths(2), hasLength(2));
  });

  group('enum di supporto', () {
    test('mese → stagione', () {
      expect(Season.ofMonth(1), Season.winter);
      expect(Season.ofMonth(12), Season.winter);
      expect(Season.ofMonth(6), Season.summer);
    });

    test('quota → fascia, con limiti esclusi', () {
      expect(AltitudeBand.ofElevation(149), AltitudeBand.plain);
      expect(AltitudeBand.ofElevation(150), AltitudeBand.hill);
      expect(AltitudeBand.ofElevation(600), AltitudeBand.mountain);
    });
  });
}
