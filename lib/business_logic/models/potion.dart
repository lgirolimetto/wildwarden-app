import 'package:druid_app/business_logic/models/enums/potion_effect.dart';

/// Una pozione preparata, sullo Scaffale: la ricetta, la potenza e il Tocco della pianta dello slot libero.
class Potion {
  /// Posizione tra le pozioni preparate (0 = la prima): id stabile.
  final int index;
  final String recipeId;

  /// Da 1 a 10.
  final int potency;

  /// L'effetto della pianta dello slot libero, che dà l'aggettivo alla pozione (`null` senza slot libero).
  final PotionEffect? touch;
  final DateTime brewedAt;

  const Potion({
    required this.index,
    required this.recipeId,
    required this.potency,
    required this.touch,
    required this.brewedAt,
  });
}
