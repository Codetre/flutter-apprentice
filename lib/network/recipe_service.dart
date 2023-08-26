import 'package:chopper/chopper.dart';

import 'model_converter.dart';
import 'model_response.dart';
import 'recipe_model.dart';
import 'service_interface.dart';

part 'recipe_service.chopper.dart';

const String apiKey = '28d368e437cddb2886e39585173096d6';
const String apiId = 'ec20dab6';
const String apiUrl = 'https://api.edamam.com';

/* `@ChopperApi()` tells for Chopper generator to build a part file holing
 * boilerplate code whose name is the same except for `.chopper.dart`.
 * That's why `abstract` followed by the class signature. implemented class is
 * created by the chopper generator.
 */
@ChopperApi()
abstract class RecipeService extends ChopperService
    implements ServiceInterface {
  // The chopper generator creates the body for this method.
  @override
  @Get(path: 'search')
  Future<Response<Result<APIRecipeQuery>>> queryRecipes(
      @Query('q') String query, @Query('from') int from, @Query('to') int to);

  static RecipeService create() {
    final client = ChopperClient(
      baseUrl: Uri.tryParse(apiUrl),
      // `HttpLoggingInterceptor` logs all calls
      interceptors: [_addQuery, HttpLoggingInterceptor()],
      // 인터셉터가 실행되기 전 요청과 응답을 변환시키기 위한 변환기.
      converter: ModelConverter(),
      // `JsonConverter` decodes any error to JSON format.
      errorConverter: const JsonConverter(),
      // It is created when the generator script runs.
      services: [_$RecipeService()],
    );
    return _$RecipeService(client);
  }
}

/// Request interceptor that inserts API ID and key.
Request _addQuery(Request request) {
  final params = Map<String, dynamic>.from(request.parameters);
  params['app_id'] = apiId;
  params['app_key'] = apiKey;
  return request.copyWith(parameters: params);
}
