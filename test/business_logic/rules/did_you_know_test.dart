import 'package:druid_app/business_logic/rules/did_you_know.dart';
import 'package:druid_app/controllers/did_you_know/did_you_know_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  final today = DateTime(2027, 2, 14, 9);

  test('uno al giorno, prima quelli non visti, nell\'ordine (prima la sicurezza)', () {
    expect(didYouKnowToday(seen: {}, lastShown: null, now: today), DidYouKnow.storm);
    expect(
      didYouKnowToday(seen: {DidYouKnow.storm}, lastShown: today.subtract(const Duration(days: 1)), now: today),
      DidYouKnow.daylight,
    );
    expect(
      didYouKnowToday(seen: {DidYouKnow.storm}, lastShown: today.subtract(const Duration(hours: 1)), now: today),
      isNull,
    );
  });

  test('il controller ricorda i visti; visti tutti si ricomincia; quello della regola compare una volta', () async {
    final prefs = InMemoryPreferences();
    final clock = FakeClock(today);
    final controller = DidYouKnowController(prefs, clock);
    expect(await controller.today(), DidYouKnow.storm);
    expect(await controller.today(), isNull, reason: 'uno al giorno');
    for (var i = 1; i < DidYouKnow.values.length; i++) {
      clock.advance(const Duration(days: 1));
      expect(await controller.today(), DidYouKnow.values[i]);
    }
    clock.advance(const Duration(days: 1));
    expect(await controller.today(), DidYouKnow.storm);

    final fresh = DidYouKnowController(InMemoryPreferences(), clock);
    expect(await fresh.firstTime(DidYouKnow.storm), DidYouKnow.storm);
    expect(await fresh.firstTime(DidYouKnow.storm), isNull);
    expect(await DidYouKnowController(InMemoryPreferences(), clock, enabled: false).today(), isNull);
  });
}
