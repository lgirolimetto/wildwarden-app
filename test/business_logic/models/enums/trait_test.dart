import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nessun tratto premia uscite rischiose: niente Notte né Dopo il temporale', () {
    final names = Trait.values.map((t) => t.name);
    expect(names, isNot(contains('night')));
    expect(names, isNot(contains('afterStorm')));
  });
}
