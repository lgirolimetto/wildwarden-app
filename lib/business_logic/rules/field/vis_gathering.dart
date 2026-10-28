/// Raccolta della Vis nel mirino (capitolo 05, 2026-10-28): mentre si fotografa la pianta (intera, foglia, fiore) e ci
/// si muove tra uno scatto e l'altro l'app ne raccoglie la Vis e intanto verifica che sia vera. L'anello attorno al
/// pulsante di scatto si riempie lungo tutta la sessione: ogni scatto chiede la sua parte di anello, raccolta dopo lo
/// scatto precedente; raggiunta, il pulsante è rosso. Se una parte non si riempie la Vis è "molto debole": si può
/// raccogliere comunque (poca Vis, scatto sospetto) o riprovare. Non blocca, depotenzia.
library;

/// Gli scatti di una sessione (intera, foglia, fiore): l'anello è diviso in tante parti.
const visShots = 3;

/// Tempo di indizi pieni che riempie l'anello intero (con indizi a metà ci vuole il doppio): 3 secondi per scatto.
const visFillTime = Duration(seconds: 9);

/// Dopo questo tempo senza la parte di anello di uno scatto la Vis è debole.
const visPatience = Duration(seconds: 15);

/// Sopra questo zoom la profondità della scena quasi non si vede: l'anello non cresce, si chiede di inquadrare senza
/// zoom (raccolta la parte, si può zoomare e scattare).
const visMaxZoom = 1.5;

/// Un fotogramma lontano dal precedente più di così non conta (app in pausa, scatto): niente salti dell'anello.
const _maxStep = Duration(milliseconds: 250);

enum VisState {
  /// Zoom troppo alto: si chiede di tornare senza zoom, il tempo non corre.
  zoomFirst,

  /// La parte di anello dello scatto si sta riempiendo.
  gathering,

  /// Parte raggiunta: il pulsante è rosso, si scatta (anche zoomando).
  ready,

  /// Tempo scaduto senza la parte di anello: avviso "Vis molto debole".
  weak,

  /// Chi gioca ha scelto di raccogliere comunque la Vis debole per questo scatto.
  weakAccepted,
}

class VisGathering {
  VisState state = VisState.gathering;

  /// Quanto è pieno l'anello (0–1), su tutta la sessione.
  double progress = 0;

  /// Scatti già fatti.
  int shots = 0;

  /// Almeno uno scatto è stato fatto con la Vis debole.
  bool anyWeak = false;

  /// La Vis mancata negli scatti fatti con "Raccogli comunque": il prossimo scatto riparte dalla sua parte (non deve
  /// recuperarla), ma alla fine la Vis raccolta è minore.
  double _missed = 0;

  Duration _elapsed = Duration.zero;

  /// Si era zoomati prima di raggiungere la parte: a parte raggiunta si avvisa che ora si può zoomare.
  bool zoomedWhileGathering = false;

  /// La parte di anello che serve per il prossimo scatto.
  double get target => (shots + 1) / visShots;

  bool get canShoot => state == VisState.ready || state == VisState.weakAccepted;

  /// Quanto Vis porta la sessione finita dopo [shots] scatti (0–1): la parte raccolta di quella che serviva. Saltare il
  /// fiore non toglie niente.
  double get gathered => shots == 0 ? 0 : ((progress - _missed) / (shots / visShots)).clamp(0, 1);

  /// La Vis è piena: ogni scatto ha avuto la sua parte, senza "Raccogli comunque".
  bool get full => !anyWeak && shots > 0;

  /// Un fotogramma analizzato: [step] dal precedente, [evidence] quanto dice che la pianta è vera (0–1), [zoom] in uso.
  /// Restituisce true se lo stato è cambiato.
  bool update({required Duration step, required double evidence, required double zoom}) {
    final before = state;
    if (state == VisState.ready || state == VisState.weak || state == VisState.weakAccepted) return false;
    if (zoom > visMaxZoom) {
      state = VisState.zoomFirst;
      zoomedWhileGathering = true;
      return state != before;
    }
    state = VisState.gathering;
    final dt = step > _maxStep ? _maxStep : step;
    _elapsed += dt;
    progress = (progress + evidence.clamp(0, 1) * dt.inMicroseconds / visFillTime.inMicroseconds).clamp(0, target);
    if (progress >= target - 1e-9) {
      progress = target;
      state = VisState.ready;
    } else if (_elapsed >= visPatience) {
      state = VisState.weak;
    }
    return state != before;
  }

  /// Uno scatto fatto: si comincia a raccogliere la parte del prossimo.
  void shotTaken() {
    if (state == VisState.weakAccepted) {
      anyWeak = true;
      _missed += target - progress;
      progress = target;
    }
    shots++;
    state = VisState.gathering;
    _elapsed = Duration.zero;
    zoomedWhileGathering = false;
  }

  /// "Riprova": si riparte a raccogliere la parte di questo scatto, con il tempo da capo.
  void retry() {
    state = VisState.gathering;
    progress = shots / visShots;
    _elapsed = Duration.zero;
  }

  /// "Raccogli comunque".
  void acceptWeak() {
    if (state == VisState.weak) state = VisState.weakAccepted;
  }
}
