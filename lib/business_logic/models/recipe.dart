import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/localized_text.dart';

/// Requisito di sblocco: la specie indicata deve aver raggiunto almeno quel livello di studio.
class RecipeUnlock {
  final String speciesSci;
  final int level;

  const RecipeUnlock({required this.speciesSci, required this.level});

  factory RecipeUnlock.fromJson(Map<String, dynamic> json) =>
      RecipeUnlock(speciesSci: json['species'] as String, level: json['level'] as int);
}

class Ingredient {
  final int quantity;

  /// `null` = qualsiasi specie (conta solo il tratto).
  final String? speciesSci;

  /// Condizione di raccolta richiesta (es. [Trait.moon]), `null` se basta la specie.
  final Trait? trait;
  final LocalizedText note;

  const Ingredient({required this.quantity, required this.speciesSci, required this.trait, required this.note});

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    quantity: json['qty'] as int,
    speciesSci: json['species'] as String?,
    trait: json['trait'] == null ? null : Trait.values.byName(json['trait'] as String),
    note: LocalizedText.fromJson(json['note'] as Map<String, dynamic>),
  );
}

/// Ricetta di gioco. Gli effetti sono dichiaratamente fantasy: mai indicazioni d'uso reali.
class Recipe {
  /// Id stabile: lo salvano gli eventi `RecipeLearned`.
  final String id;
  final LocalizedText name;
  final Grade grade;
  final RecipeUnlock? unlock;
  final List<Ingredient> ingredients;
  final LocalizedText effect;

  const Recipe({
    required this.id,
    required this.name,
    required this.grade,
    required this.unlock,
    required this.ingredients,
    required this.effect,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String,
    name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
    grade: Grade.values.byName(json['grade'] as String),
    unlock: json['unlock'] == null ? null : RecipeUnlock.fromJson(json['unlock'] as Map<String, dynamic>),
    ingredients: (json['ingredients'] as List).map((i) => Ingredient.fromJson(i as Map<String, dynamic>)).toList(),
    effect: LocalizedText.fromJson(json['effect'] as Map<String, dynamic>),
  );
}
