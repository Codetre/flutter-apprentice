import 'dart:developer';

import 'package:http/http.dart';

// constants for calling APIs
const String apiKey = '28d368e437cddb2886e39585173096d6';
const String apiId = 'ec20dab6';
const String apiUrl = 'https://api.edamam.com/search';

/// Manage the connection to the recipe API server.
class RecipeService {
  Future<dynamic> getData(String url) async {
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      log(response.body);
    }
  }

  Future<dynamic> getRecipes(String query, int from, int to) async {
    const path = apiUrl;
    const q1 = '?app_id=$apiId';
    const q2 = '&app_key=$apiKey';
    final q3 = '&q=$query';
    final q4 = '&from=$from';
    final q5 = '&to=$to';

    final recipeData = await getData(path + q1 + q2 + q3 + q4 + q5);
    return recipeData;
  }
}
