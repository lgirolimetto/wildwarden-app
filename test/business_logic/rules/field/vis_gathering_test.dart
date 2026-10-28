import 'package:druid_app/business_logic/rules/field/vis_gathering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const frame = Duration(milliseconds: 100);

  /// Fotogrammi per [time] con gli stessi indizi e lo stesso zoom.
  void run(VisGathering vis, Duration time, {double evidence = 0, double zoom = 1}) {
    for (var t = Duration.zero; t < time; t += frame) {
      vis.update(step: frame, evidence: evidence, zoom: zoom);
    }
  }

  test('il primo scatto dopo 3 secondi, gli altri subito', () {
    final vis = VisGathering();
    run(vis, const Duration(milliseconds: 2900));
    expect(vis.canShoot, isFalse);
    expect(vis.update(step: frame, evidence: 0, zoom: 1), isTrue, reason: 'avvisa quando si può scattare');
    expect(vis.canShoot, isTrue);
    vis.shotTaken();
    expect(vis.canShoot, isTrue);
  });

  test('la Vis sale con il tempo anche da fermi: anello pieno in 30 secondi', () {
    final vis = VisGathering();
    run(vis, const Duration(seconds: 15));
    expect(vis.progress, closeTo(0.5, 0.01));
    run(vis, const Duration(seconds: 15));
    expect(vis.progress, closeTo(1, 0.01));
    run(vis, const Duration(seconds: 10));
    expect(vis.progress, 1);
  });

  test('muovendosi sale al doppio: anello pieno in 15 secondi', () {
    final vis = VisGathering();
    run(vis, const Duration(seconds: 15), evidence: 1);
    expect(vis.progress, closeTo(1, 0.01));
  });

  test('chi ha fretta raccoglie comunque, solo meno', () {
    final vis = VisGathering();
    run(vis, const Duration(seconds: 10), evidence: 1);
    expect(vis.progress, closeTo(2 / 3, 0.01));
  });

  test('con lo zoom alto il movimento non conta, la Vis sale solo con il tempo', () {
    final vis = VisGathering();
    run(vis, const Duration(seconds: 15), evidence: 1, zoom: 5);
    expect(vis.zoomed, isTrue);
    expect(vis.progress, closeTo(0.5, 0.01));
    expect(vis.moved, isFalse);
  });

  test('telefono quasi fermo per tutta la sessione: scatto sospetto', () {
    final still = VisGathering();
    run(still, const Duration(seconds: 20), evidence: 0.2);
    expect(still.moved, isFalse);

    final walking = VisGathering();
    run(walking, const Duration(seconds: 16));
    run(walking, const Duration(seconds: 4), evidence: 1);
    expect(walking.moved, isTrue, reason: '4 secondi di movimento su 20');
  });

  test('un salto lungo tra due fotogrammi (app in pausa) non riempie l\'anello di colpo', () {
    final vis = VisGathering()..update(step: const Duration(seconds: 30), evidence: 1, zoom: 1);
    expect(vis.progress, closeTo(2 * 0.25 / 30, 0.001));
  });
}
