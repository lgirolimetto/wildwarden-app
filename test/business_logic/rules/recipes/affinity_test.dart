import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/rules/recipes/affinity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  final catalog = smallCatalog();

  void expectProfile(String sci, LightLiking? light, MoistureLiking? moisture, List<AltitudeBand> bands) {
    final p = affinityProfile(catalog.speciesBySci(sci)!);
    expect(p.light, light, reason: sci);
    expect(p.moisture, moisture, reason: sci);
    expect(p.bands, bands, reason: sci);
  }

  test('la luce, l\'umidità solo se netta, le fasce di quota dove la pianta sta davvero', () {
    expectProfile('Malva sylvestris', LightLiking.full, null, [AltitudeBand.plain]);
    expectProfile('Fagus sylvatica', LightLiking.shade, null, [AltitudeBand.mountain]);
    expectProfile('Eranthis hyemalis', LightLiking.half, null, [AltitudeBand.plain, AltitudeBand.hill]);
  });
}
