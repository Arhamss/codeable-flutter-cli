import 'package:test_app/core/api_service/api_service.dart';
import 'package:test_app/core/app_preferences/app_preferences.dart';
import 'package:test_app/core/di/injector.dart';
import 'package:test_app/features/onboarding/domain/repository/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({
    ApiService? apiService,
    AppPreferences? cache,
  })  : _apiService = apiService ?? Injector.resolve<ApiService>(),
        _cache = cache ?? Injector.resolve<AppPreferences>();

  final ApiService _apiService;
  final AppPreferences _cache;

  // TODO: Implement repository methods
}
