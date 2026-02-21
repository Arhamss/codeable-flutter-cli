import 'package:dio/dio.dart';
import 'package:test_app/core/app_preferences/app_preferences.dart';
import 'package:test_app/core/endpoints/endpoints.dart';
import 'package:test_app/exports.dart';

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
      options.headers['Authorization'] = 'Bearer \$token';
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
        err.requestOptions.headers['Authorization'] = 'Bearer \$newToken';
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
        '\${Endpoints.baseUrl}/\${Endpoints.refresh}',
        options: Options(headers: {'Authorization': 'Bearer \$refreshToken'}),
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
