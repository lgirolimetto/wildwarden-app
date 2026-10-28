/// Raccolta della Vis nel mirino (capitolo 05, 2026-10-28): mentre si muove piano il telefono attorno alla pianta
/// l'app ne raccoglie la Vis e intanto verifica che sia vera. L'anello attorno al pulsante di scatto si riempie con
/// gli indizi dei fotogrammi; pieno, si scatta. Se dopo un po' non si riempie la Vis è "molto debole": si può
/// raccogliere comunque (poca Vis, scatto sospetto) o riprovare. Non blocca, depotenzia.
library;

/// Tempo di indizi pieni che riempie l'anello (con indizi a metà ci vuole il doppio).
const visFillTime = Duration(seconds: 5);

/// Dopo questo tempo senza anello pieno la Vis è debole.
const visPatience = Duration(seconds: 15);

/// Sopra questo zoom la profondità della scena quasi non si vede: si chiede di inquadrare prima senza zoom.
const visMaxZoom = 1.5;

/// Un fotogramma lontano dal precedente più di così non conta (app in pausa, scatto): niente salti dell'anello.
const _maxStep = Duration(milliseconds: 250);

enum VisState {
  /// Zoom troppo alto: si chiede di tornare senza zoom, il tempo non corre.
  zoomFirst,

  /// L'anello si sta riempiendo.
  gathering,

  /// Anello pieno: il pulsante è rosso, si scatta (anche zoomando).
  full,

  /// Tempo scaduto senza anello pieno: avviso "Vis molto debole".
  weak,

  /// Chi gioca ha scelto di raccogliere comunque la Vis debole.
  weakAccepted,
}

class VisGathering {
  VisState state = VisState.gathering;

  /// Quanto è pieno l'anello (0–1).
  double progress = 0;
  Duration _elapsed = Duration.zero;

  /// Si è partiti zoomati: a anello pieno si avvisa che ora si può zoomare.
  bool startedZoomed = false;

  bool get canShoot => state == VisState.full || state == VisState.weakAccepted;

  /// Un fotogramma analizzato: [step] dal precedente, [evidence] quanto dice che la pianta è vera (0–1), [zoom] in uso.
  /// Restituisce true se lo stato è cambiato.
  bool update({required Duration step, required double evidence, required double zoom}) {
    final before = state;
    if (state == VisState.full || state == VisState.weak || state == VisState.weakAccepted) return false;
    if (zoom > visMaxZoom) {
      state = VisState.zoomFirst;
      startedZoomed = true;
      return state != before;
    }
    state = VisState.gathering;
    final dt = step > _maxStep ? _maxStep : step;
    _elapsed += dt;
    progress = (progress + evidence.clamp(0, 1) * dt.inMicroseconds / visFillTime.inMicroseconds).clamp(0, 1);
    if (progress >= 1) {
      state = VisState.full;
    } else if (_elapsed >= visPatience) {
      state = VisState.weak;
    }
    return state != before;
  }

  /// "Riprova": l'anello riparte da vuoto.
  void retry() {
    state = VisState.gathering;
    progress = 0;
    _elapsed = Duration.zero;
  }

  /// "Raccogli comunque".
  void acceptWeak() {
    if (state == VisState.weak) state = VisState.weakAccepted;
  }
}
