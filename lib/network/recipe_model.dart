import 'package:json_annotation/json_annotation.dart';

part 'recipe_model.g.dart';

@JsonSerializable()
class APIRecipeQuery {
  // Deserialization
  factory APIRecipeQuery.fromJson(Map<String, dynamic> json) =>
      _$APIRecipeQueryFromJson(json);

  // Serialization
  Map<String, dynamic> toJson() => _$APIRecipeQueryToJson(this);

  /* JSON 상 필드명과 클래스 내 필드명이 다르지만 같은 것으로 취급하려 할 때 아래처럼 연결한다:
   * @JsonKey(name: key_on_json)
   * <T> fieldOnClass
   */
  @JsonKey(name: 'q')
  String query;
  int from;
  int to;
  bool more;
  int count;
  List<APIHits> hits;

  APIRecipeQuery({
    required this.query,
    required this.from,
    required this.to,
    required this.more,
    required this.count,
    required this.hits,
  });
}

@JsonSerializable()
class APIHits {
  APIRecipe recipe;

  APIHits({required this.recipe});

  factory APIHits.fromJson(Map<String, dynamic> json) =>
      _$APIHitsFromJson(json);

  Map<String, dynamic> toJson() => _$APIHitsToJson(this);
}

/// JSON의 Hits 필드 아래에 들어가는 객체의 추상화.
@JsonSerializable()
class APIRecipe {
  String label;
  String image;
  String url;
  List<APIIngredients> ingredients;
  double calories;
  double totalWeight;
  double totalTime;

  APIRecipe({
    required this.label,
    required this.image,
    required this.url,
    required this.ingredients,
    required this.calories,
    required this.totalWeight,
    required this.totalTime,
  });

  factory APIRecipe.fromJson(Map<String, dynamic> json) =>
      _$APIRecipeFromJson(json);

  Map<String, dynamic> toJson() => _$APIRecipeToJson(this);
}

String getCalories(double? calories) =>
    '${calories == null ? 0 : calories.floor()} KCal';

String getWeight(double? weight) => '${weight == null ? 0 : weight.floor()} g';

/// JSON의 Hits 필드 아래 들어가는 Recipe 객체의 필드 중 ingredients 객체의 추상화.
@JsonSerializable()
class APIIngredients {
  @JsonKey(name: 'text')
  String name;
  double weight;

  APIIngredients({
    required this.name,
    required this.weight,
  });

  factory APIIngredients.fromJson(Map<String, dynamic> json) =>
      _$APIIngredientsFromJson(json);

  Map<String, dynamic> toJson() => _$APIIngredientsToJson(this);
}
