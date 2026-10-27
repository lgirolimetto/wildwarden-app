import 'package:druid_app/business_logic/models/enums/grade.dart';

/// Prezzi e premi dell'economia dei PE: Bottino dell'Esperienza e pozioni (tappa C).
///
/// Numeri di partenza dal simulatore dell'economia (capitolo 02, "Numeri di partenza dal simulatore", 2026-10-26):
/// si confermano giocando. I PE guadagnati con studio ed essenze stanno in `XpRules`.
abstract final class EconomyRules {
  /// Costo in PE del saldo di un Bottino dell'Esperienza.
  static int troveCost(Grade grade) => switch (grade) {
    Grade.common => 150,
    Grade.uncommon => 500,
    Grade.rare => 3000,
    Grade.mythic => 8000,
  };

  /// Prezzo di favore del primo Bottino raro con il regalo "bentornato": quanto un non comune.
  static const welcomeTrovePrice = 500;

  /// Il regalo "bentornato" arriva dopo 4 settimane di gioco a chi non ha ancora un Bottino raro e ha attinto meno di
  /// 15 Essenze nelle ultime 4 settimane (chi attinge tanto il raro se lo compra da solo).
  static const welcomeAfterDays = 28;
  static const welcomeIfEssencesBelow = 15;

  /// Bottini dell'Esperienza al giorno, al massimo.
  static const trovesPerDay = 3;

  /// Grado di ciò che esce da un Bottino, secondo il grado del Bottino (`trove.contents` del simulatore). Le Mitiche
  /// escono **solo dal Bottino mitico** (decisione del 2026-10-27): il 10 % di Mitiche del raro è passato alle Rare.
  static Map<Grade, double> troveContents(Grade grade) => switch (grade) {
    Grade.common => const {Grade.common: 0.9, Grade.uncommon: 0.1},
    Grade.uncommon => const {Grade.common: 0.3, Grade.uncommon: 0.6, Grade.rare: 0.1},
    Grade.rare => const {Grade.uncommon: 0.3, Grade.rare: 0.7},
    Grade.mythic => const {Grade.rare: 0.5, Grade.mythic: 0.5},
  };

  /// Se hai Tavole incomplete di grado non più alto del Bottino, quanto spesso esce un loro pezzo.
  static const trovePieceChance = 0.4;

  /// Quota del Bottino che pesca dalle pagine delle piante che conosci (incontrate o studiate); il resto da tutta la
  /// Zona.
  static const troveKnownPlantsShare = 0.75;

  /// Riciclo dei doppioni: 3 riciclati di un grado fanno un componente dello stesso grado, 9 uno del grado sopra (al
  /// massimo un grado).
  static const recycleSameGrade = 3;
  static const recycleGradeUp = 9;

  /// Vis di qualsiasi specie che costa un componente riciclato, secondo il suo grado (proposta 🟡 del capitolo 02, da
  /// confermare con il simulatore).
  static int recycleVisCost(Grade grade) => switch (grade) {
    Grade.common => 5,
    Grade.uncommon => 10,
    Grade.rare => 20,
    Grade.mythic => 40,
  };

  /// Pezzi del nome che mancano a una Tavola trovata nel Bottino: la Non comune non sa l'effetto, la Rara il secondo
  /// tratto e l'effetto, la Mitica le sue 3 parole.
  static int missingPiecesWhenFound(Grade grade) => switch (grade) {
    Grade.common => 0,
    Grade.uncommon => 1,
    Grade.rare => 2,
    Grade.mythic => 3,
  };

  /// PE di una pozione di potenza 5, secondo il grado della ricetta; si scalano con la potenza.
  static int potionXp(Grade grade) => switch (grade) {
    Grade.common => 15,
    Grade.uncommon => 40,
    Grade.rare => 100,
    Grade.mythic => 250,
  };

  /// PE in più alla prima pozione di ogni ricetta.
  static const firstBrewBonus = 30;
}
