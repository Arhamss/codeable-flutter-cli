import 'package:dio/dio.dart';
import 'package:test_app/core/models/api_response/api_response_handler.dart';
import 'package:test_app/core/models/api_response/base_api_response.dart';

enum ResponseStatus {
  nullResponse,
  nullArgument,
  success,
  responseError,
  sessionExpired,
}

class ResponseModel<T> {
  ResponseModel({
    required this.status,
    this.response,
    this.error,
  });

  final T? response;
  final String? error;
  final ResponseStatus status;

  bool get isSuccess => status == ResponseStatus.success;

  bool get isError => status == ResponseStatus.responseError || isNull;

  bool get isNull => status == ResponseStatus.nullResponse;

  static ResponseModel<T> fromApiResponse<T extends BaseApiResponse<dynamic>>(
    Response<dynamic> response,
    T Function(Map<String, dynamic> json) parser,
  ) {
    try {
      return ApiResponseHandler<T>(parser, response).handleResponse();
    } on Exception catch (e) {
      return ResponseModel<T>(
        status: ResponseStatus.responseError,
        error: e.toString(),
      );
    }
  }
}
