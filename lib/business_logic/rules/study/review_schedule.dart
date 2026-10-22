/// Ripasso a intervalli crescenti (sistema di Leitner): ogni fatto sta in una "scatola";
/// ricordarlo lo sposta nella successiva, dimenticarlo lo riporta alla prima.
///
/// Indice = scatola. La scatola 0 è "non ancora imparato".
const reviewIntervalsDays = [0, 1, 3, 7, 21];

const maxBox = 4;

/// Scatola dalla quale un fatto si considera consolidato (ricordato a 1 e 3 giorni): serve per la maestria.
const consolidatedBox = 3;

DateTime startOfDay(DateTime t) => DateTime(t.year, t.month, t.day);

DateTime addDays(DateTime day, int days) => DateTime(day.year, day.month, day.day + days);

/// Avanzamento di un singolo fatto.
class FactProgress {
  /// Il fatto è stato superato almeno una volta in un livello.
  final bool learned;
  final int box;

  /// Giorno da cui il fatto è di nuovo da ripassare.
  final DateTime? dueOn;

  /// Il primo errore su questo fatto è già stato premiato con PE.
  final bool mistakeRewarded;

  const FactProgress({this.learned = false, this.box = 0, this.dueOn, this.mistakeRewarded = false});

  static const initial = FactProgress();

  FactProgress afterLearningAnswer({required bool correct}) =>
      correct ? this : FactProgress(learned: learned, box: box, dueOn: dueOn, mistakeRewarded: true);

  /// Il livello del fatto è stato superato: entra nei ripassi, il primo domani.
  FactProgress afterLevelPassed(DateTime at) {
    final newBox = box < 1 ? 1 : box;
    return FactProgress(
      learned: true,
      box: newBox,
      dueOn: addDays(startOfDay(at), reviewIntervalsDays[newBox]),
      mistakeRewarded: mistakeRewarded,
    );
  }

  FactProgress afterReview({required bool correct, required DateTime at}) {
    final newBox = correct ? (box + 1).clamp(1, maxBox) : 1;
    return FactProgress(
      learned: true,
      box: newBox,
      dueOn: addDays(startOfDay(at), reviewIntervalsDays[newBox]),
      mistakeRewarded: mistakeRewarded,
    );
  }

  bool isDue(DateTime now) => learned && dueOn != null && !startOfDay(now).isBefore(dueOn!);

  bool get consolidated => box >= consolidatedBox;
}
