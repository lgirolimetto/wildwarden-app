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
