import 'package:druid_app/business_logic/rules/first_run.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  test("l'onboarding si apre finché le regole non sono accettate e non è arrivato alla fine", () {
    expect(needsFirstRun(InMemoryPreferences()), isTrue);
    expect(needsFirstRun(InMemoryPreferences({termsAcceptedKey: '$termsVersion'})), isTrue);
    expect(needsFirstRun(InMemoryPreferences({firstRunDoneKey: '1'})), isTrue);
    expect(needsFirstRun(InMemoryPreferences({termsAcceptedKey: '$termsVersion', firstRunDoneKey: '1'})), isFalse);
  });

  test('regole di una versione vecchia: si chiedono di nuovo', () {
    final old = InMemoryPreferences({termsAcceptedKey: '${termsVersion - 1}', firstRunDoneKey: '1'});
    expect(acceptedTermsVersion(old), termsVersion - 1);
    expect(needsFirstRun(old), isTrue);
  });
}
