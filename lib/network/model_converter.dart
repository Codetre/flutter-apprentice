/* 서버가 반환한 API 응답 데이터를 사용하려면 그 전에 변환을 거쳐야 한다(String -> class).
 * 이를 담당할 converter를 Chopper 클라이언트에 부착하려면 'interceptor'가 필요하다.
 * interceptor란 요청을 보내거나 응답을 받을 때마다 호출되는 함수이다.
 */

import 'dart:convert';

import 'package:chopper/chopper.dart';

import 'model_response.dart';
import 'recipe_model.dart';

class ModelConverter implements Converter {
  /// Map(Dart) -> String(JSON)
  Request encodeJson(Request request) {
    final contentType = request.headers[contentTypeKey];
    if (contentType != null && contentType.contains(jsonHeaders)) {
      return request.copyWith(body: json.encode(request.body));
    } else {
      return request;
    }
  }

  /// String(JSON) -> Map(Dart)
  Response<BodyType> decodeJson<BodyType, InnerType>(Response response) {
    final contentType = response.headers[contentTypeKey];
    var body = response.body;
    if (contentType != null && contentType.contains(jsonHeaders)) {
      body = utf8.decode(response.bodyBytes);
    }
    try {
      final mapData = json.decode(body);
      // 에러가 있다면 body에 'status'란 필드가 존재한다.
      if (mapData['status'] != null) {
        return response.copyWith<BodyType>(
            body: Error(Exception(mapData['status'])) as BodyType);
      }
      final recipeQuery = APIRecipeQuery.fromJson(mapData);
      return response.copyWith<BodyType>(
          body: Success(recipeQuery) as BodyType);
    } catch (e) {
      // Catch any other kind of error
      chopperLogger.warning(e);
      return response.copyWith<BodyType>(
          body: Error(e as Exception) as BodyType);
    }
  }

  @override
  Request convertRequest(Request request) {
    final req = applyHeader(
      request,
      contentTypeKey,
      jsonHeaders,
      override: false,
    );

    return encodeJson(req);
  }

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
    return decodeJson<BodyType, InnerType>(response);
  }
}
