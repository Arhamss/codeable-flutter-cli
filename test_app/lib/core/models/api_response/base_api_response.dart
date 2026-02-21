import 'package:test_app/core/models/api_response/api_error.dart';

class BaseApiResponse<T> {
  BaseApiResponse({
    required this.statusCode,
    this.error,
    this.data,
  });

  factory BaseApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parser,
  ) {
    final statusCode = json['statusCode'] as int;
    final error = json['error'] != null
        ? ApiError.fromJson(json['error'] as Map<String, dynamic>)
        : null;

    T? parsedData;
    if (json['data'] != null && error == null) {
      parsedData = parser(json['data'] as Map<String, dynamic>);
    }

    return BaseApiResponse<T>(
      statusCode: statusCode,
      error: error,
      data: parsedData,
    );
  }

  final int statusCode;
  final ApiError? error;
  final T? data;

  bool get hasError => error != null;
}
