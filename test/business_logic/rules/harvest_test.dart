import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/harvest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 10, 27, 10);
  final yesterday = DateTime(2026, 10, 26, 18);

  EssenceDrawn draw(String sci, DateTime at) =>
      EssenceDrawn(speciesSci: sci, simulated: true, vis: 10, xp: 30, occurredAt: at);

  test('le essenze di oggi sono le specie attinte oggi', () {
    final state = GameState.replay([
      draw('Malva sylvestris', yesterday),
      draw('Helleborus viridis', yesterday),
      draw('Helleborus viridis', today),
      draw('Eranthis hyemalis', today),
    ]);

    expect(drawsToday(state, today), 2);
    expect(drawsToday(state, yesterday), 1);
  });
}
