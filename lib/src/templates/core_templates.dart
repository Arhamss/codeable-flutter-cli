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
import 'package:hive_flutter/adapters.dart';

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

  /// Check if user is a guest
  bool getIsUserGuest() {
    final token = getAuthToken();
    return token == null || token.isEmpty;
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
import 'package:hive_flutter/hive_flutter.dart';
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
  static const guestLogin = 'auth/guest';
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
