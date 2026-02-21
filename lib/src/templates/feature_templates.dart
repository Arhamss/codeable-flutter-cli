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
import 'package:{{project_name}}/core/app_preferences/app_preferences.dart';
import 'package:{{project_name}}/core/di/injector.dart';
import 'package:{{project_name}}/features/{{feature_name}}/domain/repository/{{feature_name}}_repository.dart';

class {{FeatureName}}RepositoryImpl implements {{FeatureName}}Repository {
  {{FeatureName}}RepositoryImpl({ApiService? apiService, AppPreferences? cache})
    : _apiService = apiService ?? Injector.resolve<ApiService>(),
      _cache = cache ?? Injector.resolve<AppPreferences>();

  final ApiService _apiService;
  final AppPreferences _cache;

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
import 'package:{{project_name}}/features/{{feature_name}}/presentation/cubit/cubit.dart';
import 'package:{{project_name}}/features/{{feature_name}}/presentation/cubit/state.dart';

class {{FeatureName}}Screen extends StatelessWidget {
  const {{FeatureName}}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: '{{FeatureName}}'),
      body: BlocBuilder<{{FeatureName}}Cubit, {{FeatureName}}State>(
        builder: (context, state) {
          return const Center(
            child: Text('{{FeatureName}} Screen'),
          );
        },
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
  // TODO: Define your onboarding methods
  // Example:
  // Future<RepositoryResponse<bool>> login({required String email, required String password});
  // Future<RepositoryResponse<bool>> register({required String email, required String password});
}
''';

const onboardingRepositoryImplTemplate = '''
import 'package:{{project_name}}/core/api_service/api_service.dart';
import 'package:{{project_name}}/core/app_preferences/app_preferences.dart';
import 'package:{{project_name}}/core/di/injector.dart';
import 'package:{{project_name}}/features/onboarding/domain/repository/onboarding_repository.dart';

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
''';

const onboardingCubitTemplate = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{project_name}}/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:{{project_name}}/features/onboarding/presentation/cubit/state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required this.repository})
      : super(const OnboardingState());

  final OnboardingRepository repository;

  // TODO: Add cubit methods (login, register, etc.)
}
''';

const onboardingStateTemplate = '''
import 'package:equatable/equatable.dart';
import 'package:{{project_name}}/utils/helpers/data_state.dart';

class OnboardingState extends Equatable {
  const OnboardingState({
    this.login = const DataState.initial(),
  });

  final DataState<bool> login;

  OnboardingState copyWith({
    DataState<bool>? login,
  }) {
    return OnboardingState(
      login: login ?? this.login,
    );
  }

  @override
  List<Object?> get props => [login];
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
              SocialAuthButton(
                text: 'Sign in with Google',
                onPressed: () {
                  // TODO: Implement Google sign-in
                },
              ),
              const SizedBox(height: 16),
              SocialAuthButton(
                text: 'Sign in with Apple',
                onPressed: () {
                  // TODO: Implement Apple sign-in
                },
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
