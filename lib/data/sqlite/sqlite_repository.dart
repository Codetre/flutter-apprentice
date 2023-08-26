import 'dart:async';

import '../models/models.dart';
import '../repository.dart';
import 'database_helper.dart';

class SqliteRepository extends Repository {
  final dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Recipe>> findAllRecipes() => dbHelper.findAllRecipes();

  @override
  Stream<List<Recipe>> watchAllRecipes() => dbHelper.watchAllRecipes();

  @override
  Stream<List<Ingredient>> watchAllIngredients() =>
      dbHelper.watchAllIngredients();

  @override
  Future<Recipe> findRecipeById(int id) => dbHelper.findRecipeById(id);

  @override
  Future<List<Ingredient>> findAllIngredients() =>
      dbHelper.findAllIngredients();

  @override
  Future<List<Ingredient>> findRecipeIngredients(int recipeId) =>
      dbHelper.findRecipeIngredients(recipeId);

  /// `recipe`는 id가 null일 수 있어 그 경우 `insertRecipe()`가 리턴한 값을 id로 삼는다.
  @override
  Future<int> insertRecipe(Recipe recipe) async {
    return Future(() async {
      final id = await dbHelper.insertRecipe(recipe);
      recipe.id = id;
      if (recipe.ingredients != null) {
        recipe.ingredients!.forEach((ingredient) {
          ingredient.recipeId = id;
        });
        insertIngredients(recipe.ingredients!);
      }
      return id;
    });
  }

  @override
  Future<List<int>> insertIngredients(List<Ingredient> ingredients) {
    return Future(() async {
      if (ingredients.isNotEmpty) {
        final ingredientIds = <int>[];
        await Future.forEach(ingredients, (Ingredient ingredient) async {
          final futureId = await dbHelper.insertIngredient(ingredient);
          ingredient.id = futureId;
          ingredientIds.add(futureId);
        });
        return Future.value(ingredientIds);
      } else {
        return Future.value(<int>[]);
      }
    });
  }

  @override
  Future<int> deleteRecipe(Recipe recipe) {
    final id = dbHelper.deleteRecipe(recipe);
    if (recipe.id != null) {
      deleteRecipeIngredients(recipe.id!);
      return Future.value(recipe.id);
    }
    return id;
  }

  @override
  Future<void> deleteIngredient(Ingredient ingredient) =>
      dbHelper.deleteIngredient(ingredient);

  @override
  Future<void> deleteIngredients(List<Ingredient> ingredients) =>
      dbHelper.deleteIngredients(ingredients);

  @override
  Future<void> deleteRecipeIngredients(int recipeId) =>
      dbHelper.deleteRecipeIngredients(recipeId);

  @override
  Future init() async {
    await dbHelper.streamDatabase;
    return Future.value();
  }

  @override
  void close() {
    dbHelper.close();
  }
}
