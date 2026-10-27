import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/localized_text.dart';

/// Ingrediente di una ricetta scritta a mano (le Mitiche). Le ricette ad affissi hanno i loro ingredienti, calcolati
/// dalle regole (`RecipeIngredient`).
class Ingredient {
  final int quantity;

  /// `null` = qualsiasi specie (conta solo il tratto).
  final String? speciesSci;

  /// Condizione di raccolta richiesta (es. [Trait.moon]), `null` se basta la specie.
  final Trait? trait;

  /// Nota scritta a mano (quando e dove si trova); `null` nelle ricette generate e nelle Mitiche.
  final LocalizedText? note;

  const Ingredient({required this.quantity, required this.speciesSci, required this.trait, this.note});

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    quantity: json['qty'] as int,
    speciesSci: json['species'] as String?,
    trait: json['trait'] == null ? null : Trait.values.byName(json['trait'] as String),
    note: json['note'] == null ? null : LocalizedText.fromJson(json['note'] as Map<String, dynamic>),
  );
}
