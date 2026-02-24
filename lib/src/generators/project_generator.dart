import 'dart:io';
import 'dart:isolate';

import 'package:mason_logger/mason_logger.dart';
import 'package:codeable_cli/src/generators/feature_generator.dart';
import 'package:codeable_cli/src/generators/keystore_generator.dart';
import 'package:codeable_cli/src/template_engine.dart';
import 'package:codeable_cli/src/templates/analysis_options_template.dart';
import 'package:codeable_cli/src/templates/android_templates.dart';
import 'package:codeable_cli/src/templates/app_templates.dart';
import 'package:codeable_cli/src/templates/config_templates.dart';
import 'package:codeable_cli/src/templates/constants_templates.dart';
import 'package:codeable_cli/src/templates/core_templates.dart';
import 'package:codeable_cli/src/templates/core_widgets_templates.dart';
import 'package:codeable_cli/src/templates/feature_templates.dart';
import 'package:codeable_cli/src/templates/ios_templates.dart';
import 'package:codeable_cli/src/templates/l10n_templates.dart';
import 'package:codeable_cli/src/templates/navigation_templates.dart';
import 'package:codeable_cli/src/templates/pubspec_template.dart';
import 'package:codeable_cli/src/templates/ai_config_templates.dart';
import 'package:codeable_cli/src/templates/readme_template.dart';
import 'package:codeable_cli/src/templates/router_templates.dart';
import 'package:codeable_cli/src/templates/run_config_templates.dart';
import 'package:codeable_cli/src/templates/utils_templates.dart';

class ProjectGenerator {
  ProjectGenerator({required Logger logger}) : _logger = logger;

  final Logger _logger;

  Future<bool> generate({
    required String projectName,
    required String orgName,
    required String description,
    required String outputPath,
    String appName = '',
    List<String> roles = const [],
  }) async {
    final snakeName = TemplateEngine.toSnakeCase(
      projectName,
    ).replaceAll(RegExp('[^a-z0-9_]'), '').replaceAll(RegExp('^[0-9]'), '');

    final vars = TemplateEngine.buildVars(
      projectName: snakeName,
      orgName: orgName,
      appName: appName,
      description: description,
    );

    // Sanitize roles upfront
    final sanitizedRoles = roles
        .map(
          (r) => TemplateEngine.toSnakeCase(r)
              .replaceAll(RegExp('[^a-z0-9_]'), ''),
        )
        .where((r) => r.isNotEmpty)
        .toList();
    final hasRoles = sanitizedRoles.isNotEmpty;

    // Onboarding vars only needed when no roles (standalone onboarding)
    final onboardingVars = {
      ...vars,
      'feature_name': 'onboarding',
      'feature_path': 'onboarding',
      'FeatureName': 'Onboarding',
    };

    final projectPath = '$outputPath/$snakeName';

    // Extract org prefix (everything except last segment) for flutter create
    final orgParts = orgName.split('.');
    final orgPrefix = orgParts.length > 1
        ? orgParts.sublist(0, orgParts.length - 1).join('.')
        : orgName;

    // Step 1: Run flutter create
    final flutterCreateProgress = _logger.progress('Running flutter create');
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

    // Remove default main.dart run configuration
    final defaultRunConfig =
        File('$projectPath/.idea/runConfigurations/main_dart.xml');
    if (defaultRunConfig.existsSync()) {
      defaultRunConfig.deleteSync();
    }
    cleanProgress.complete('Default files cleaned');

    // Step 3: Create directory structure
    final structureProgress = _logger.progress('Creating project structure');
    final directories = [
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
      'lib/core/locale/cubit',
      'lib/core/models/api_response',
      'lib/core/models/auth',
      'lib/core/notifications',
      'lib/core/permissions',
      // Navigation
      'lib/features/navigation/presentation/views',
      'lib/core/models',
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
      'assets/animation',
      'assets/fonts',
    ];

    // Standalone onboarding dirs only when no roles
    if (!hasRoles) {
      directories.addAll([
        'lib/features/onboarding/data/models',
        'lib/features/onboarding/data/repository',
        'lib/features/onboarding/domain/repository',
        'lib/features/onboarding/presentation/cubit',
        'lib/features/onboarding/presentation/views',
        'lib/features/onboarding/presentation/widgets',
      ]);
    }

    for (final dir in directories) {
      Directory('$projectPath/$dir').createSync(recursive: true);
    }

    // Create role + common directories when roles specified
    if (hasRoles) {
      for (final role in sanitizedRoles) {
        Directory('$projectPath/lib/features/$role')
            .createSync(recursive: true);
      }
      Directory('$projectPath/lib/features/common')
          .createSync(recursive: true);
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

      // App — use base template (no onboarding) when roles exist
      'lib/app/view/app_page.dart': render(
        hasRoles ? appPageBaseTemplate : appPageTemplate,
        vars,
      ),
      'lib/app/view/app_view.dart': render(appViewTemplate, vars),
      'lib/app/view/splash.dart': hasRoles
          ? render(splashBaseTemplate, {
              ...vars,
              'onboarding_route_name':
                  '${TemplateEngine.toCamelCase(sanitizedRoles.first)}'
                  'OnboardingScreen',
            })
          : render(splashTemplate, vars),

      // Config
      'lib/config/flavor_config.dart': render(flavorConfigTemplate, vars),
      'lib/config/api_environment.dart': render(apiEnvironmentTemplate, vars),
      'lib/config/remote_config.dart': render(remoteConfigTemplate, vars),

      // Constants
      'lib/constants/app_colors.dart': render(appColorsTemplate, vars),
      'lib/constants/app_text_style.dart': render(appTextStyleTemplate, vars),
      'lib/constants/asset_paths.dart': render(assetPathsTemplate, vars),
      'lib/constants/constants.dart': render(constantsTemplate, vars),
      'lib/constants/export.dart': render(constantsExportTemplate, vars),

      // Core - API Service
      'lib/core/api_service/api_service.dart': render(apiServiceTemplate, vars),
      'lib/core/api_service/app_api_exception.dart': render(
        appApiExceptionTemplate,
        vars,
      ),
      'lib/core/api_service/authentication_interceptor.dart': render(
        authInterceptorTemplate,
        vars,
      ),
      'lib/core/api_service/log_interceptor.dart': render(
        logInterceptorTemplate,
        vars,
      ),

      // Core - Preferences
      'lib/core/app_preferences/base_storage.dart': render(
        baseStorageTemplate,
        vars,
      ),
      'lib/core/app_preferences/app_preferences.dart': render(
        appPreferencesTemplate,
        vars,
      ),

      // Core - DI
      'lib/core/di/injector.dart': render(injectorTemplate, vars),
      'lib/core/di/modules/app_modules.dart': render(appModulesTemplate, vars),

      // Core - Endpoints
      'lib/core/endpoints/endpoints.dart': render(endpointsTemplate, vars),

      // Core - Validators
      'lib/core/field_validators.dart': render(fieldValidatorsTemplate, vars),

      // Core - Locale
      'lib/core/locale/cubit/locale_cubit.dart': render(
        localeCubitTemplate,
        vars,
      ),
      'lib/core/locale/cubit/locale_state.dart': render(
        localeStateTemplate,
        vars,
      ),

      // Core - Models - API Response
      'lib/core/models/api_response/api_response_model.dart': render(
        apiResponseModelTemplate,
        vars,
      ),
      'lib/core/models/api_response/api_error.dart': render(
        apiErrorTemplate,
        vars,
      ),
      'lib/core/models/api_response/base_api_response.dart': render(
        baseApiResponseTemplate,
        vars,
      ),
      'lib/core/models/api_response/api_response_handler.dart': render(
        apiResponseHandlerTemplate,
        vars,
      ),
      'lib/core/models/api_response/response_model.dart': render(
        responseModelTemplate,
        vars,
      ),

      // Core - Permissions
      'lib/core/permissions/permission_manager.dart': render(
        permissionManagerTemplate,
        vars,
      ),
      'lib/core/permissions/permission_messages.dart': render(
        permissionMessagesTemplate,
        vars,
      ),

      // Core - Notifications
      'lib/core/notifications/firebase_notifications.dart': render(
        firebaseNotificationsTemplate,
        vars,
      ),
      'lib/core/notifications/local_notification_service.dart': render(
        localNotificationServiceTemplate,
        vars,
      ),

      // Utils - Extensions
      'lib/utils/extensions/null_check.dart': render(
        nullCheckExtensionTemplate,
        vars,
      ),

      // Navigation — NavItem model + shell navigation widget (commented out)
      'lib/core/models/navigation_item.dart': navItemModelTemplate,
      'lib/features/navigation/presentation/views/app_navigation.dart':
          render(navigationWidgetTemplate, vars),

      // Go Router — use base templates (no onboarding) when roles exist
      'lib/go_router/exports.dart': render(
        hasRoles ? routerExportsBaseTemplate : routerExportsTemplate,
        vars,
      ),
      'lib/go_router/router.dart': render(
        hasRoles ? routerBaseTemplate : routerTemplate,
        vars,
      ),
      'lib/go_router/routes.dart': render(
        hasRoles ? routesBaseTemplate : routesTemplate,
        vars,
      ),

      // L10n
      'lib/l10n/l10n.dart': render(l10nDartTemplate, vars),
      'lib/l10n/arb/app_en.arb': render(appEnArbTemplate, vars),
      'lib/l10n/arb/app_es.arb': render(appEsArbTemplate, vars),

      // Utils - Helpers
      'lib/utils/helpers/data_state.dart': render(dataStateTemplate, vars),
      'lib/utils/helpers/api_call_state.dart': render(
        apiCallStateTemplate,
        vars,
      ),
      'lib/utils/helpers/repository_response.dart': render(
        repositoryResponseTemplate,
        vars,
      ),
      'lib/utils/helpers/logger_helper.dart': render(
        loggerHelperTemplate,
        vars,
      ),
      'lib/utils/helpers/toast_helper.dart': render(toastHelperTemplate, vars),
      'lib/utils/helpers/typedef.dart': render(typedefTemplate, vars),
      'lib/utils/helpers/focus_handler.dart': render(
        focusHandlerTemplate,
        vars,
      ),
      'lib/utils/helpers/string_helper.dart': render(
        stringHelperTemplate,
        vars,
      ),
      'lib/utils/helpers/color_helper.dart': render(colorHelperTemplate, vars),
      'lib/utils/helpers/decorations_helper.dart': render(
        decorationsHelperTemplate,
        vars,
      ),
      'lib/utils/helpers/layout_helper.dart': render(
        layoutHelperTemplate,
        vars,
      ),

      // Utils - Response model
      'lib/utils/response_data_model/response_data_model.dart': render(
        responseDataModelTemplate,
        vars,
      ),
      'lib/utils/response_data_model/api_response_parser.dart': render(
        apiResponseParserTemplate,
        vars,
      ),

      // Utils - Core Widgets
      'lib/utils/widgets/core_widgets/export.dart': render(
        exportTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/app_bar.dart': render(
        appBarTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/bottom_sheet.dart': render(
        bottomSheetTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/bullet_point_item.dart': render(
        bulletPointItemTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/button.dart': render(
        buttonTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/cached_network_image.dart': render(
        cachedNetworkImageTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/checkbox.dart': render(
        checkboxTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/chips.dart': render(chipsTemplate, vars),
      'lib/utils/widgets/core_widgets/confirmation_dialog.dart': render(
        confirmationDialogTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/custom_date_picker.dart': render(
        customDatePickerTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/custom_dropdown.dart': render(
        customDropdownTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/custom_dropdown_cubit.dart': render(
        customDropdownCubitTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/custom_sliding_tab.dart': render(
        customSlidingTabTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/date_picker.dart': render(
        datePickerTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/empty_state_widget.dart': render(
        emptyStateWidgetTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/icon_button.dart': render(
        iconButtonTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/image_picker.dart': render(
        imagePickerTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/loading_widget.dart': render(
        loadingWidgetTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/outline_button.dart': render(
        outlineButtonTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/paginated_list_view.dart': render(
        paginatedListViewTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/progress_dashes.dart': render(
        progressDashesTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/retry_widget.dart': render(
        retryWidgetTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/reusable_calendar_widget.dart': render(
        reusableCalendarWidgetTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/rich_text.dart': render(
        richTextTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/search_field.dart': render(
        searchFieldTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/searchable_dropdown.dart': render(
        searchableDropdownTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/section_title.dart': render(
        sectionTitleTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/shimmer_loading_widget.dart': render(
        shimmerCustomLoadingWidgetTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/slider.dart': render(
        sliderTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/sliding_tab.dart': render(
        slidingTabTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/social_auth_button.dart': render(
        socialAuthButtonTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/stacked_images_widget.dart': render(
        stackedImagesWidgetTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/star_rating_widget.dart': render(
        starRatingWidgetTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/switch.dart': render(
        switchTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/text_button.dart': render(
        textButtonTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/text_field.dart': render(
        textFieldTemplate,
        vars,
      ),
      'lib/utils/widgets/core_widgets/tile.dart': render(tileTemplate, vars),
      'lib/utils/widgets/core_widgets/time_picker.dart': render(
        timePickerTemplate,
        vars,
      ),
      // Extra widgets (referenced by core_widgets export)
      'lib/utils/widgets/blur_overlay.dart': render(blurOverlayTemplate, vars),
      'lib/utils/widgets/filter_icon_widget.dart': render(
        filterIconWidgetTemplate,
        vars,
      ),

      // Extra helpers (referenced by core widgets)
      'lib/utils/helpers/datetime_helper.dart': render(
        datetimeHelperTemplate,
        vars,
      ),

      // Standalone onboarding feature (only when no roles)
      if (!hasRoles) ...{
        'lib/features/onboarding/domain/repository/'
            'onboarding_repository.dart':
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
      },

      // Placeholder assets (images, vectors, fonts get real files via
      // _copyBundledAssets; only animation needs a placeholder)
      'assets/animation/.gitkeep': '',

      // README
      'README.md': render(readmeTemplate, vars),

      // AI Assistant Config
      'CLAUDE.md': render(claudeMdTemplate, vars),
      '.cursorrules': render(cursorRulesTemplate, vars),

      // Android Studio run configurations
      '.idea/runConfigurations/development.xml':
          runConfigDevelopmentTemplate,
      '.idea/runConfigurations/staging.xml': runConfigStagingTemplate,
      '.idea/runConfigurations/production.xml':
          runConfigProductionTemplate,
    };

    for (final entry in files.entries) {
      final file = File('$projectPath/${entry.key}');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(entry.value);
    }
    filesProgress.complete('Template files written');

    // Generate onboarding per role (uses FeatureGenerator for auto-wiring)
    if (hasRoles) {
      final featureGen = FeatureGenerator(logger: _logger);
      for (final role in sanitizedRoles) {
        await featureGen.generate(
          featureName: 'onboarding',
          projectPath: projectPath,
          role: role,
        );
      }
    }

    // Step 5: Replace pubspec.yaml
    final pubspecProgress = _logger.progress('Configuring pubspec.yaml');
    File(
      '$projectPath/pubspec.yaml',
    ).writeAsStringSync(render(pubspecTemplate, vars));
    pubspecProgress.complete('pubspec.yaml configured');

    // Step 6: Write analysis_options.yaml
    File(
      '$projectPath/analysis_options.yaml',
    ).writeAsStringSync(analysisOptionsTemplate);

    // Step 7: Write l10n.yaml
    File('$projectPath/l10n.yaml').writeAsStringSync(l10nYamlTemplate);

    // Step 8: Update Android build config
    final androidProgress = _logger.progress('Configuring Android');
    final buildGradlePath = '$projectPath/android/app/build.gradle.kts';
    if (File(buildGradlePath).existsSync()) {
      File(
        buildGradlePath,
      ).writeAsStringSync(render(androidBuildGradleTemplate, vars));
    }

    // Write proguard rules
    File(
      '$projectPath/android/app/proguard-rules.pro',
    ).writeAsStringSync(proguardRulesTemplate);

    // Update gradle.properties
    File(
      '$projectPath/android/gradle.properties',
    ).writeAsStringSync(gradlePropertiesTemplate);

    // Replace root build.gradle.kts (suppresses Java 8 warnings globally)
    File(
      '$projectPath/android/build.gradle.kts',
    ).writeAsStringSync(androidRootBuildGradleTemplate);

    // Write AndroidManifest
    final manifestPath =
        '$projectPath/android/app/src/main/AndroidManifest.xml';
    File(manifestPath).writeAsStringSync(androidManifestTemplate);

    // Move MainActivity.kt to match the org-based namespace.
    // flutter create uses the project name (e.g., com/example/test_app/)
    // but our namespace is the org name (e.g., com/example/testapp/).
    _relocateMainActivity(projectPath, orgName);

    androidProgress.complete('Android configured');

    // Step 9: Configure iOS
    final iosProgress = _logger.progress('Configuring iOS');

    // Write Podfile with permission handlers
    File('$projectPath/ios/Podfile').writeAsStringSync(iosPodfileTemplate);

    // Write Info.plist with permissions
    final infoPlistPath = '$projectPath/ios/Runner/Info.plist';
    File(infoPlistPath).writeAsStringSync(render(iosInfoPlistTemplate, vars));

    // Write entitlements for push notifications & Sign in with Apple
    File(
      '$projectPath/ios/Runner/Runner.entitlements',
    ).writeAsStringSync(iosEntitlementsTemplate);
    File(
      '$projectPath/ios/Runner/RunnerRelease.entitlements',
    ).writeAsStringSync(iosReleaseEntitlementsTemplate);

    iosProgress.complete('iOS configured');

    // Step 10: Create firebase config directory structure
    for (final flavor in ['development', 'staging', 'production']) {
      Directory('$projectPath/firebase/$flavor').createSync(recursive: true);
    }

    // Step 11: Copy bundled assets (splash, app icons, SVGs)
    await _copyBundledAssets(projectPath);

    // Step 11b: Create per-flavor app icon sets (iOS + Android)
    await _createFlavorAppIcons(projectPath);

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

    // Step 14: Configure iOS Xcode project for flavors
    // (must run AFTER flutter pub get, because pod install rewrites pbxproj)
    final flavorProgress = _logger.progress('Configuring flavor builds');
    _configureFlavorBuildConfigurations(projectPath, vars);
    _createFlavorSchemes(projectPath);
    _injectGoogleServiceCopyScript(projectPath);
    flavorProgress.complete('Flavor builds configured');

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
    final packageUri = Uri.parse('package:codeable_cli/src/assets/marker');
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

      // 2. SVG logos → assets/vectors/
      final svgDir = Directory('$assetsRoot/svgs');
      if (svgDir.existsSync()) {
        for (final file in svgDir.listSync().whereType<File>()) {
          final name = file.uri.pathSegments.last;
          _copyFile(file.path, '$projectPath/assets/vectors/$name');
        }
      }

      // 3. Android app icons → android/app/src/main/res/
      final androidResBase = '$projectPath/android/app/src/main/res';
      // Clear default Flutter mipmap icons before copying ours
      final resDir = Directory(androidResBase);
      if (resDir.existsSync()) {
        for (final entity in resDir.listSync()) {
          if (entity is Directory && entity.path.contains('mipmap')) {
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

      // 5. Fonts → assets/fonts/ (preserves subdirectory structure)
      final fontsSrcDir = Directory('$assetsRoot/fonts');
      if (fontsSrcDir.existsSync()) {
        _copyDirectory(fontsSrcDir.path, '$projectPath/assets/fonts');
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

  /// Moves MainActivity.kt so its package matches the org-based namespace.
  ///
  /// `flutter create` generates `com/example/test_app/MainActivity.kt`
  /// but our build.gradle.kts sets `namespace = "com.example.testapp"`.
  /// Android resolves `.MainActivity` against the namespace, so the Kotlin
  /// file must live under the matching directory.
  void _relocateMainActivity(String projectPath, String orgName) {
    final kotlinBase = '$projectPath/android/app/src/main/kotlin';
    final orgPath = orgName.replaceAll('.', '/');
    final targetDir = '$kotlinBase/$orgPath';
    final targetFile = '$targetDir/MainActivity.kt';

    // If already correct, nothing to do
    if (File(targetFile).existsSync()) return;

    // Find the existing MainActivity.kt
    final kotlinDir = Directory(kotlinBase);
    if (!kotlinDir.existsSync()) return;

    File? found;
    for (final f in kotlinDir.listSync(recursive: true).whereType<File>()) {
      if (f.path.endsWith('MainActivity.kt')) {
        found = f;
        break;
      }
    }
    if (found == null) return;

    // Read, update package declaration, write to new location
    var content = found.readAsStringSync();
    final packageRe = RegExp(r'package\s+\S+');
    content = content.replaceFirst(packageRe, 'package $orgName');

    Directory(targetDir).createSync(recursive: true);
    File(targetFile).writeAsStringSync(content);

    // Remove old file and clean up empty parent dirs
    final oldDir = found.parent;
    found.deleteSync();
    _deleteEmptyParents(oldDir, kotlinDir);
  }

  /// Deletes empty directories upward until [stopAt].
  void _deleteEmptyParents(Directory dir, Directory stopAt) {
    var current = dir;
    while (current.path != stopAt.path && current.listSync().isEmpty) {
      final parent = current.parent;
      current.deleteSync();
      current = parent;
    }
  }

  // ---------------------------------------------------------------------------
  // Flavor build-configuration helpers
  // ---------------------------------------------------------------------------

  static const _flavors = [
    {'name': 'production', 'suffix': '', 'label': '', 'icon': 'AppIcon'},
    {'name': 'staging', 'suffix': '.stg', 'label': ' [STG]', 'icon': 'AppIcon-stg'},
    {'name': 'development', 'suffix': '.dev', 'label': ' [DEV]', 'icon': 'AppIcon-dev'},
  ];

  static const _buildTypes = ['Debug', 'Release', 'Profile'];

  /// Deterministic 24-char UUID for a flavor build configuration.
  /// bt: 1=Debug 2=Release 3=Profile, fl: 1=production 2=staging 3=development,
  /// tg: 1=project 2=runner 3=tests
  static String _flavorUuid(int bt, int fl, int tg) =>
      'C0DE4B1E${bt.toString().padLeft(2, "0")}'
      '${fl.toString().padLeft(2, "0")}'
      '${tg.toString().padLeft(2, "0")}0000000000';

  /// Transforms the default 3×3 build configurations in the flutter-generated
  /// project.pbxproj into 9×3 flavor build configurations
  /// (Debug/Release/Profile × production/staging/development × 3 targets).
  void _configureFlavorBuildConfigurations(
    String projectPath,
    Map<String, String> vars,
  ) {
    final pbxprojFile = File(
      '$projectPath/ios/Runner.xcodeproj/project.pbxproj',
    );
    if (!pbxprojFile.existsSync()) return;

    var content = pbxprojFile.readAsStringSync();

    final orgName = vars['org_name']!;
    final projectName = vars['app_name']!;

    // --- Step 1: Parse XCConfigurationList to map config UUIDs → target ---
    // target indices: 1=project, 2=runner, 3=tests
    final configToTarget = <String, int>{};

    // First extract the XCConfigurationList section to avoid matching
    // the buildConfigurationList *references* in the target sections.
    final configListSectionRe = RegExp(
      r'/\* Begin XCConfigurationList section \*/\n([\s\S]*?)'
      r'/\* End XCConfigurationList section \*/',
    );
    final configListSection = configListSectionRe.firstMatch(content);
    if (configListSection == null) return;
    final clContent = configListSection.group(1)!;

    // Within the section, match each list definition and its configs
    final listDefRe = RegExp(
      r'Build configuration list for (\w+) "(\w+)".*?'
      r'buildConfigurations = \((.*?)\);',
      dotAll: true,
    );
    final uuidInListRe = RegExp(r'([0-9A-F]{24})');

    for (final m in listDefRe.allMatches(clContent)) {
      final kind = m.group(1)!; // PBXProject or PBXNativeTarget
      final name = m.group(2)!; // Runner or RunnerTests
      final targetIdx = kind == 'PBXProject'
          ? 1
          : name == 'Runner'
              ? 2
              : 3;
      for (final u in uuidInListRe.allMatches(m.group(3)!)) {
        configToTarget[u.group(1)!] = targetIdx;
      }
    }

    // --- Step 2: Parse XCBuildConfiguration blocks ---
    final configSectionRe = RegExp(
      r'/\* Begin XCBuildConfiguration section \*/\n([\s\S]*?)/\* End XCBuildConfiguration section \*/',
    );
    final sectionMatch = configSectionRe.firstMatch(content);
    if (sectionMatch == null) return;

    final blockRe = RegExp(
      r'\t\t([0-9A-F]{24}) /\* (\w+) \*/ = \{([\s\S]*?)\n\t\t\};',
    );

    // Collect original blocks keyed by (buildType, targetIndex)
    final origBlocks = <String, String>{}; // key: "$buildType:$targetIdx"
    for (final m in blockRe.allMatches(sectionMatch.group(1)!)) {
      final uuid = m.group(1)!;
      final buildType = m.group(2)!; // Debug, Release, or Profile
      final body = m.group(3)!;
      final targetIdx = configToTarget[uuid] ?? 0;
      if (targetIdx == 0) continue;

      origBlocks['$buildType:$targetIdx'] =
          '\t\t$uuid /* $buildType */ = {$body\n\t\t};';
    }

    // --- Step 3: Generate 27 new configuration blocks ---
    final newBlocks = StringBuffer();

    for (var btIdx = 0; btIdx < _buildTypes.length; btIdx++) {
      final bt = _buildTypes[btIdx];
      for (var flIdx = 0; flIdx < _flavors.length; flIdx++) {
        final fl = _flavors[flIdx];
        final configName = '$bt-${fl['name']}';

        for (var tgIdx = 1; tgIdx <= 3; tgIdx++) {
          final uuid = _flavorUuid(btIdx + 1, flIdx + 1, tgIdx);
          final origKey = '$bt:$tgIdx';
          var block = origBlocks[origKey];
          if (block == null) continue;

          // Replace the UUID
          final origUuidRe = RegExp(r'[0-9A-F]{24}(?= /\*)');
          block = block.replaceFirst(origUuidRe, uuid);

          // Replace the name (handles both `name = Debug;` and `name = "Debug";`)
          block = block.replaceFirst(
            RegExp(r'name = "?' + bt + r'"?;'),
            'name = "$configName";',
          );

          // Replace the comment
          block = block.replaceFirst('/* $bt */', '/* $configName */');

          // --- Runner target: inject flavor-specific build settings ---
          if (tgIdx == 2) {
            final bundleId = fl['suffix']!.isEmpty
                ? orgName
                : '$orgName${fl['suffix']}';
            final appName = fl['label']!.isEmpty
                ? projectName
                : '$projectName${fl['label']}';
            final iconName = fl['icon']!;

            // Replace PRODUCT_BUNDLE_IDENTIFIER
            block = block.replaceFirst(
              RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+;'),
              'PRODUCT_BUNDLE_IDENTIFIER = $bundleId;',
            );

            // Replace ASSETCATALOG_COMPILER_APPICON_NAME
            block = block.replaceFirst(
              RegExp(r'ASSETCATALOG_COMPILER_APPICON_NAME = [^;]+;'),
              'ASSETCATALOG_COMPILER_APPICON_NAME = "$iconName";',
            );

            // Add FLAVOR_APP_NAME after ENABLE_BITCODE line
            block = block.replaceFirst(
              'ENABLE_BITCODE = NO;',
              'ENABLE_BITCODE = NO;\n\t\t\t\tFLAVOR_APP_NAME = "$appName";',
            );
          }

          newBlocks.writeln(block);
        }
      }
    }

    // --- Step 4: Replace the XCBuildConfiguration section ---
    content = content.replaceFirst(
      configSectionRe,
      '/* Begin XCBuildConfiguration section */\n'
          '$newBlocks'
          '/* End XCBuildConfiguration section */',
    );

    // --- Step 5: Update XCConfigurationList entries ---
    // Extract the section, modify it, then put it back to avoid matching
    // the buildConfigurationList *references* in target sections.
    final clSectionRe = RegExp(
      r'(/\* Begin XCConfigurationList section \*/\n)'
      r'([\s\S]*?)'
      r'(/\* End XCConfigurationList section \*/)',
    );
    content = content.replaceFirstMapped(clSectionRe, (sectionM) {
      var section = sectionM.group(2)!;

      for (var tgIdx = 1; tgIdx <= 3; tgIdx++) {
        final refs = StringBuffer();
        for (var btIdx = 0; btIdx < _buildTypes.length; btIdx++) {
          for (var flIdx = 0; flIdx < _flavors.length; flIdx++) {
            final uuid = _flavorUuid(btIdx + 1, flIdx + 1, tgIdx);
            final name =
                '${_buildTypes[btIdx]}-${_flavors[flIdx]['name']}';
            refs.writeln('\t\t\t\t$uuid /* $name */,');
          }
        }

        final targetLabel = tgIdx == 1
            ? 'PBXProject "Runner"'
            : tgIdx == 2
                ? 'PBXNativeTarget "Runner"'
                : 'PBXNativeTarget "RunnerTests"';

        final listRe = RegExp(
          '(Build configuration list for '
          '${RegExp.escape(targetLabel)}'
          r'.*?buildConfigurations = \()\n[\s\S]*?(\);)',
          dotAll: true,
        );
        section = section.replaceFirstMapped(listRe, (m) {
          return '${m.group(1)}\n$refs${m.group(2)}';
        });
      }

      // Change default config name
      section = section.replaceAll(
        'defaultConfigurationName = Release;',
        'defaultConfigurationName = "Release-production";',
      );

      return '${sectionM.group(1)}$section${sectionM.group(3)}';
    });

    // --- Step 6: Disable automatic signing for Runner target ---
    // Add ProvisioningStyle = Manual to Runner's TargetAttributes so Xcode
    // does not default to "Automatically manage signing".
    content = content.replaceFirstMapped(
      RegExp(
        r'(97C146ED1CF9000F007C117D = \{[^}]*?'
        r'CreatedOnToolsVersion = [^;]+;)',
      ),
      (m) => '${m.group(1)}\n'
          '\t\t\t\t\tProvisioningStyle = Manual;',
    );

    pbxprojFile.writeAsStringSync(content);
  }

  /// Creates Xcode scheme files for each flavor so `flutter run --flavor X`
  /// can find the matching build configuration.
  void _createFlavorSchemes(String projectPath) {
    final schemesDir = Directory(
      '$projectPath/ios/Runner.xcodeproj/xcshareddata/xcschemes',
    );
    schemesDir.createSync(recursive: true);

    // Remove the default Runner.xcscheme (references non-existent Debug/Release)
    final defaultScheme = File('${schemesDir.path}/Runner.xcscheme');
    if (defaultScheme.existsSync()) defaultScheme.deleteSync();

    for (final flavor in _flavors) {
      final rendered = TemplateEngine.render(
        iosFlavorSchemeTemplate,
        {'flavor': flavor['name']!},
      );
      File('${schemesDir.path}/${flavor['name']}.xcscheme')
          .writeAsStringSync(rendered);
    }
  }

  /// Creates per-flavor app icon sets for iOS and Android.
  /// Copies the same base icons to all flavors — users customise them later.
  Future<void> _createFlavorAppIcons(String projectPath) async {
    final assetsRoot = await _resolveAssetsPath();

    // --- iOS: create AppIcon-dev & AppIcon-stg icon sets ---
    final iosIconSrc = Directory('$assetsRoot/ios/AppIcon.appiconset');
    if (iosIconSrc.existsSync()) {
      for (final suffix in ['dev', 'stg']) {
        final dst =
            '$projectPath/ios/Runner/Assets.xcassets/AppIcon-$suffix.appiconset';
        Directory(dst).createSync(recursive: true);
        for (final file in iosIconSrc.listSync().whereType<File>()) {
          final name = file.uri.pathSegments.last;
          file.copySync('$dst/$name');
        }
      }
    }

    // --- Android: create development/ and staging/ source sets ---
    final androidSrcDir = Directory('$assetsRoot/android');
    if (androidSrcDir.existsSync()) {
      for (final flavor in ['development', 'staging']) {
        final dst = '$projectPath/android/app/src/$flavor/res';
        _copyDirectory(androidSrcDir.path, dst);
      }
    }
  }

  // Use a fixed unique ID for the build phase
  static const _copyGoogleServicePhaseId = 'C0DE4B1E2F22000000000001';

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
    final phaseDefinition =
        '\t\t$id'
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
