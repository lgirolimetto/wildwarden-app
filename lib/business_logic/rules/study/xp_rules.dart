/// Punti esperienza (decisione 🟢 in `druid_decisioni.md`: anche il primo errore insegna).
///
/// Numeri di partenza dal simulatore dell'economia (capitolo 02, "Numeri di partenza dal simulatore", 2026-10-26):
/// si confermano giocando.
abstract final class XpRules {
  /// Primo errore su un fatto: una sola volta per fatto, per non premiare chi sbaglia apposta.
  static const firstMistake = 2;

  /// Risposta giusta dopo aver visto la soluzione nella stessa sessione.
  static const correctAfterMistake = 5;
  static const correctFirstTry = 10;

  /// PE di un ripasso ricordato secondo la scatola del fatto prima del ripasso (indice = scatola, vedi
  /// `reviewIntervalsDays`): pieni finché il fatto non è consolidato, poi pochi, poi niente. Con 15 PE per sempre i
  /// ripassi facevano il 70–90 % della carriera.
  static const reviewByBox = [0, 5, 5, 2, 1, 0, 0];
  static const levelPassed = 20;
  static const mastery = 50;
  static const desiderataFulfilled = 15;

  /// Ogni raccolta vale PE (decisione 🟢 "economia dei PE"): sono reali da subito, perché vengono dal campo.
  static const essenceDrawn = 30;

  /// Le prime [essencesFullPerDay] essenze del giorno valgono pieno, le successive [essenceAfterFull]: chi esce tanto
  /// va più veloce, ma non a dismisura.
  static const essencesFullPerDay = 5;
  static const essenceAfterFull = 0.3;

  /// PE di un'essenza, sapendo quante se ne sono già attinte oggi.
  static int essence({required int drawnToday}) =>
      drawnToday < essencesFullPerDay ? essenceDrawn : (essenceDrawn * essenceAfterFull).round();

  /// PE di una risposta durante lo studio di un livello.
  static int learning({
    required bool correct,
    required bool wrongEarlierInSession,
    required bool mistakeRewardedBefore,
  }) {
    if (correct) return wrongEarlierInSession ? correctAfterMistake : correctFirstTry;
    return mistakeRewardedBefore ? 0 : firstMistake;
  }

  static int review({required bool correct, required int box}) =>
      correct ? reviewByBox[box.clamp(0, reviewByBox.length - 1)] : 0;
}

/// Titoli del giocatore in base ai PE di carriera (incassati: i PE virtuali non contano).
///
/// Viandante alla prima essenza, poi tarati sul camminatore del weekend: Cercatore in un mese, Custode in 2,
/// Botanomante in 7–8 (simulatore, 2026-10-26).
enum Rank {
  apprentice(0),
  wanderer(50),
  seeker(1000),
  warden(3500),
  botanomancer(18000);

  const Rank(this.minXp);

  final int minXp;

  static Rank of(int xp) => Rank.values.lastWhere((r) => xp >= r.minXp);

  Rank? get next => index + 1 < Rank.values.length ? Rank.values[index + 1] : null;
}
