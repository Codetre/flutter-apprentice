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
}
