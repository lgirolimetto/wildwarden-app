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

  /// Quando l'hai usata (`null` = è ancora sullo Scaffale).
  final DateTime? usedAt;

  const Potion({
    required this.index,
    required this.recipeId,
    required this.potency,
    required this.touch,
    required this.brewedAt,
    this.usedAt,
  });

  bool get onShelf => usedAt == null;

  Potion used(DateTime at) =>
      Potion(index: index, recipeId: recipeId, potency: potency, touch: touch, brewedAt: brewedAt, usedAt: at);
}

/// Un effetto di pozione in corso: [strength] da 1 a 10, fino a [until].
class ActiveEffect {
  final PotionEffect effect;
  final int strength;
  final DateTime until;

  const ActiveEffect({required this.effect, required this.strength, required this.until});
}
