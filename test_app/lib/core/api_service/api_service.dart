import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:test_app/core/api_service/app_api_exception.dart';
import 'package:test_app/core/api_service/authentication_interceptor.dart';
import 'package:test_app/core/api_service/log_interceptor.dart';
import 'package:test_app/core/app_preferences/app_preferences.dart';
import 'package:test_app/core/di/injector.dart';
import 'package:test_app/core/endpoints/endpoints.dart';

class ApiService {
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '\${Endpoints.baseUrl}/\${Endpoints.apiVersion}/',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(AuthInterceptor(_appPreferences, _dio));
    _dio.interceptors.add(LoggingInterceptor());
    _dio.interceptors.add(ChuckerDioInterceptor());
  }

  static final ApiService _instance = ApiService._internal();

  late final Dio _dio;
  final AppPreferences _appPreferences = Injector.resolve<AppPreferences>();

  /// GET Request
  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    return _handleRequest(
      () => _dio.get(endpoint, queryParameters: queryParams),
    );
  }

  /// POST Request
  Future<Response<dynamic>> post({
    required String endpoint,
    dynamic data,
  }) async {
    return _handleRequest(() => _dio.post(endpoint, data: data));
  }

  /// PUT Request
  Future<Response<dynamic>> put(String endpoint, dynamic data) async {
    return _handleRequest(() => _dio.put(endpoint, data: data));
  }

  /// PATCH Request
  Future<Response<dynamic>> patch(String endpoint, dynamic data) async {
    return _handleRequest(() => _dio.patch(endpoint, data: data));
  }

  Future<Response<dynamic>> patchMultipart(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final formData = FormData.fromMap(data);
    return _handleRequest(() => _dio.patch(endpoint, data: formData));
  }

  /// DELETE Request
  Future<Response<dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    return _handleRequest(
      () => _dio.delete(endpoint, queryParameters: queryParams),
    );
  }

  /// Handles Requests & Centralized Error Handling
  Future<Response<dynamic>> _handleRequest(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('Unhandled error: \$e');
      throw AppApiException('Unexpected error occurred');
    }
  }

  AppApiException _handleDioError(DioException e) {
    var errorMessage = 'An unknown error occurred';
    int? statusCode;

    if (e.response != null) {
      statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      if (responseData is Map<String, dynamic>) {
        final error = responseData['error'] as Map<String, dynamic>?;
        final serverMessage = error?['message'];
        if (serverMessage is String && serverMessage.isNotEmpty) {
          errorMessage = serverMessage;
        } else {
          switch (statusCode) {
            case 400:
              errorMessage = 'Bad request';
            case 401:
              errorMessage = 'Unauthorized';
            case 403:
              errorMessage = 'Forbidden';
            case 404:
              errorMessage = 'Not found';
            case 500:
              errorMessage = 'Internal server error';
            default:
              errorMessage = 'Unexpected error: \${e.response?.statusMessage}';
          }
        }
      }
    } else {
      errorMessage = e.message ?? 'Network error';
    }

    debugPrint('API Error: \$errorMessage');
    throw AppApiException(errorMessage, statusCode: statusCode);
  }
}
