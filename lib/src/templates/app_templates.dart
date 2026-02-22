const mainDevelopmentTemplate = '''
import 'package:device_preview/device_preview.dart';
import 'package:{{project_name}}/app/view/app_page.dart';
import 'package:{{project_name}}/bootstrap.dart';
import 'package:{{project_name}}/config/flavor_config.dart';

Future<void> main() async {
  FlavorConfig(flavor: Flavor.development);
  await bootstrap(
    () => DevicePreview(
      enabled: false,
      builder: (context) {
        return const App();
      },
    ),
  );
}
''';

const mainStagingTemplate = '''
import 'package:device_preview/device_preview.dart';
import 'package:{{project_name}}/app/view/app_page.dart';
import 'package:{{project_name}}/bootstrap.dart';
import 'package:{{project_name}}/config/flavor_config.dart';

Future<void> main() async {
  FlavorConfig(flavor: Flavor.staging);
  await bootstrap(
    () => DevicePreview(
      enabled: false,
      builder: (context) {
        return const App();
      },
    ),
  );
}
''';

const mainProductionTemplate = '''
import 'package:device_preview/device_preview.dart';
import 'package:{{project_name}}/app/view/app_page.dart';
import 'package:{{project_name}}/bootstrap.dart';
import 'package:{{project_name}}/config/flavor_config.dart';

Future<void> main() async {
  FlavorConfig(flavor: Flavor.production);
  await bootstrap(
    () => DevicePreview(
      enabled: false,
      builder: (context) {
        return const App();
      },
    ),
  );
}
''';

const bootstrapTemplate = '''
import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:{{project_name}}/core/di/injector.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(\${bloc.runtimeType}, \$change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(\${bloc.runtimeType}, \$error, \$stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Bloc.observer = const AppBlocObserver();

  await Injector.setup();
  runApp(await builder());
}
''';

const appPageTemplate = '''
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:{{project_name}}/app/view/app_view.dart';
import 'package:{{project_name}}/core/locale/cubit/locale_cubit.dart';
import 'package:{{project_name}}/exports.dart';
import 'package:{{project_name}}/features/onboarding/data/repository/onboarding_repository_impl.dart';
import 'package:{{project_name}}/features/onboarding/presentation/cubit/cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Phoenix(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LocaleCubit(context: context),
          ),
          BlocProvider(
            create: (context) => OnboardingCubit(
              repository: OnboardingRepositoryImpl(),
            ),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}
''';

/// Base app_page without onboarding — used when roles are specified
/// (onboarding cubits are added programmatically per role).
const appPageBaseTemplate = '''
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:{{project_name}}/app/view/app_view.dart';
import 'package:{{project_name}}/core/locale/cubit/locale_cubit.dart';
import 'package:{{project_name}}/exports.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Phoenix(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LocaleCubit(context: context),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}
''';

const appViewTemplate = '''
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{project_name}}/constants/app_colors.dart';
import 'package:{{project_name}}/core/locale/cubit/locale_cubit.dart';
import 'package:{{project_name}}/go_router/exports.dart';
import 'package:{{project_name}}/l10n/gen/app_localizations.dart';
import 'package:toastification/toastification.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return ToastificationWrapper(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            child: MaterialApp.router(
              routerConfig: AppRouter.router,
              theme: ThemeData(
                appBarTheme: const AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                scaffoldBackgroundColor: AppColors.backgroundPrimary,
                useMaterial3: true,
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: AppColors.blackPrimary,
                  selectionColor:
                      AppColors.blackPrimary.withValues(alpha: 0.25),
                  selectionHandleColor: AppColors.blackPrimary,
                ),
              ),
              locale: DevicePreview.locale(context) ?? state.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              debugShowCheckedModeBanner: false,
              builder: DevicePreview.appBuilder,
            ),
          ),
        );
      },
    );
  }
}
''';

const splashTemplate = '''
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:{{project_name}}/core/app_preferences/app_preferences.dart';
import 'package:{{project_name}}/core/di/injector.dart';
import 'package:{{project_name}}/exports.dart';
import 'package:{{project_name}}/utils/helpers/logger_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate();
    });
  }

  void _navigate() {
    final authToken = Injector.resolve<AppPreferences>().getAuthToken();
    FlutterNativeSplash.remove();

    if ((authToken ?? '').isEmpty) {
      context.goNamed(AppRouteNames.loginScreen);
    } else {
      AppLogger.info('Auth token found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
    );
  }
}
''';

/// Base splash for role-based projects — navigates to onboarding screen.
/// Uses {{onboarding_route_name}} placeholder for the first role's route.
const splashBaseTemplate = '''
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:{{project_name}}/exports.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate();
    });
  }

  void _navigate() {
    FlutterNativeSplash.remove();
    context.goNamed(AppRouteNames.{{onboarding_route_name}});
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
    );
  }
}
''';

const exportsTemplate = '''
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:flutter_svg/svg.dart';
export 'package:go_router/go_router.dart';
export 'package:{{project_name}}/constants/app_colors.dart';
export 'package:{{project_name}}/constants/app_text_style.dart';
export 'package:{{project_name}}/constants/asset_paths.dart';
export 'package:{{project_name}}/constants/constants.dart';
export 'package:{{project_name}}/go_router/exports.dart';
export 'package:{{project_name}}/utils/helpers/toast_helper.dart';
export 'package:{{project_name}}/utils/widgets/core_widgets/export.dart';
''';
