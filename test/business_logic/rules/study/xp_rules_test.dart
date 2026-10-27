import 'package:druid_app/business_logic/rules/study/review_schedule.dart';
import 'package:druid_app/business_logic/rules/study/xp_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le prime 5 essenze del giorno valgono pieno, le successive il 30 %', () {
    expect(XpRules.essence(drawnToday: 0), 30);
    expect(XpRules.essence(drawnToday: 4), 30);
    expect(XpRules.essence(drawnToday: 5), 9);
    expect(XpRules.essence(drawnToday: 12), 9);
  });

  test('il ripasso ricordato vale meno man mano che il fatto si consolida, poi niente', () {
    expect([for (var box = 1; box <= maxBox; box++) XpRules.review(correct: true, box: box)], [5, 5, 2, 1, 0, 0]);
    expect(XpRules.review(correct: false, box: 1), 0);
  });

  test('una scatola per ogni intervallo di ripasso', () {
    expect(XpRules.reviewByBox, hasLength(reviewIntervalsDays.length));
    expect(reviewIntervalsDays.last, 180);
  });
}
