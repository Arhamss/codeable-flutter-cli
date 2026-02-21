import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('[\u27A1\uFE0F] [\${options.method}] \${options.uri}');
      print('Headers: \${options.headers}');
      if (options.data != null) {
        print('Body: \${options.data}');
      }
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('[\u2705] [\${response.statusCode}] \${response.requestOptions.uri}');
      print('Response: \${response.data}');
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('[\u274C] [Error] \${err.requestOptions.uri}');
      print('Message: \${err.message}');
      if (err.response != null) {
        print('Response Data: \${err.response?.data}');
      }
    }
    return handler.next(err);
  }
}
