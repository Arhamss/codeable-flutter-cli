import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:my_dart_cli/src/generators/keystore_generator.dart';
import 'package:my_dart_cli/src/template_engine.dart';
import 'package:my_dart_cli/src/templates/analysis_options_template.dart';
import 'package:my_dart_cli/src/templates/android_templates.dart';
import 'package:my_dart_cli/src/templates/app_templates.dart';
import 'package:my_dart_cli/src/templates/config_templates.dart';
import 'package:my_dart_cli/src/templates/constants_templates.dart';
import 'package:my_dart_cli/src/templates/core_templates.dart';
import 'package:my_dart_cli/src/templates/feature_templates.dart';
import 'package:my_dart_cli/src/templates/ios_templates.dart';
import 'package:my_dart_cli/src/templates/l10n_templates.dart';
import 'package:my_dart_cli/src/templates/pubspec_template.dart';
import 'package:my_dart_cli/src/templates/router_templates.dart';
import 'package:my_dart_cli/src/templates/utils_templates.dart';

class ProjectGenerator {
  ProjectGenerator({required Logger logger}) : _logger = logger;

  final Logger _logger;

  Future<bool> generate({
    required String projectName,
    required String orgName,
    required String description,
    required String outputPath,
  }) async {
    final snakeName = TemplateEngine.toSnakeCase(projectName)
        .replaceAll(RegExp('[^a-z0-9_]'), '')
        .replaceAll(RegExp('^[0-9]'), '');

    final vars = TemplateEngine.buildVars(
      projectName: snakeName,
      orgName: orgName,
      description: description,
    );

    // Also need feature-specific vars for onboarding
    final onboardingVars = {
      ...vars,
      'feature_name': 'onboarding',
      'FeatureName': 'Onboarding',
    };

    final projectPath = '$outputPath/$snakeName';

    // Extract org prefix (everything except last segment) for flutter create
    final orgParts = orgName.split('.');
    final orgPrefix = orgParts.length > 1
        ? orgParts.sublist(0, orgParts.length - 1).join('.')
        : orgName;

    // Step 1: Run flutter create
    final flutterCreateProgress =
        _logger.progress('Running flutter create');
    final createResult = await Process.run(
      'flutter',
      [
        'create',
        '--org',
        orgPrefix,
        '--project-name',
        snakeName,
        projectPath,
      ],
    );

    if (createResult.exitCode != 0) {
      flutterCreateProgress.fail('flutter create failed');
      _logger.err(createResult.stderr.toString());
      return false;
    }
    flutterCreateProgress.complete('Flutter project created');

    // Step 2: Clean default lib/ and test/
    final cleanProgress = _logger.progress('Cleaning default files');
    final libDir = Directory('$projectPath/lib');
    if (libDir.existsSync()) {
      for (final entity in libDir.listSync()) {
        entity.deleteSync(recursive: true);
      }
    }
    final testDir = Directory('$projectPath/test');
    if (testDir.existsSync()) {
      for (final entity in testDir.listSync()) {
        entity.deleteSync(recursive: true);
      }
    }
    cleanProgress.complete('Default files cleaned');

    // Step 3: Create directory structure
    final structureProgress =
        _logger.progress('Creating project structure');
    const directories = [
      // App
      'lib/app/view',
      // Config
      'lib/config',
      // Constants
      'lib/constants',
      // Core
      'lib/core/api_service',
      'lib/core/app_preferences',
      'lib/core/di/modules',
      'lib/core/endpoints',
      'lib/core/enums',
      'lib/core/guards',
      'lib/core/locale/cubit',
      'lib/core/models/api_response',
      'lib/core/models/auth',
      // Features - Onboarding
      'lib/features/onboarding/data/models',
      'lib/features/onboarding/data/repository',
      'lib/features/onboarding/domain/repository',
      'lib/features/onboarding/presentation/cubit',
      'lib/features/onboarding/presentation/views',
      'lib/features/onboarding/presentation/widgets',
      // Go Router
      'lib/go_router',
      // L10n
      'lib/l10n/arb',
      // Utils
      'lib/utils/extensions',
      'lib/utils/helpers',
      'lib/utils/response_data_model',
      'lib/utils/widgets/core_widgets',
      // Assets
      'assets/images',
      'assets/vectors',
      'assets/lottie',
    ];

    for (final dir in directories) {
      Directory('$projectPath/$dir').createSync(recursive: true);
    }
    structureProgress.complete('Project structure created');

    // Step 4: Write all template files
    final filesProgress = _logger.progress('Writing template files');

    final render = TemplateEngine.render;

    final files = <String, String>{
      // Entry points
      'lib/main_development.dart': render(mainDevelopmentTemplate, vars),
      'lib/main_production.dart': render(mainProductionTemplate, vars),
      'lib/bootstrap.dart': render(bootstrapTemplate, vars),
      'lib/exports.dart': render(exportsTemplate, vars),

      // App
      'lib/app/view/app_page.dart': render(appPageTemplate, vars),
      'lib/app/view/app_view.dart': render(appViewTemplate, vars),
      'lib/app/view/splash.dart': render(splashTemplate, vars),

      // Config
      'lib/config/flavor_config.dart': render(flavorConfigTemplate, vars),
      'lib/config/api_environment.dart':
          render(apiEnvironmentTemplate, vars),
      'lib/config/remote_config.dart': render(remoteConfigTemplate, vars),

      // Constants
      'lib/constants/app_colors.dart': render(appColorsTemplate, vars),
      'lib/constants/app_text_style.dart':
          render(appTextStyleTemplate, vars),
      'lib/constants/asset_paths.dart': render(assetPathsTemplate, vars),
      'lib/constants/constants.dart': render(constantsTemplate, vars),
      'lib/constants/export.dart': render(constantsExportTemplate, vars),

      // Core - API Service
      'lib/core/api_service/api_service.dart':
          render(apiServiceTemplate, vars),
      'lib/core/api_service/app_api_exception.dart':
          render(appApiExceptionTemplate, vars),
      'lib/core/api_service/authentication_interceptor.dart':
          render(authInterceptorTemplate, vars),
      'lib/core/api_service/log_interceptor.dart':
          render(logInterceptorTemplate, vars),

      // Core - Preferences
      'lib/core/app_preferences/base_storage.dart':
          render(baseStorageTemplate, vars),
      'lib/core/app_preferences/app_preferences.dart':
          render(appPreferencesTemplate, vars),

      // Core - DI
      'lib/core/di/injector.dart': render(injectorTemplate, vars),
      'lib/core/di/modules/app_modules.dart':
          render(appModulesTemplate, vars),

      // Core - Endpoints
      'lib/core/endpoints/endpoints.dart': render(endpointsTemplate, vars),

      // Core - Validators
      'lib/core/field_validators.dart':
          render(fieldValidatorsTemplate, vars),

      // Core - Locale
      'lib/core/locale/cubit/locale_cubit.dart':
          render(localeCubitTemplate, vars),
      'lib/core/locale/cubit/locale_state.dart':
          render(localeStateTemplate, vars),

      // Core - Models
      'lib/core/models/api_response/api_response_model.dart':
          render(apiResponseModelTemplate, vars),

      // Go Router
      'lib/go_router/exports.dart': render(routerExportsTemplate, vars),
      'lib/go_router/router.dart': render(routerTemplate, vars),
      'lib/go_router/routes.dart': render(routesTemplate, vars),

      // L10n
      'lib/l10n/l10n.dart': render(l10nDartTemplate, vars),
      'lib/l10n/arb/app_en.arb': render(appEnArbTemplate, vars),
      'lib/l10n/arb/app_es.arb': render(appEsArbTemplate, vars),

      // Utils - Helpers
      'lib/utils/helpers/data_state.dart': render(dataStateTemplate, vars),
      'lib/utils/helpers/repository_response.dart':
          render(repositoryResponseTemplate, vars),
      'lib/utils/helpers/logger_helper.dart':
          render(loggerHelperTemplate, vars),
      'lib/utils/helpers/toast_helper.dart':
          render(toastHelperTemplate, vars),
      'lib/utils/helpers/typedef.dart': render(typedefTemplate, vars),

      // Utils - Response model
      'lib/utils/response_data_model/response_data_model.dart':
          render(responseDataModelTemplate, vars),
      'lib/utils/response_data_model/api_response_parser.dart':
          render(apiResponseParserTemplate, vars),

      // Utils - Core Widgets
      'lib/utils/widgets/core_widgets/export.dart':
          render(coreWidgetsExportTemplate, vars),
      'lib/utils/widgets/core_widgets/app_bar.dart':
          render(customAppBarTemplate, vars),
      'lib/utils/widgets/core_widgets/button.dart':
          render(customButtonTemplate, vars),
      'lib/utils/widgets/core_widgets/text_field.dart':
          render(customTextFieldTemplate, vars),

      // Onboarding feature
      'lib/features/onboarding/domain/repository/onboarding_repository.dart':
          render(onboardingRepositoryTemplate, onboardingVars),
      'lib/features/onboarding/data/repository/'
              'onboarding_repository_impl.dart':
          render(onboardingRepositoryImplTemplate, onboardingVars),
      'lib/features/onboarding/data/models/'
              'guest_login_response_model.dart':
          render(guestLoginResponseModelTemplate, onboardingVars),
      'lib/features/onboarding/presentation/cubit/cubit.dart':
          render(onboardingCubitTemplate, onboardingVars),
      'lib/features/onboarding/presentation/cubit/state.dart':
          render(onboardingStateTemplate, onboardingVars),
      'lib/features/onboarding/presentation/views/login_screen.dart':
          render(loginScreenTemplate, onboardingVars),
      'lib/features/onboarding/presentation/widgets/.gitkeep': '',

      // Placeholder assets
      'assets/images/.gitkeep': '',
      'assets/vectors/.gitkeep': '',
      'assets/lottie/.gitkeep': '',
    };

    for (final entry in files.entries) {
      final file = File('$projectPath/${entry.key}');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(entry.value);
    }
    filesProgress.complete('Template files written');

    // Step 5: Replace pubspec.yaml
    final pubspecProgress = _logger.progress('Configuring pubspec.yaml');
    File('$projectPath/pubspec.yaml')
        .writeAsStringSync(render(pubspecTemplate, vars));
    pubspecProgress.complete('pubspec.yaml configured');

    // Step 6: Write analysis_options.yaml
    File('$projectPath/analysis_options.yaml')
        .writeAsStringSync(analysisOptionsTemplate);

    // Step 7: Write l10n.yaml
    File('$projectPath/l10n.yaml').writeAsStringSync(l10nYamlTemplate);

    // Step 8: Update Android build config
    final androidProgress =
        _logger.progress('Configuring Android');
    final buildGradlePath = '$projectPath/android/app/build.gradle.kts';
    if (File(buildGradlePath).existsSync()) {
      File(buildGradlePath)
          .writeAsStringSync(render(androidBuildGradleTemplate, vars));
    }

    // Write proguard rules
    File('$projectPath/android/app/proguard-rules.pro')
        .writeAsStringSync(proguardRulesTemplate);

    // Update gradle.properties
    File('$projectPath/android/gradle.properties')
        .writeAsStringSync(gradlePropertiesTemplate);

    // Write AndroidManifest
    final manifestPath =
        '$projectPath/android/app/src/main/AndroidManifest.xml';
    File(manifestPath).writeAsStringSync(androidManifestTemplate);

    androidProgress.complete('Android configured');

    // Step 9: Configure iOS
    final iosProgress = _logger.progress('Configuring iOS');

    // Write Podfile with permission handlers
    File('$projectPath/ios/Podfile')
        .writeAsStringSync(iosPodfileTemplate);

    // Write Info.plist with permissions
    final infoPlistPath = '$projectPath/ios/Runner/Info.plist';
    File(infoPlistPath)
        .writeAsStringSync(render(iosInfoPlistTemplate, vars));

    // Write entitlements for push notifications & Sign in with Apple
    File('$projectPath/ios/Runner/Runner.entitlements')
        .writeAsStringSync(iosEntitlementsTemplate);
    File('$projectPath/ios/Runner/RunnerRelease.entitlements')
        .writeAsStringSync(iosReleaseEntitlementsTemplate);

    iosProgress.complete('iOS configured');

    // Step 10: Generate keystore
    await KeystoreGenerator(logger: _logger).generate(
      projectPath: projectPath,
      projectName: snakeName,
      orgName: orgName,
    );

    // Step 11: Run flutter pub get
    final pubGetProgress = _logger.progress('Running flutter pub get');
    final pubGetResult = await Process.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: projectPath,
    );

    if (pubGetResult.exitCode != 0) {
      pubGetProgress.fail('flutter pub get failed');
      _logger.err(pubGetResult.stderr.toString());
    } else {
      pubGetProgress.complete('Dependencies installed');
    }

    // Done!
    _logger
      ..info('')
      ..success('Project $snakeName created successfully!')
      ..info('')
      ..info('Project location: $projectPath')
      ..info('')
      ..info('Next steps:')
      ..info('  cd $snakeName')
      ..info(
        '  flutter run --flavor development '
        '-t lib/main_development.dart',
      )
      ..info('')
      ..info('To create a new feature:')
      ..info('  codeable_cli feature <feature_name>')
      ..info('');

    return true;
  }
}
