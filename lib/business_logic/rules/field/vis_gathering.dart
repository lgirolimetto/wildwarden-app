/// Raccolta della Vis nel mirino (capitoli 05 e 02, 2026-10-28): la Vis si raccoglie lungo tutta la sessione delle
/// foto (intera, foglia, fiore). Sale con il tempo, e più in fretta muovendosi: chi ha pazienza raccoglie di più, chi
/// ha fretta raccoglie comunque, solo meno. Il movimento lungo gli scatti è anche la verifica provvisoria che davanti
/// ci sia una scena vera (quella vera del blocco 5 guarda la parallasse); se il telefono è rimasto quasi fermo tutto il
/// tempo lo scatto è sospetto, senza fermare niente.
library;

/// Il primo scatto si può fare dopo questo tempo: GPS e primi fotogrammi. Gli altri subito.
const visFirstShotAfter = Duration(seconds: 3);

/// Tempo che riempie l'anello con il solo tempo che passa (telefono fermo o zoomato).
const visTimeFill = Duration(seconds: 30);

/// Con il movimento pieno l'anello si riempie in metà tempo (15 s): il movimento vale quanto il tempo.
const visMotionFill = Duration(seconds: 30);

/// Sopra questo zoom il movimento non conta: la profondità della scena quasi non si vede.
const visMaxZoom = 1.5;

/// Il movimento conta da questi indizi in su (0–1).
const _movingEvidence = 0.5;

/// Sotto questa parte della sessione passata in movimento lo scatto è sospetto.
const visMinMovingShare = 0.15;

/// Un fotogramma lontano dal precedente più di così non conta (app in pausa, scatto): niente salti dell'anello.
const _maxStep = Duration(milliseconds: 250);

class VisGathering {
  /// Quanto è pieno l'anello (0–1): la Vis raccolta.
  double progress = 0;

  /// Scatti già fatti.
  int shots = 0;

  Duration _elapsed = Duration.zero;
  Duration _moving = Duration.zero;

  /// Il movimento non conta perché lo zoom è alto.
  bool zoomed = false;

  bool get canShoot => shots > 0 || _elapsed >= visFirstShotAfter;

  /// Il telefono si è mosso abbastanza durante la sessione (verifica provvisoria passata).
  bool get moved => _elapsed > Duration.zero && _moving.inMicroseconds / _elapsed.inMicroseconds >= visMinMovingShare;

  /// Un fotogramma analizzato: [step] dal precedente, [evidence] quanto dice che la scena è vera (0–1), [zoom] in uso.
  /// Restituisce true se si può scattare per la prima volta.
  bool update({required Duration step, required double evidence, required double zoom}) {
    final couldShoot = canShoot;
    final dt = step > _maxStep ? _maxStep : step;
    zoomed = zoom > visMaxZoom;
    final motion = zoomed ? 0.0 : evidence.clamp(0.0, 1.0);
    _elapsed += dt;
    if (motion >= _movingEvidence) _moving += dt;
    final micros = dt.inMicroseconds;
    progress = (progress + micros / visTimeFill.inMicroseconds + motion * micros / visMotionFill.inMicroseconds).clamp(
      0,
      1,
    );
    return !couldShoot && canShoot;
  }

  void shotTaken() => shots++;
}
