import 'dart:async';

import '../models/models.dart';
import '../repository.dart';
import 'drift_db.dart';

class DriftRepository extends Repository {
  late RecipeDatabase recipeDatabase;
  late RecipeDao _recipeDao;
  late IngredientDao _ingredientDao;
  Stream<List<Ingredient>>? ingredientStream;
  Stream<List<Recipe>>? recipeStream;

  @override
  Future<List<Recipe>> findAllRecipes() {
    return _recipeDao
        .findAllRecipes()
        .then<List<Recipe>>((List<DriftRecipeData> driftRecipes) async {
      final recipes = <Recipe>[];

      for (final driftRecipe in driftRecipes) {
        final recipe = driftRecipeToRecipe(driftRecipe);
        if (recipe.id != null) {
          recipe.ingredients = await findRecipeIngredients(recipe.id!);
        }
        recipes.add(recipe);
      }
      return recipes;
    });
  }

  @override
  Stream<List<Recipe>> watchAllRecipes() {
    recipeStream ??= _recipeDao.watchAllRecipes();
    return recipeStream!;
  }

  @override
  Stream<List<Ingredient>> watchAllIngredients() {
    if (ingredientStream == null) {
      final stream = _ingredientDao.watchAllIngredients();
      ingredientStream =
          stream.map((List<DriftIngredientData> driftIngredients) {
        final ingredients = <Ingredient>[];

        for (final driftIngredient in driftIngredients) {
          ingredients.add(driftIngredientToIngredient(driftIngredient));
        }
        return ingredients;
      });
    }
    return ingredientStream!;
  }

  @override
  Future<Recipe> findRecipeById(int id) {
    return _recipeDao
        .findRecipeById(id)
        .then<Recipe>((List<DriftRecipeData> recipes) {
      return driftRecipeToRecipe(recipes.first);
    });
  }

  @override
  Future<List<Ingredient>> findAllIngredients() {
    return _ingredientDao
        .findAllIngredients()
        .then<List<Ingredient>>((List<DriftIngredientData> driftIngredients) {
      final ingredients = <Ingredient>[];
      for (final driftIngredient in driftIngredients) {
        final ingredient = driftIngredientToIngredient(driftIngredient);
        ingredients.add(ingredient);
      }
      return ingredients;
    });
  }

  @override
  Future<List<Ingredient>> findRecipeIngredients(int recipeId) {
    return _ingredientDao
        .findRecipeIngredients(recipeId)
        .then<List<Ingredient>>((List<DriftIngredientData> driftIngredients) {
      final ingredients = <Ingredient>[];

      for (final driftIngredient in driftIngredients) {
        final ingredient = driftIngredientToIngredient(driftIngredient);
        ingredients.add(ingredient);
      }
      return ingredients;
    });
  }

  @override
  Future<int> insertRecipe(Recipe recipe) {
    return Future(() async {
      final id =
          await _recipeDao.insertRecipe(recipeToInsertableDriftRecipe(recipe));
      if (recipe.ingredients != null) {
        for (final ingredient in recipe.ingredients!) {
          ingredient.recipeId = id;
        }
        insertIngredients(recipe.ingredients!);
      }
      return id;
    });
  }

  @override
  Future<List<int>> insertIngredients(List<Ingredient> ingredients) {
    return Future(() {
      if (ingredients.isEmpty) {
        return <int>[];
      } else {
        final resultIds = <int>[];
        for (final ingredient in ingredients) {
          final driftIngredient =
              ingredientToInsertableDriftIngredient(ingredient);
          _ingredientDao.insertIngredient(driftIngredient).then((int id) {
            resultIds.add(id);
          });
        }
        return resultIds;
      }
    });
  }

  @override
  Future<int> deleteRecipe(Recipe recipe) {
    int endState;

    if (recipe.id != null) {
      _recipeDao.deleteRecipe(recipe.id!);
      deleteRecipeIngredients(recipe.id!);
      endState = 0;
    } else {
      endState = 1;
    }
    return Future.value(endState);
  }

  @override
  Future<int> deleteIngredient(Ingredient ingredient) {
    int endState;

    if (ingredient.id != null) {
      _ingredientDao.deleteIngredient(ingredient.id!);
      endState = 0;
    } else {
      endState = 1;
    }
    return Future.value(endState);
  }

  @override
  Future<List<int>> deleteIngredients(List<Ingredient> ingredients) {
    final endStates = <int>[];

    for (final ingredient in ingredients) {
      int endState;

      if (ingredient.id != null) {
        _ingredientDao.deleteIngredient(ingredient.id!);
        endState = 0;
      } else {
        endState = 1;
      }
      endStates.add(endState);
    }
    return Future.value(endStates);
  }

  @override
  Future<List<int>> deleteRecipeIngredients(int recipeId) async {
    final ingredients = await findRecipeIngredients(recipeId);
    return deleteIngredients(ingredients);
  }

  @override
  Future init() async {
    recipeDatabase = RecipeDatabase();
    _recipeDao = recipeDatabase.recipeDao;
    _ingredientDao = recipeDatabase.ingredientDao;
  }

  @override
  void close() {
    recipeDatabase.close();
  }
}
