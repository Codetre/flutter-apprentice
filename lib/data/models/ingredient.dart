import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  int? id;
  int? recipeId;
  final String? name;
  final double? weight;

  Ingredient({
    this.id,
    this.recipeId,
    this.name,
    this.weight,
  });

  /// 동일성을 검사하는 기준을 나열한다.
  @override
  List<Object?> get props => [
        recipeId,
        name,
        weight,
      ];

  /// Create a Ingredient object from JSON data.
  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: json['ingredientId'],
        recipeId: json['recipeId'],
        name: json['name'],
        weight: json['weight'],
      );

  /// Convert our Ingredient object to JSON format to make it easier when you
  /// store it in the database.
  Map<String, dynamic> toJson() => {
        'ingredientId': id,
        'recipeId': recipeId,
        'name': name,
        'weight': weight,
      };
}
