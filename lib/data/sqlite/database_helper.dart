// A class in this file handles all the SQLite database operations.
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:synchronized/synchronized.dart';

import '../models/models.dart';

class DatabaseHelper {
  static const _databaseName = 'MyRecipes.db';
  static const _databaseVersion = 1;

  // Tables
  static const recipeTable = 'Recipe';
  static const ingredientTable = 'Ingredient';
  static const recipeId = 'recipeId'; // Column name for p-key in recipe table
  static const ingredientId = 'IngredientId'; // Same for the ingredient table.

  static late BriteDatabase _streamDatabase;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // prevent concurrent access.
  static var lock = Lock();

  // Only have a single app-wide reference to the database.
  static Database? _database;

  /// Run SQL code to create the db table.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $recipeTable (
      $recipeId INTEGER PRIMARY KEY,
      label TEXT, 
      image TEXT,
      url TEXT, 
      calories REAL, 
      totalWeight REAL,
      totalTime REAL
    )
    ''');

    await db.execute('''
    CREATE TABLE $ingredientTable (
      $ingredientId INTEGER PRIMARY KEY,
      $recipeId INTEGER, 
      name TEXT,
      weight REAL
    )
    ''');
  }

  /// Open the database (and create if it doesn't exist).
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  /// 존재하면 그 db를, 없다면 새로 만들고 거기에 변화를 감지할 스트림 wrapper를 달고 db를 반환.
  Future<Database> get database async {
    if (_database != null) return _database!;

    // 락이 사용 가능할 때만 콜백을 호출한다.
    await lock.synchronized(() async {
      // lazily instantiate the db the first time it is accessed.
      if (_database == null) {
        _database = await _initDatabase();
        _streamDatabase = BriteDatabase(_database!);
      }
    });
    return _database!;
  }

  Future<BriteDatabase> get streamDatabase async {
    await database; // 이 라인을 거치면 stream wrapper가 생성됨을 보장한다.
    return _streamDatabase;
  }

  List<Recipe> parseRecipes(List<Map<String, dynamic>> recipeList) {
    final recipes = <Recipe>[];

    for (final recipeMap in recipeList) {
      final recipe = Recipe.fromJson(recipeMap);
      recipes.add(recipe);
    }

    return recipes;
  }

  List<Ingredient> parseIngredients(List<Map<String, dynamic>> ingredientList) {
    final ingredients = <Ingredient>[];

    for (final ingredientMap in ingredientList) {
      final ingredient = Ingredient.fromJson(ingredientMap);
      ingredients.add(ingredient);
    }

    return ingredients;
  }

  Future<List<Recipe>> findAllRecipes() async {
    final db = await instance.streamDatabase;
    final recipeList = await db.query(recipeTable);
    final recipes = parseRecipes(recipeList);
    return recipes;
  }

  /// DB에 저장된 모든 레시피를 가져오는 비동기 제너레이터.
  Stream<List<Recipe>> watchAllRecipes() async* {
    final db = await instance.streamDatabase;
    yield* db
        .createQuery(recipeTable)
        .mapToList((JSON row) => Recipe.fromJson(row));
  }

  /// DB에 저장된 모든 재료를 가져오는 비동기 제너레이터.
  Stream<List<Ingredient>> watchAllIngredients() async* {
    final db = await instance.streamDatabase;
    yield* db
        .createQuery(ingredientTable)
        .mapToList((JSON row) => Ingredient.fromJson(row));
  }

  /// 아이디에 해당하는 레시피를 DB에서 꺼내온다.
  Future<Recipe> findRecipeById(int id) async {
    final db = await instance.streamDatabase;
    final recipeList =
        await db.query(recipeTable, where: '${DatabaseHelper.recipeId}=$id');

    final recipes = parseRecipes(recipeList);
    return recipes.first;
  }

  /// 모든 재료 목록을 DB에서 가져온다.
  Future<List<Ingredient>> findAllIngredients() async {
    final db = await instance.streamDatabase;
    final ingredientList = await db.query(ingredientTable);
    final ingredients = parseIngredients(ingredientList);
    return ingredients;
  }

  /// 일련번호에 맞는 레시피에 들어가는 재료를 나열한다.
  Future<List<Ingredient>> findRecipeIngredients(int recipeId) async {
    final db = await instance.streamDatabase;
    final ingredientList = await db.query(ingredientTable,
        where: '${DatabaseHelper.recipeId}=$recipeId');
    final ingredients = parseIngredients(ingredientList);
    return ingredients;
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.streamDatabase;
    final lastInsertedRowId = db.insert(table, row);
    return lastInsertedRowId;
  }

  Future<int> insertRecipe(Recipe recipe) {
    final lastInsertedRowId = insert(recipeTable, recipe.toJson());
    return lastInsertedRowId;
  }

  Future<int> insertIngredient(Ingredient ingredient) {
    final lastInsertedRowId = insert(ingredientTable, ingredient.toJson());
    return lastInsertedRowId;
  }

  Future<int> _delete(String table, String columnId, int id) async {
    final db = await instance.streamDatabase;

    return db.delete(table, where: '$columnId= ?', whereArgs: [id]);
  }

  Future<int> deleteRecipe(Recipe recipe) async {
    if (recipe.id != null) {
      return _delete(recipeTable, recipeId, recipe.id!);
    } else {
      return Future.value(-1);
    }
  }

  Future<int> deleteIngredient(Ingredient ingredient) async {
    if (ingredient.id != null) {
      return _delete(ingredientTable, ingredientId, ingredient.id!);
    } else {
      return Future.value(-1);
    }
  }

  Future<void> deleteIngredients(List<Ingredient> ingredients) async {
    for (final ingredient in ingredients) {
      deleteIngredient(ingredient);
    }
  }

  Future<int> deleteRecipeIngredients(int id) async {
    final db = await instance.streamDatabase;
    return db.delete(ingredientTable, where: '$recipeId = ?', whereArgs: [id]);
  }

  void close() {
    _streamDatabase.close();
  }
}
