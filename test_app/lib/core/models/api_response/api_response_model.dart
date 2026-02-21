class ApiResponseModel<T> {
  ApiResponseModel({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  final bool success;
  final T? data;
  final String? message;
  final ApiError? error;
}

class ApiError {
  ApiError({
    this.message,
    this.code,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] as String?,
      code: json['code'] as String?,
    );
  }

  final String? message;
  final String? code;
}
