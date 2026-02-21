import 'package:dio/dio.dart';

class ApiResponseParser {
  ApiResponseParser._();

  static T? parse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final responseData = data['data'];
      if (responseData is Map<String, dynamic>) {
        return fromJson(responseData);
      }
    }
    return null;
  }

  static List<T> parseList<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final responseData = data['data'];
      if (responseData is List) {
        return responseData
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }
}
