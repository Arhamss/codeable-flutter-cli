import 'package:dio/dio.dart';
import 'package:test_app/core/models/api_response/api_response_model.dart';
import 'package:test_app/core/models/api_response/base_api_response.dart';

class ApiResponseHandler<T extends BaseApiResponse<dynamic>> {
  ApiResponseHandler(this.parser, this.response);

  final T Function(Map<String, dynamic>) parser;
  final Response<dynamic> response;

  ResponseModel<T> handleResponse() {
    try {
      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300) {
        final body = response.data;
        if (body is! Map<String, dynamic>) {
          return ResponseModel<T>(
            status: ResponseStatus.nullResponse,
            error: 'Invalid response format',
          );
        }

        final parsedData = parser(body);

        if (parsedData.hasError) {
          return ResponseModel<T>(
            status: ResponseStatus.responseError,
            error: parsedData.error?.message ?? 'Unknown API error',
            response: parsedData,
          );
        }

        return ResponseModel<T>(
          status: ResponseStatus.success,
          response: parsedData,
        );
      }

      return ResponseModel<T>(
        status: ResponseStatus.responseError,
        error: 'Request failed with status code \$statusCode',
      );
    } catch (e) {
      return ResponseModel<T>(
        status: ResponseStatus.responseError,
        error: 'Exception during parsing: \$e',
      );
    }
  }
}
