// ============================================================
// Generic feature scaffolding templates (for `feature` command)
// ============================================================

const featureRepositoryTemplate = '''
import 'package:{{project_name}}/utils/helpers/repository_response.dart';

abstract class {{FeatureName}}Repository {
  // TODO: Define your repository methods
  // Example:
  // Future<RepositoryResponse<List<{{FeatureName}}Model>>> getAll();
  // Future<RepositoryResponse<{{FeatureName}}Model>> getById(String id);
}
''';

const featureRepositoryImplTemplate = '''
import 'package:{{project_name}}/core/api_service/api_service.dart';
import 'package:{{project_name}}/core/di/injector.dart';
import 'package:{{project_name}}/features/{{feature_name}}/domain/repository/{{feature_name}}_repository.dart';

class {{FeatureName}}RepositoryImpl implements {{FeatureName}}Repository {
  {{FeatureName}}RepositoryImpl({
    ApiService? apiService,
  }) : _apiService = apiService ?? Injector.resolve<ApiService>();

  final ApiService _apiService;

  // TODO: Implement repository methods
}
''';

const featureModelTemplate = '''
import 'package:equatable/equatable.dart';

class {{FeatureName}}Model extends Equatable {
  const {{FeatureName}}Model({
    required this.id,
  });

  factory {{FeatureName}}Model.fromJson(Map<String, dynamic> json) {
    return {{FeatureName}}Model(
      id: json['id'] as String? ?? '',
    );
  }

  final String id;

  Map<String, dynamic> toJson() => {
        'id': id,
      };

  {{FeatureName}}Model copyWith({
    String? id,
  }) {
    return {{FeatureName}}Model(
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [id];
}
''';

const featureCubitTemplate = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{project_name}}/features/{{feature_name}}/domain/repository/{{feature_name}}_repository.dart';
import 'package:{{project_name}}/features/{{feature_name}}/presentation/cubit/state.dart';

class {{FeatureName}}Cubit extends Cubit<{{FeatureName}}State> {
  {{FeatureName}}Cubit({required this.repository})
      : super(const {{FeatureName}}State());

  final {{FeatureName}}Repository repository;

  // TODO: Add cubit methods
}
''';

const featureStateTemplate = '''
import 'package:equatable/equatable.dart';
import 'package:{{project_name}}/utils/helpers/data_state.dart';

class {{FeatureName}}State extends Equatable {
  const {{FeatureName}}State({
    this.fetch = const DataState.initial(),
  });

  final DataState<dynamic> fetch;

  {{FeatureName}}State copyWith({
    DataState<dynamic>? fetch,
  }) {
    return {{FeatureName}}State(
      fetch: fetch ?? this.fetch,
    );
  }

  @override
  List<Object?> get props => [fetch];
}
''';

const featureScreenTemplate = '''
import 'package:{{project_name}}/exports.dart';

class {{FeatureName}}Screen extends StatelessWidget {
  const {{FeatureName}}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('{{FeatureName}}', style: context.t2),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('{{FeatureName}} Screen'),
      ),
    );
  }
}
''';

// ============================================================
// Sample onboarding feature (included in `create` command)
// ============================================================

const onboardingRepositoryTemplate = '''
import 'package:{{project_name}}/utils/helpers/repository_response.dart';

abstract class OnboardingRepository {
  Future<RepositoryResponse<bool>> guestLogin();
}
''';

const onboardingRepositoryImplTemplate = '''
import 'package:{{project_name}}/core/api_service/api_service.dart';
import 'package:{{project_name}}/core/app_preferences/app_preferences.dart';
import 'package:{{project_name}}/core/di/injector.dart';
import 'package:{{project_name}}/core/endpoints/endpoints.dart';
import 'package:{{project_name}}/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:{{project_name}}/utils/helpers/repository_response.dart';
import 'package:{{project_name}}/utils/response_data_model/api_response_parser.dart';
import 'package:{{project_name}}/features/onboarding/data/models/guest_login_response_model.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({
    ApiService? apiService,
    AppPreferences? cache,
  })  : _apiService = apiService ?? Injector.resolve<ApiService>(),
        _cache = cache ?? Injector.resolve<AppPreferences>();

  final ApiService _apiService;
  final AppPreferences _cache;

  @override
  Future<RepositoryResponse<bool>> guestLogin() async {
    try {
      final response = await _apiService.post(endpoint: Endpoints.guestLogin);
      final parsed = ApiResponseParser.parse<GuestLoginResponseModel>(
        response,
        GuestLoginResponseModel.fromJson,
      );

      if (parsed != null) {
        _cache.setAuthToken(parsed.accessToken);
        _cache.setRefreshToken(parsed.refreshToken);
        return RepositoryResponse(isSuccess: true, data: true);
      }

      return RepositoryResponse(
        isSuccess: false,
        message: 'Failed to parse guest login response',
      );
    } catch (e) {
      return RepositoryResponse(
        isSuccess: false,
        message: e.toString(),
      );
    }
  }
}
''';

const guestLoginResponseModelTemplate = '''
import 'package:equatable/equatable.dart';

class GuestLoginResponseModel extends Equatable {
  const GuestLoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
  });

  factory GuestLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return GuestLoginResponseModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      expiresIn: json['expiresIn'] as int?,
    );
  }

  final String accessToken;
  final String refreshToken;
  final int? expiresIn;

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn,
      };

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn];
}
''';

const onboardingCubitTemplate = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{project_name}}/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:{{project_name}}/features/onboarding/presentation/cubit/state.dart';
import 'package:{{project_name}}/utils/helpers/data_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required this.repository})
      : super(const OnboardingState());

  final OnboardingRepository repository;

  Future<void> guestLogin() async {
    emit(state.copyWith(guestLogin: const DataState.loading()));
    final response = await repository.guestLogin();
    if (response.isSuccess) {
      emit(state.copyWith(guestLogin: const DataState.loaded(data: true)));
    } else {
      emit(
        state.copyWith(
          guestLogin: DataState.failure(error: response.message),
        ),
      );
    }
  }
}
''';

const onboardingStateTemplate = '''
import 'package:equatable/equatable.dart';
import 'package:{{project_name}}/utils/helpers/data_state.dart';

class OnboardingState extends Equatable {
  const OnboardingState({
    this.guestLogin = const DataState.initial(),
  });

  final DataState<bool> guestLogin;

  OnboardingState copyWith({
    DataState<bool>? guestLogin,
  }) {
    return OnboardingState(
      guestLogin: guestLogin ?? this.guestLogin,
    );
  }

  @override
  List<Object?> get props => [guestLogin];
}
''';

const loginScreenTemplate = '''
import 'package:{{project_name}}/exports.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Welcome',
                style: context.h1,
              ),
              const SizedBox(height: 8),
              Text(
                'Log in to continue',
                style: context.b1.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              CustomButton(
                text: 'Sign in with Google',
                onPressed: () {
                  // TODO: Implement Google sign-in
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Continue as Guest',
                onPressed: () {
                  context.goNamed(AppRouteNames.homeScreen);
                },
                backgroundColor: AppColors.surface,
                textColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
''';
