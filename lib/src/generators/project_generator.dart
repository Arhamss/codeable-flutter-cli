import 'dart:io';
import 'dart:isolate';

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
import 'package:my_dart_cli/src/templates/readme_template.dart';
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

    // Step 2: Clean default lib/, test/, and remove unused platforms
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

    // Remove unused platform folders (linux, macos, web, windows)
    for (final platform in ['linux', 'macos', 'web', 'windows']) {
      final platformDir = Directory('$projectPath/$platform');
      if (platformDir.existsSync()) {
        platformDir.deleteSync(recursive: true);
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
      'lib/core/notifications',
      'lib/core/permissions',
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
      'assets/svgs',
      'assets/animation',
      'assets/fonts',
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
      'lib/main_staging.dart': render(mainStagingTemplate, vars),
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

      // Core - Models - API Response
      'lib/core/models/api_response/api_response_model.dart':
          render(apiResponseModelTemplate, vars),
      'lib/core/models/api_response/api_error.dart':
          render(apiErrorTemplate, vars),
      'lib/core/models/api_response/base_api_response.dart':
          render(baseApiResponseTemplate, vars),
      'lib/core/models/api_response/api_response_handler.dart':
          render(apiResponseHandlerTemplate, vars),
      'lib/core/models/api_response/response_model.dart':
          render(responseModelTemplate, vars),

      // Core - Permissions
      'lib/core/permissions/permission_manager.dart':
          render(permissionManagerTemplate, vars),
      'lib/core/permissions/permission_messages.dart':
          render(permissionMessagesTemplate, vars),

      // Core - Notifications
      'lib/core/notifications/firebase_notifications.dart':
          render(firebaseNotificationsTemplate, vars),
      'lib/core/notifications/local_notification_service.dart':
          render(localNotificationServiceTemplate, vars),

      // Utils - Extensions
      'lib/utils/extensions/null_check.dart':
          render(nullCheckExtensionTemplate, vars),

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
      'lib/utils/helpers/api_call_state.dart':
          render(apiCallStateTemplate, vars),
      'lib/utils/helpers/repository_response.dart':
          render(repositoryResponseTemplate, vars),
      'lib/utils/helpers/logger_helper.dart':
          render(loggerHelperTemplate, vars),
      'lib/utils/helpers/toast_helper.dart':
          render(toastHelperTemplate, vars),
      'lib/utils/helpers/typedef.dart': render(typedefTemplate, vars),
      'lib/utils/helpers/focus_handler.dart':
          render(focusHandlerTemplate, vars),
      'lib/utils/helpers/string_helper.dart':
          render(stringHelperTemplate, vars),
      'lib/utils/helpers/color_helper.dart':
          render(colorHelperTemplate, vars),
      'lib/utils/helpers/decorations_helper.dart':
          render(decorationsHelperTemplate, vars),
      'lib/utils/helpers/layout_helper.dart':
          render(layoutHelperTemplate, vars),

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
      'lib/utils/widgets/core_widgets/outline_button.dart':
          render(customOutlineButtonTemplate, vars),
      'lib/utils/widgets/core_widgets/text_button.dart':
          render(customTextButtonTemplate, vars),
      'lib/utils/widgets/core_widgets/icon_button.dart':
          render(customIconButtonTemplate, vars),
      'lib/utils/widgets/core_widgets/text_field.dart':
          render(customTextFieldTemplate, vars),
      'lib/utils/widgets/core_widgets/search_field.dart':
          render(searchFieldTemplate, vars),
      'lib/utils/widgets/core_widgets/loading_widget.dart':
          render(loadingWidgetTemplate, vars),
      'lib/utils/widgets/core_widgets/shimmer_loading_widget.dart':
          render(shimmerLoadingWidgetTemplate, vars),
      'lib/utils/widgets/core_widgets/retry_widget.dart':
          render(retryWidgetTemplate, vars),
      'lib/utils/widgets/core_widgets/empty_state_widget.dart':
          render(emptyStateWidgetTemplate, vars),
      'lib/utils/widgets/core_widgets/confirmation_dialog.dart':
          render(confirmationDialogTemplate, vars),
      'lib/utils/widgets/core_widgets/section_title.dart':
          render(sectionTitleTemplate, vars),
      'lib/utils/widgets/core_widgets/cached_network_image.dart':
          render(cachedNetworkImageTemplate, vars),
      'lib/utils/widgets/core_widgets/social_auth_button.dart':
          render(socialAuthButtonTemplate, vars),
      'lib/utils/widgets/core_widgets/bottom_sheet.dart':
          render(bottomSheetTemplate, vars),
      'lib/utils/widgets/core_widgets/paginated_list_view.dart':
          render(paginatedListViewTemplate, vars),

      // Onboarding feature
      'lib/features/onboarding/domain/repository/onboarding_repository.dart':
          render(onboardingRepositoryTemplate, onboardingVars),
      'lib/features/onboarding/data/repository/'
              'onboarding_repository_impl.dart':
          render(onboardingRepositoryImplTemplate, onboardingVars),
      'lib/features/onboarding/data/models/.gitkeep': '',
      'lib/features/onboarding/presentation/cubit/cubit.dart':
          render(onboardingCubitTemplate, onboardingVars),
      'lib/features/onboarding/presentation/cubit/state.dart':
          render(onboardingStateTemplate, onboardingVars),
      'lib/features/onboarding/presentation/views/login_screen.dart':
          render(loginScreenTemplate, onboardingVars),
      'lib/features/onboarding/presentation/widgets/.gitkeep': '',

      // Placeholder assets
      'assets/images/.gitkeep': '',
      'assets/svgs/.gitkeep': '',
      'assets/animation/.gitkeep': '',
      'assets/fonts/.gitkeep': '',

      // README
      'README.md': render(readmeTemplate, vars),
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

    // Inject "Copy GoogleService-Info.plist" run script into Xcode project
    _injectGoogleServiceCopyScript(projectPath);

    iosProgress.complete('iOS configured');

    // Step 10: Create firebase config directory structure
    for (final flavor in ['development', 'staging', 'production']) {
      Directory('$projectPath/firebase/$flavor').createSync(recursive: true);
    }

    // Step 11: Copy bundled assets (splash, app icons, SVGs)
    await _copyBundledAssets(projectPath);

    // Step 12: Generate keystore
    await KeystoreGenerator(logger: _logger).generate(
      projectPath: projectPath,
      projectName: snakeName,
      orgName: orgName,
    );

    // Step 13: Run flutter pub get
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

  /// Resolves the CLI package's bundled assets directory path.
  Future<String> _resolveAssetsPath() async {
    final packageUri =
        Uri.parse('package:my_dart_cli/src/assets/marker');
    final resolved = await Isolate.resolvePackageUri(packageUri);
    if (resolved == null) {
      throw Exception('Could not resolve CLI package asset path');
    }
    // resolved points to lib/src/assets/marker, go up one to get assets dir
    return resolved.resolve('.').toFilePath();
  }

  /// Copies all bundled assets (splash, app icons, SVGs) into the
  /// generated project.
  Future<void> _copyBundledAssets(String projectPath) async {
    final assetsProgress = _logger.progress('Copying app icons & splash');

    try {
      final assetsRoot = await _resolveAssetsPath();

      // 1. Splash image → assets/images/
      _copyFile(
        '$assetsRoot/splash/splash-with-logo.png',
        '$projectPath/assets/images/splash-with-logo.png',
      );

      // 2. SVG logos → assets/svgs/
      final svgDir = Directory('$assetsRoot/svgs');
      if (svgDir.existsSync()) {
        for (final file in svgDir.listSync().whereType<File>()) {
          final name = file.uri.pathSegments.last;
          _copyFile(file.path, '$projectPath/assets/svgs/$name');
        }
      }

      // 3. Android app icons → android/app/src/main/res/
      final androidResBase = '$projectPath/android/app/src/main/res';
      // Clear default Flutter mipmap icons before copying ours
      final resDir = Directory(androidResBase);
      if (resDir.existsSync()) {
        for (final entity in resDir.listSync()) {
          if (entity is Directory &&
              entity.path.contains('mipmap')) {
            entity.deleteSync(recursive: true);
          }
        }
      }
      final androidSrcDir = Directory('$assetsRoot/android');
      if (androidSrcDir.existsSync()) {
        _copyDirectory(androidSrcDir.path, androidResBase);
      }

      // 4. iOS app icons → ios/Runner/Assets.xcassets/AppIcon.appiconset/
      final iosIconDst =
          '$projectPath/ios/Runner/Assets.xcassets/AppIcon.appiconset';
      final iosIconSrc = Directory('$assetsRoot/ios/AppIcon.appiconset');
      if (iosIconSrc.existsSync()) {
        // Clear default Flutter icons before copying ours
        final dstDir = Directory(iosIconDst);
        if (dstDir.existsSync()) {
          for (final file in dstDir.listSync().whereType<File>()) {
            file.deleteSync();
          }
        } else {
          dstDir.createSync(recursive: true);
        }
        for (final file in iosIconSrc.listSync().whereType<File>()) {
          final name = file.uri.pathSegments.last;
          _copyFile(file.path, '$iosIconDst/$name');
        }
      }

      assetsProgress.complete('App icons & splash copied');
    } catch (e) {
      assetsProgress.fail('Failed to copy assets: $e');
    }
  }

  /// Recursively copies a directory tree, preserving sub-folder structure.
  void _copyDirectory(String srcPath, String dstPath) {
    final srcDir = Directory(srcPath);
    for (final entity in srcDir.listSync(recursive: true)) {
      final relativePath = entity.path.substring(srcDir.path.length);
      if (entity is File) {
        final destFile = File('$dstPath$relativePath');
        destFile.parent.createSync(recursive: true);
        entity.copySync(destFile.path);
      }
    }
  }

  /// Copies a single file, creating parent directories as needed.
  void _copyFile(String src, String dst) {
    final srcFile = File(src);
    if (srcFile.existsSync()) {
      File(dst).parent.createSync(recursive: true);
      srcFile.copySync(dst);
    }
  }

  // Use a fixed unique ID for the build phase
  static const _copyGoogleServicePhaseId =
      'C0DE4B1E2F22000000000001';

  /// Injects a "Copy GoogleService-Info.plist" Run Script build phase
  /// into the Xcode project. The script copies the correct plist per
  /// flavor (development/staging/production) from `firebase/<flavor>/`.
  /// If no plist is found, it prints a warning and continues (does NOT
  /// fail the build), so the project works before Firebase is set up.
  void _injectGoogleServiceCopyScript(String projectPath) {
    final pbxprojFile = File(
      '$projectPath/ios/Runner.xcodeproj/project.pbxproj',
    );
    if (!pbxprojFile.existsSync()) return;

    var content = pbxprojFile.readAsStringSync();

    // 1. Add the build phase definition before
    //    /* End PBXShellScriptBuildPhase section */
    const id = _copyGoogleServicePhaseId;
    // Shell script with $PLIST var — use raw segments to avoid
    // Dart treating shell variables as interpolation.
    final phaseDefinition = '\t\t$id'
        r' /* Copy GoogleService-Info.plist */ = {'
        '\n\t\t\tisa = PBXShellScriptBuildPhase;'
        '\n\t\t\tbuildActionMask = 2147483647;'
        '\n\t\t\tfiles = ('
        '\n\t\t\t);'
        '\n\t\t\tinputFileListPaths = ('
        '\n\t\t\t);'
        '\n\t\t\tinputPaths = ('
        '\n\t\t\t);'
        '\n\t\t\tname = "Copy GoogleService-Info.plist";'
        '\n\t\t\toutputFileListPaths = ('
        '\n\t\t\t);'
        '\n\t\t\toutputPaths = ('
        '\n\t\t\t);'
        '\n\t\t\trunOnlyForDeploymentPostprocessing = 0;'
        '\n\t\t\tshellPath = /bin/sh;'
        '\n\t\t\tshellScript = '
        r'''"#!/bin/sh\n'''
        r'''PROJECT_DIR=\"${SRCROOT}/..\"\n'''
        r'''FIREBASE_CONFIG_DIR=\"${PROJECT_DIR}/firebase\"\n'''
        r'''\n'''
        r'''case \"${CONFIGURATION}\" in\n'''
        r'''    \"Debug-development\"|\"Release-development\"|\"Profile-development\")\n'''
        r'''        PLIST=\"${FIREBASE_CONFIG_DIR}/development/GoogleService-Info.plist\"\n'''
        r'''    ;;\n'''
        r'''    \"Debug-staging\"|\"Release-staging\"|\"Profile-staging\")\n'''
        r'''        PLIST=\"${FIREBASE_CONFIG_DIR}/staging/GoogleService-Info.plist\"\n'''
        r'''    ;;\n'''
        r'''    \"Debug-production\"|\"Release-production\"|\"Profile-production\")\n'''
        r'''        PLIST=\"${FIREBASE_CONFIG_DIR}/production/GoogleService-Info.plist\"\n'''
        r'''    ;;\n'''
        r'''    *)\n'''
        r'''        echo \"warning: Unknown configuration ${CONFIGURATION} — skipping GoogleService-Info.plist copy\"\n'''
        r'''        exit 0\n'''
        r'''    ;;\n'''
        r'''esac\n'''
        r'''\n'''
        r'''if [ -f \"$PLIST\" ]; then\n'''
        r'''    cp \"$PLIST\" \"${PROJECT_DIR}/ios/Runner/GoogleService-Info.plist\"\n'''
        r'''    echo \"${CONFIGURATION} GoogleService-Info.plist copied\"\n'''
        r'''else\n'''
        r'''    echo \"warning: GoogleService-Info.plist not found at $PLIST — skipping (add it when you set up Firebase)\"\n'''
        r'''fi\n";'''
        '\n\t\t};';

    content = content.replaceFirst(
      '/* End PBXShellScriptBuildPhase section */',
      '$phaseDefinition\n/* End PBXShellScriptBuildPhase section */',
    );

    // 2. Add the phase reference in Runner target's buildPhases,
    //    right after "Run Script" (9740EEB61CF901F6004384FC)
    content = content.replaceFirst(
      '9740EEB61CF901F6004384FC /* Run Script */,',
      '9740EEB61CF901F6004384FC /* Run Script */,\n'
          '\t\t\t\t$id '
          '/* Copy GoogleService-Info.plist */,',
    );

    pbxprojFile.writeAsStringSync(content);
  }
}
