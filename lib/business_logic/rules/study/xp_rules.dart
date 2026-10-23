/// Punti esperienza (decisione 🟢 in `druid_decisioni.md`: anche il primo errore insegna).
abstract final class XpRules {
  /// Primo errore su un fatto: una sola volta per fatto, per non premiare chi sbaglia apposta.
  static const firstMistake = 2;

  /// Risposta giusta dopo aver visto la soluzione nella stessa sessione.
  static const correctAfterMistake = 5;
  static const correctFirstTry = 10;

  /// Risposta giusta in un ripasso a distanza di giorni: ricordare vale di più.
  static const reviewRemembered = 15;
  static const levelPassed = 20;
  static const mastery = 50;
  static const desiderataFulfilled = 15;

  /// Ogni raccolta vale PE (decisione 🟢 "economia dei PE"): sono reali da subito, perché vengono dal campo.
  static const essenceDrawn = 10;

  /// PE di una risposta durante lo studio di un livello.
  static int learning({
    required bool correct,
    required bool wrongEarlierInSession,
    required bool mistakeRewardedBefore,
  }) {
    if (correct) return wrongEarlierInSession ? correctAfterMistake : correctFirstTry;
    return mistakeRewardedBefore ? 0 : firstMistake;
  }

  static int review({required bool correct}) => correct ? reviewRemembered : 0;
}

/// Titoli del giocatore in base ai PE di carriera (incassati: i PE virtuali non contano).
enum Rank {
  apprentice(0),
  wanderer(100),
  seeker(300),
  warden(700),
  botanomancer(1500);

  const Rank(this.minXp);

  final int minXp;

  static Rank of(int xp) => Rank.values.lastWhere((r) => xp >= r.minXp);

  Rank? get next => index + 1 < Rank.values.length ? Rank.values[index + 1] : null;
}
