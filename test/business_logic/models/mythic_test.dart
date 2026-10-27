import 'package:druid_app/business_logic/models/mythic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('finestra di date nello stesso anno', () {
    final window = DateWindow.fromJson({'from': '06-20', 'to': '06-26'});
    expect(window.contains(DateTime(2027, 6, 20)), isTrue);
    expect(window.contains(DateTime(2027, 6, 26, 23)), isTrue);
    expect(window.contains(DateTime(2027, 6, 27)), isFalse);
    expect(window.contains(DateTime(2027, 6, 19)), isFalse);
  });

  test('finestra di date a cavallo dell\'anno', () {
    final window = DateWindow.fromJson({'from': '12-28', 'to': '01-06'});
    expect(window.contains(DateTime(2026, 12, 31)), isTrue);
    expect(window.contains(DateTime(2027, 1, 6)), isTrue);
    expect(window.contains(DateTime(2027, 1, 7)), isFalse);
    expect(window.contains(DateTime(2026, 12, 27)), isFalse);
  });

  test('il nome di una Mitica incompleta: le parole che mancano sono "…"', () {
    final mythic = Mythic.fromJson({
      'number': 1,
      'id': 'm',
      'nameParts': [
        {'it': 'La Lanterna'},
        {'it': 'di Santa'},
        {'it': 'Lucia'},
      ],
      'story': {'it': ''},
      'ingredients': <Object>[],
      'effect': 'omen',
      'effectText': {'it': ''},
    });
    expect(mythic.name('it'), 'La Lanterna di Santa Lucia');
    expect(mythic.name('it', missing: 1), 'La Lanterna di Santa …');
    expect(mythic.name('it', missing: 3), '… … …');
  });
}
