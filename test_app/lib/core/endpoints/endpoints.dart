import 'package:test_app/config/api_environment.dart';

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
