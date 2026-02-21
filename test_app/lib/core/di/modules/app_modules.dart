import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:test_app/core/api_service/api_service.dart';
import 'package:test_app/core/app_preferences/app_preferences.dart';

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
