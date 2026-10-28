import 'package:druid_app/business_logic/rules/field/vis_gathering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const frame = Duration(milliseconds: 100);

  /// Fotogrammi per [time] con gli stessi indizi e lo stesso zoom.
  void run(VisGathering vis, Duration time, {double evidence = 1, double zoom = 1}) {
    for (var t = Duration.zero; t < time; t += frame) {
      vis.update(step: frame, evidence: evidence, zoom: zoom);
    }
  }

  test('indizi pieni: l\'anello si riempie in 2,5 secondi e si può scattare', () {
    final vis = VisGathering();
    run(vis, const Duration(milliseconds: 1200));
    expect(vis.progress, closeTo(0.48, 0.01));
    expect(vis.canShoot, isFalse);
    run(vis, const Duration(milliseconds: 1400));
    expect(vis.state, VisState.full);
    expect(vis.canShoot, isTrue);
  });

  test('telefono fermo (nessun indizio): dopo 10 secondi la Vis è debole', () {
    final vis = VisGathering();
    run(vis, const Duration(milliseconds: 9900), evidence: 0);
    expect(vis.state, VisState.gathering);
    run(vis, frame, evidence: 0);
    expect(vis.state, VisState.weak);
    expect(vis.canShoot, isFalse);
  });

  test('Vis debole: "Raccogli comunque" fa scattare, "Riprova" svuota l\'anello', () {
    final vis = VisGathering();
    run(vis, visPatience, evidence: 0.1);
    expect(vis.state, VisState.weak);
    vis.retry();
    expect((vis.state, vis.progress), (VisState.gathering, 0));
    run(vis, visPatience, evidence: 0);
    vis.acceptWeak();
    expect(vis.state, VisState.weakAccepted);
    expect(vis.canShoot, isTrue);
  });

  test('con lo zoom alto si chiede di inquadrare prima senza zoom e il tempo non corre', () {
    final vis = VisGathering();
    run(vis, const Duration(seconds: 20), zoom: 5);
    expect(vis.state, VisState.zoomFirst);
    expect(vis.progress, 0);
    run(vis, visFillTime + frame);
    expect(vis.state, VisState.full);
    expect(vis.startedZoomed, isTrue);
  });

  test('a anello pieno si può zoomare: resta pieno', () {
    final vis = VisGathering();
    run(vis, visFillTime + frame);
    run(vis, const Duration(seconds: 1), zoom: 5);
    expect(vis.state, VisState.full);
  });

  test('un salto lungo tra due fotogrammi (app in pausa) non riempie l\'anello di colpo', () {
    final vis = VisGathering()..update(step: const Duration(seconds: 30), evidence: 1, zoom: 1);
    expect(vis.progress, closeTo(0.1, 0.001));
    expect(vis.state, VisState.gathering);
  });
}
