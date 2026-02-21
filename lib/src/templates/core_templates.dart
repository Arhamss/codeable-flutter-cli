const apiServiceTemplate = '''
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:{{project_name}}/core/api_service/app_api_exception.dart';
import 'package:{{project_name}}/core/api_service/authentication_interceptor.dart';
import 'package:{{project_name}}/core/api_service/log_interceptor.dart';
import 'package:{{project_name}}/core/app_preferences/app_preferences.dart';
import 'package:{{project_name}}/core/di/injector.dart';
import 'package:{{project_name}}/core/endpoints/endpoints.dart';

class ApiService {
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '\\\${Endpoints.baseUrl}/\\\${Endpoints.apiVersion}/',
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
      debugPrint('Unhandled error: \\\$e');
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
              errorMessage = 'Unexpected error: \\\${e.response?.statusMessage}';
          }
        }
      }
    } else {
      errorMessage = e.message ?? 'Network error';
    }

    debugPrint('API Error: \\\$errorMessage');
    throw AppApiException(errorMessage, statusCode: statusCode);
  }
}
''';

const appApiExceptionTemplate = '''
class AppApiException implements Exception {
  AppApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

String extractApiErrorMessage(Object e, String fallback) {
  return e is AppApiException ? e.message : fallback;
}
''';

const authInterceptorTemplate = '''
import 'package:dio/dio.dart';
import 'package:{{project_name}}/core/app_preferences/app_preferences.dart';
import 'package:{{project_name}}/core/endpoints/endpoints.dart';
import 'package:{{project_name}}/exports.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._appPreferences, this._dio);

  final AppPreferences _appPreferences;
  final Dio _dio;
  bool _isRefreshing = false;
  Future<String?>? _refreshTokenFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _appPreferences.getAuthToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer \\\$token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final newToken = await _handleTokenRefresh();

      if (newToken != null) {
        err.requestOptions.headers['Authorization'] = 'Bearer \\\$newToken';
        final retryResponse = await _dio.fetch<dynamic>(err.requestOptions);
        return handler.resolve(retryResponse);
      }
    }

    return handler.next(err);
  }

  Future<String?> _handleTokenRefresh() async {
    if (_isRefreshing) {
      return _refreshTokenFuture;
    }

    _isRefreshing = true;
    _refreshTokenFuture = _refreshToken();

    final newToken = await _refreshTokenFuture;
    _isRefreshing = false;
    return newToken;
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = _appPreferences.getRefreshToken();
      if (refreshToken == null) {
        await _appPreferences.clearAuthData();
        _navigateToSplash();
        return null;
      }

      final response = await _dio.post<dynamic>(
        '\\\${Endpoints.baseUrl}/\\\${Endpoints.refresh}',
        options: Options(headers: {'Authorization': 'Bearer \\\$refreshToken'}),
      );

      if (response.statusCode == 200) {
        final newToken =
            (response.data as Map<String, dynamic>)['token'] as String;
        _appPreferences.setAuthToken(newToken);
        return newToken;
      } else {
        await _appPreferences.clearAuthData();
        _navigateToSplash();
        return null;
      }
    } catch (e) {
      await _appPreferences.clearAuthData();
      _navigateToSplash();
      return null;
    }
  }

  void _navigateToSplash() {
    final context = AppRouter.appContext;
    if (context != null) {
      context.goNamed(AppRouteNames.splash);
    }
  }
}
''';

const logInterceptorTemplate = '''
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('[\\u27A1\\uFE0F] [\\\${options.method}] \\\${options.uri}');
      print('Headers: \\\${options.headers}');
      if (options.data != null) {
        print('Body: \\\${options.data}');
      }
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('[\\u2705] [\\\${response.statusCode}] \\\${response.requestOptions.uri}');
      print('Response: \\\${response.data}');
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('[\\u274C] [Error] \\\${err.requestOptions.uri}');
      print('Message: \\\${err.message}');
      if (err.response != null) {
        print('Response Data: \\\${err.response?.data}');
      }
    }
    return handler.next(err);
  }
}
''';

const baseStorageTemplate = '''
import 'package:hive_ce/hive_ce.dart';

abstract class BaseStorage {
  late Box<dynamic> _box;

  Future<void> init(String boxName) async {
    try {
      _box = await Hive.openBox(boxName);
    } catch (e) {
      await Hive.deleteBoxFromDisk(boxName);
      _box = await Hive.openBox(boxName);
    }
  }

  Future<void> remove(String key) => _box.delete(key);

  Future<void> removeAll() => _box.clear();

  T? retrieve<T>(String key) => _box.get(key) as T?;

  Future<void> store<T>(String key, T value) => _box.put(key, value);

  bool hasData(String key) => _box.containsKey(key);

  List<dynamic> getAllKeys() => _box.keys.toList();
}
''';

const appPreferencesTemplate = '''
import 'package:{{project_name}}/core/app_preferences/base_storage.dart';
import 'package:{{project_name}}/utils/helpers/logger_helper.dart';

class AppPreferences extends BaseStorage {
  AppPreferences() {
    init('app-storage');
  }

  final String _authTokenKey = 'auth_token';
  final String _refreshTokenKey = 'refresh_token';
  final String _userIdKey = 'user_id';
  final String _appLocale = 'app_locale';

  /// App Locale
  void setAppLocale(String locale) {
    store<String>(_appLocale, locale);
  }

  String? getAppLocale() {
    return retrieve<String>(_appLocale);
  }

  void clearAppLocale() {
    remove(_appLocale);
  }

  /// Auth Tokens
  void setAuthToken(String token) {
    store<String>(_authTokenKey, token);
  }

  String? getAuthToken() {
    return retrieve<String>(_authTokenKey);
  }

  void removeAuthToken() {
    remove(_authTokenKey);
  }

  /// Refresh Tokens
  void setRefreshToken(String token) {
    store<String>(_refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return retrieve<String>(_refreshTokenKey);
  }

  void removeRefreshToken() {
    remove(_refreshTokenKey);
  }

  /// User ID
  void setUserId(String userId) {
    store<String>(_userIdKey, userId);
  }

  String? getUserId() {
    return retrieve<String>(_userIdKey);
  }

  void removeUserId() {
    remove(_userIdKey);
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    final token = getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all auth data
  Future<void> clearAuthData() async {
    await remove(_authTokenKey);
    await remove(_refreshTokenKey);
    await remove(_userIdKey);
  }

  /// Clear all data
  Future<void> clearAll() {
    return removeAll();
  }

  /// Print ID Token (for debugging)
  void printIdToken() {
    final token = getAuthToken();
    if (token != null) {
      AppLogger.info('=== ID TOKEN ===');
      AppLogger.info(token);
      AppLogger.info('================');
    } else {
      AppLogger.warning('No ID token found');
    }
  }
}
''';

const injectorTemplate = '''
import 'package:get_it/get_it.dart';
import 'package:{{project_name}}/core/di/modules/app_modules.dart';

abstract class Injector {
  static late final GetIt _container;

  static Future<void> setup() async {
    _container = GetIt.instance;
    await AppModule.setup(_container);
  }

  static T resolve<T extends Object>() => _container.get<T>();
}
''';

const appModulesTemplate = '''
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:{{project_name}}/core/api_service/api_service.dart';
import 'package:{{project_name}}/core/app_preferences/app_preferences.dart';

abstract class AppModule {
  static late final GetIt _container;

  static Future<void> setup(GetIt container) async {
    _container = container;
    await _setupHive();
    await _setupAppPreferences();
    await _setupAPIService();
  }

  static Future<void> _setupHive() async {
    await Hive.initFlutter();
    // Register Hive adapters here
    // Hive.registerAdapter(YourModelAdapter());
  }

  static Future<void> _setupAPIService() async {
    final apiService = ApiService();
    _container.registerSingleton<ApiService>(apiService);
  }

  static Future<void> _setupAppPreferences() async {
    final appPreferences = AppPreferences();
    await appPreferences.init('app-storage');
    _container.registerSingleton<AppPreferences>(appPreferences);
  }
}
''';

const endpointsTemplate = '''
import 'package:{{project_name}}/config/api_environment.dart';

class Endpoints {
  Endpoints._();

  static String get baseUrl => ApiEnvironment.current.baseUrl;

  static String get apiVersion => ApiEnvironment.current.apiVersion;

  /// Authentication
  static const refresh = 'auth/refresh';
  static const login = 'auth/login';
  static const logout = 'auth/logout';
  static const googleAuth = 'auth/google';

  /// Profile
  static const profile = 'users/profile';
}
''';

const fieldValidatorsTemplate = '''
class FieldValidators {
  FieldValidators._();

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '\\\${fieldName ?? "This field"} is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\\\$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\\+?[0-9]{10,15}\\\$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}
''';

const localeCubitTemplate = '''
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:{{project_name}}/core/app_preferences/app_preferences.dart';
import 'package:{{project_name}}/core/di/injector.dart';

part 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit({
    AppPreferences? cache,
    this.context,
  })  : _cache = cache ?? Injector.resolve<AppPreferences>(),
        super(const LocaleState()) {
    _initLocale();
  }

  final AppPreferences _cache;
  final BuildContext? context;

  void _initLocale() {
    final savedLocale = _cache.getAppLocale();
    if ((savedLocale ?? '').isNotEmpty) {
      emit(
        state.copyWith(
          locale: Locale(savedLocale ?? 'en'),
        ),
      );
    } else {
      emit(
        state.copyWith(
          locale: const Locale('en'),
        ),
      );
    }
  }

  void setLocale(String languageCode) {
    _cache.setAppLocale(languageCode);
    emit(
      state.copyWith(
        locale: Locale(languageCode),
      ),
    );
    if (context != null) {
      Phoenix.rebirth(context!);
    }
  }
}
''';

const localeStateTemplate = '''
part of 'locale_cubit.dart';

class LocaleState extends Equatable {
  const LocaleState({
    this.locale = const Locale('en'),
  });

  final Locale locale;

  LocaleState copyWith({
    Locale? locale,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [locale];
}
''';

const apiResponseModelTemplate = '''
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
''';

const apiErrorTemplate = '''
import 'package:equatable/equatable.dart';

class ApiError extends Equatable {
  const ApiError({
    required this.code,
    required this.message,
    required this.timestamp,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String?,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String?,
    );
  }

  final String? code;
  final String message;
  final String? timestamp;

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'timestamp': timestamp,
      };

  @override
  List<Object?> get props => [code, message, timestamp];

  @override
  String toString() => '\\\$code: \\\$message';
}
''';

const baseApiResponseTemplate = '''
import 'package:{{project_name}}/core/models/api_response/api_error.dart';

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
''';

const apiResponseHandlerTemplate = '''
import 'package:dio/dio.dart';
import 'package:{{project_name}}/core/models/api_response/api_response_model.dart';
import 'package:{{project_name}}/core/models/api_response/base_api_response.dart';

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
        error: 'Request failed with status code \\\$statusCode',
      );
    } catch (e) {
      return ResponseModel<T>(
        status: ResponseStatus.responseError,
        error: 'Exception during parsing: \\\$e',
      );
    }
  }
}
''';

const responseModelTemplate = '''
import 'package:dio/dio.dart';
import 'package:{{project_name}}/core/models/api_response/api_response_handler.dart';
import 'package:{{project_name}}/core/models/api_response/base_api_response.dart';

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
''';

const permissionManagerTemplate = '''
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission states
enum PermissionState {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
  provisional,
  unknown,
}

/// Permission request result
class PermissionResult {
  const PermissionResult({
    required this.state,
    this.message,
    this.shouldShowRationale = false,
  });

  final PermissionState state;
  final String? message;
  final bool shouldShowRationale;

  bool get isGranted => state == PermissionState.granted;
  bool get isDenied => state == PermissionState.denied;
  bool get isPermanentlyDenied => state == PermissionState.permanentlyDenied;
}

class PermissionManager {
  static bool _isRequestingPermissions = false;
  static bool _isDialogShowing = false;

  static PermissionState _convertStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionState.granted;
      case PermissionStatus.denied:
        return PermissionState.denied;
      case PermissionStatus.permanentlyDenied:
        return PermissionState.permanentlyDenied;
      case PermissionStatus.restricted:
        return PermissionState.restricted;
      case PermissionStatus.limited:
        return PermissionState.limited;
      case PermissionStatus.provisional:
        return PermissionState.provisional;
    }
  }

  /// Request location permission
  static Future<PermissionResult> requestLocationPermission() async {
    try {
      final isServiceEnabled =
          await Permission.location.serviceStatus.isEnabled;
      if (!isServiceEnabled) {
        return const PermissionResult(
          state: PermissionState.denied,
          message: 'Location services are disabled.',
        );
      }
      final currentStatus = await Permission.location.status;
      if (currentStatus.isGranted) {
        return const PermissionResult(state: PermissionState.granted);
      }
      if (currentStatus.isPermanentlyDenied) {
        return const PermissionResult(
          state: PermissionState.permanentlyDenied,
          message: 'Location access is required. Please enable it in Settings.',
        );
      }
      final status = await Permission.location.request();
      return PermissionResult(
        state: _convertStatus(status),
        message: status.isPermanentlyDenied
            ? 'Location access is required. Please enable it in Settings.'
            : null,
        shouldShowRationale: status.isDenied,
      );
    } catch (e) {
      debugPrint('Error requesting location permission: \\\$e');
      return const PermissionResult(state: PermissionState.unknown);
    }
  }

  /// Request camera permission
  static Future<PermissionResult> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return PermissionResult(
        state: _convertStatus(status),
        message: status.isPermanentlyDenied
            ? 'Camera access is required. Please enable it in Settings.'
            : null,
        shouldShowRationale: status.isDenied,
      );
    } catch (e) {
      debugPrint('Error requesting camera permission: \\\$e');
      return const PermissionResult(state: PermissionState.unknown);
    }
  }

  /// Request photo library permission
  static Future<PermissionResult> requestPhotosPermission() async {
    try {
      final status = await Permission.photos.request();
      return PermissionResult(
        state: _convertStatus(status),
        message: status.isPermanentlyDenied
            ? 'Photo library access is required. Please enable it in Settings.'
            : null,
        shouldShowRationale: status.isDenied,
      );
    } catch (e) {
      debugPrint('Error requesting photos permission: \\\$e');
      return const PermissionResult(state: PermissionState.unknown);
    }
  }

  /// Generic permission request
  static Future<PermissionResult> requestPermission(
    Permission permission,
  ) async {
    try {
      final status = await permission.request();
      return PermissionResult(
        state: _convertStatus(status),
        message: status.isPermanentlyDenied
            ? 'Permission is required. Please enable it in Settings.'
            : null,
        shouldShowRationale: status.isDenied,
      );
    } catch (e) {
      debugPrint('Error requesting permission: \\\$e');
      return const PermissionResult(state: PermissionState.unknown);
    }
  }

  /// Request permission with automatic dialog handling
  static Future<bool> requestPermissionWithDialog({
    required BuildContext context,
    required Permission permission,
    required String permissionName,
    String? customPermanentlyDeniedMessage,
  }) async {
    try {
      final result = await requestPermission(permission);
      if (result.isGranted) return true;
      if (result.isPermanentlyDenied) {
        await _showPermissionSettingsDialog(
          context: context,
          permissionName: permissionName,
          message: customPermanentlyDeniedMessage ??
              '\\\$permissionName access is required. Please enable it in Settings.',
        );
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting permission with dialog: \\\$e');
      return false;
    }
  }

  /// Check if a permission is granted
  static Future<bool> isGranted(Permission permission) async {
    try {
      return await permission.status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Request multiple permissions at once
  static Future<Map<Permission, PermissionResult>>
      requestMultiplePermissions(List<Permission> permissions) async {
    if (_isRequestingPermissions) return {};
    try {
      _isRequestingPermissions = true;
      final statusMap = await permissions.request();
      final resultMap = <Permission, PermissionResult>{};
      for (final entry in statusMap.entries) {
        resultMap[entry.key] = PermissionResult(
          state: _convertStatus(entry.value),
          shouldShowRationale: entry.value.isDenied,
        );
      }
      return resultMap;
    } finally {
      _isRequestingPermissions = false;
    }
  }

  /// Open app settings
  static Future<bool> openAppSettingsPage() async {
    try {
      return await openAppSettings();
    } catch (e) {
      return false;
    }
  }

  static Future<void> _showPermissionSettingsDialog({
    required BuildContext context,
    required String permissionName,
    required String message,
  }) async {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('\\\$permissionName Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await openAppSettingsPage();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
    _isDialogShowing = false;
  }
}
''';

const permissionMessagesTemplate = '''
import 'dart:io';

import 'package:flutter/material.dart';

class PermissionMessages {
  static String getCameraSettingsMessage(BuildContext context) {
    return Platform.isIOS
        ? 'Camera access is required. Please enable it in Settings > Privacy & Security > Camera.'
        : 'Camera access is required. Please enable it in Settings > Apps > Permissions.';
  }

  static String getNotificationSettingsMessage(BuildContext context) {
    return Platform.isIOS
        ? 'Notification access is required. Please enable it in Settings > Notifications.'
        : 'Notification access is required. Please enable it in Settings > Apps > Notifications.';
  }

  static String getLocationSettingsMessage(BuildContext context) {
    return Platform.isIOS
        ? 'Location access is required. Please enable it in Settings > Privacy & Security > Location Services.'
        : 'Location access is required. Please enable it in Settings > Apps > Permissions.';
  }

  static String getPhotoLibrarySettingsMessage(BuildContext context) {
    return Platform.isIOS
        ? 'Photo library access is required. Please enable it in Settings > Privacy & Security > Photos.'
        : 'Photo library access is required. Please enable it in Settings > Apps > Permissions.';
  }
}
''';

const firebaseNotificationsTemplate = '''
import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class FirebaseNotificationService {
  factory FirebaseNotificationService() {
    return _instance;
  }

  FirebaseNotificationService._internal();

  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final StreamController<Map<String, dynamic>> navigationStreamController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get navigationStream =>
      navigationStreamController.stream;

  Future<String?> getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: \\\$token');
      return token;
    } catch (e) {
      debugPrint('Error fetching FCM token: \\\$e');
      return null;
    }
  }

  Future<bool> deleteFCMToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      return true;
    } catch (e) {
      debugPrint('Error deleting FCM token: \\\$e');
      return false;
    }
  }

  Future<void> initialize() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
  }

  Future<void> _onMessageOpenedApp(RemoteMessage message) async {
    navigationStreamController.add(message.data);
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message: \\\${message.data}');
    // TODO: Handle foreground notifications (show local notification)
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: \\\${message.data}');
}
''';

const localNotificationServiceTemplate = '''
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  factory LocalNotificationService() {
    return _instance;
  }

  LocalNotificationService._internal();

  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeLocalNotifications() async {
    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinInitializationSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final payload = notificationResponse.payload;
    if (payload == null) return;

    try {
      final decodedPayload = json.decode(payload) as Map<String, dynamic>;
      debugPrint('Parsed payload: \\\$decodedPayload');
      // TODO: Handle notification tap navigation
    } catch (e) {
      debugPrint('Error parsing notification payload: \\\$e');
    }
  }

  Future<void> sendLocalNotification(
    String? title,
    String? body,
    String payload,
  ) async {
    const androidNotificationDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title ?? 'Notification',
      body ?? '',
      notificationDetails,
      payload: payload,
    );
  }
}
''';

const nullCheckExtensionTemplate = '''
import 'dart:developer';

import 'package:flutter/foundation.dart';

extension NullCheck on Object? {
  bool get isNull => this == null;

  bool get isNotNull => this != null;
}

extension NullOrEmptyStringCheck on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullAndNotEmpty => this != null && this!.isNotEmpty;
}

extension NullOrEmptyListCheck<T> on List<T>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullAndNotEmpty => this != null && this!.isNotEmpty;
}

void debugLog(
  String message, {
  StackTrace? stackTrace,
}) {
  if (kDebugMode) {
    log(message, stackTrace: stackTrace);
  }
}
''';
