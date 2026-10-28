import 'package:druid_app/business_logic/rules/field/vis_gathering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const frame = Duration(milliseconds: 100);
  const perShot = Duration(seconds: 3);

  /// Fotogrammi per [time] con gli stessi indizi e lo stesso zoom.
  void run(VisGathering vis, Duration time, {double evidence = 1, double zoom = 1}) {
    for (var t = Duration.zero; t < time; t += frame) {
      vis.update(step: frame, evidence: evidence, zoom: zoom);
    }
  }

  test('ogni scatto chiede la sua parte di anello: 3 secondi di indizi pieni, poi il pulsante è rosso', () {
    final vis = VisGathering();
    run(vis, const Duration(milliseconds: 1500));
    expect(vis.progress, closeTo(1 / 6, 0.01));
    expect(vis.canShoot, isFalse);
    run(vis, const Duration(milliseconds: 1600));
    expect(vis.state, VisState.ready);
    expect(vis.progress, closeTo(1 / 3, 0.001), reason: 'l\'anello si ferma alla parte dello scatto');
  });

  test('tre scatti con la Vis piena: l\'anello intero, Vis piena', () {
    final vis = VisGathering();
    for (var i = 0; i < visShots; i++) {
      run(vis, perShot + frame);
      expect(vis.canShoot, isTrue);
      vis.shotTaken();
      expect(vis.canShoot, isFalse, reason: 'dopo lo scatto si raccoglie la parte del prossimo');
    }
    expect(vis.progress, closeTo(1, 0.001));
    expect(vis.full, isTrue);
  });

  test('saltare il fiore non toglie Vis', () {
    final vis = VisGathering();
    for (var i = 0; i < 2; i++) {
      run(vis, perShot + frame);
      vis.shotTaken();
    }
    expect(vis.gathered, closeTo(1, 0.001));
    expect(vis.full, isTrue);
  });

  test('telefono fermo: dopo 15 secondi la Vis è debole; "Raccogli comunque" scatta ma la Vis non è piena', () {
    final vis = VisGathering();
    run(vis, const Duration(milliseconds: 14900), evidence: 0);
    expect(vis.state, VisState.gathering);
    run(vis, frame, evidence: 0);
    expect(vis.state, VisState.weak);
    vis.acceptWeak();
    expect(vis.canShoot, isTrue);
    vis.shotTaken();
    run(vis, perShot + frame);
    vis.shotTaken();
    expect(vis.anyWeak, isTrue);
    expect(vis.full, isFalse);
    expect(vis.gathered, closeTo(0.5, 0.01), reason: 'il primo scatto senza Vis, il secondo pieno');
  });

  test('"Riprova" riparte dalla parte già raccolta con il tempo da capo', () {
    final vis = VisGathering();
    run(vis, perShot + frame);
    vis.shotTaken();
    run(vis, visPatience, evidence: 0.05);
    expect(vis.state, VisState.weak);
    vis.retry();
    expect(vis.state, VisState.gathering);
    expect(vis.progress, closeTo(1 / 3, 0.001));
  });

  test('con lo zoom alto l\'anello non cresce e il tempo non corre; raggiunta la parte si può zoomare', () {
    final vis = VisGathering();
    run(vis, const Duration(seconds: 20), zoom: 5);
    expect(vis.state, VisState.zoomFirst);
    expect(vis.progress, 0);
    expect(vis.zoomedWhileGathering, isTrue);
    run(vis, perShot + frame);
    expect(vis.state, VisState.ready);
    run(vis, const Duration(seconds: 1), zoom: 5);
    expect(vis.state, VisState.ready);
  });

  test('un salto lungo tra due fotogrammi (app in pausa) non riempie l\'anello di colpo', () {
    final vis = VisGathering()..update(step: const Duration(seconds: 30), evidence: 1, zoom: 1);
    expect(vis.progress, closeTo(0.25 / 9, 0.001));
    expect(vis.state, VisState.gathering);
  });
}
