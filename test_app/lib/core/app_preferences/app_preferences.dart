import 'package:test_app/core/app_preferences/base_storage.dart';
import 'package:test_app/utils/helpers/logger_helper.dart';

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
