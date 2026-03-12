import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:codeable_cli/src/template_engine.dart';
import 'package:mason_logger/mason_logger.dart';

/// Removes a feature module and unwires its cubit, routes, and imports.
class RemoveFeatureCommand extends Command<int> {
  RemoveFeatureCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'Feature name to remove (snake_case).',
      )
      ..addOption(
        'role',
        abbr: 'r',
        help: 'Role prefix for the feature (e.g., customer, admin, common).',
      );
  }

  final Logger _logger;

  @override
  String get description =>
      'Remove a feature and unwire its cubit, routes, and imports.';

  @override
  String get name => 'remove-feature';

  @override
  String get invocation =>
      'codeable_cli remove-feature --name <feature_name> [--role <role>]';

  @override
  Future<int> run() async {
    // Ensure we're inside a Flutter project
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      _logger.err(
        'No pubspec.yaml found. '
        'Run this command from the root of a Flutter project.',
      );
      return ExitCode.usage.code;
    }

    // Read project name from pubspec.yaml
    final pubspecContent = pubspecFile.readAsStringSync();
    final nameMatch = RegExp(r'^name:\s*(.+)$', multiLine: true)
        .firstMatch(pubspecContent);
    if (nameMatch == null) {
      _logger.err('Could not parse project name from pubspec.yaml.');
      return ExitCode.software.code;
    }
    final projectName = nameMatch.group(1)!.trim();

    // Get feature name
    var featureName = argResults?['name'] as String?;
    if (featureName == null || featureName.isEmpty) {
      featureName = _logger.prompt('What is the feature name to remove?');
    }

    final role = argResults?['role'] as String?;

    // Compute composite names (same logic as FeatureGenerator)
    final snakeName = TemplateEngine.toSnakeCase(featureName)
        .replaceAll(RegExp('[^a-z0-9_]'), '');
    final snakeRole = role != null
        ? TemplateEngine.toSnakeCase(role)
            .replaceAll(RegExp('[^a-z0-9_]'), '')
        : null;
    final isCommonRole = snakeRole == 'common';

    final compositeSnakeName = (snakeRole != null && !isCommonRole)
        ? '${snakeRole}_$snakeName'
        : snakeName;
    final compositePascalName =
        TemplateEngine.toPascalCase(compositeSnakeName);
    final compositeCamelName = TemplateEngine.toCamelCase(compositeSnakeName);

    final featurePath =
        snakeRole != null ? '$snakeRole/$snakeName' : snakeName;
    final routePath = (snakeRole != null && !isCommonRole)
        ? '/${TemplateEngine.toKebabCase(compositeSnakeName)}'
        : '/$snakeName';

    // Feature directory on disk
    final projectPath = Directory.current.path;
    final featureDirPath = snakeRole != null
        ? '$projectPath/lib/features/$snakeRole/$snakeName'
        : '$projectPath/lib/features/$snakeName';
    final featureDir = Directory(featureDirPath);

    // Verify feature exists
    if (!featureDir.existsSync()) {
      _logger.err(
        'Feature directory not found: $featureDirPath\n'
        'Nothing to remove.',
      );
      return ExitCode.usage.code;
    }

    // Ask for confirmation
    final confirmed = _logger.confirm(
      "Are you sure you want to remove feature '$compositeSnakeName'? "
      'This will delete all files and unwire routes/cubits.',
    );
    if (!confirmed) {
      _logger.info('Aborted.');
      return ExitCode.success.code;
    }

    _logger
      ..info('')
      ..info(
        'Removing feature ${lightCyan.wrap(compositeSnakeName)}...',
      )
      ..info('');

    // Step 1: Remove cubit from app_page.dart
    _removeCubitFromAppPage(
      projectPath: projectPath,
      projectName: projectName,
      featurePath: featurePath,
      compositeSnakeName: compositeSnakeName,
      pascalName: compositePascalName,
    );

    // Step 2: Remove route from go_router
    _removeRouteFromRouter(
      projectPath: projectPath,
      projectName: projectName,
      featurePath: featurePath,
      compositeSnakeName: compositeSnakeName,
      pascalName: compositePascalName,
      camelName: compositeCamelName,
      routePath: routePath,
    );

    // Step 3: Delete feature directory
    final deleteProgress = _logger.progress('Deleting feature directory');
    try {
      featureDir.deleteSync(recursive: true);
      deleteProgress.complete('Feature directory deleted');
    } on FileSystemException catch (e) {
      deleteProgress.fail('Failed to delete feature directory: $e');
      return ExitCode.software.code;
    }

    // Step 4: Run flutter pub get
    final pubGetProgress = _logger.progress('Running flutter pub get');
    final pubGetResult = await Process.run('flutter', ['pub', 'get']);
    if (pubGetResult.exitCode != 0) {
      pubGetProgress.fail('flutter pub get failed');
      _logger.err(pubGetResult.stderr.toString());
    } else {
      pubGetProgress.complete('Dependencies resolved');
    }

    _logger
      ..info('')
      ..success('Feature $compositeSnakeName fully removed:')
      ..info('  - Cubit unregistered from app_page.dart')
      ..info('  - Route removed from go_router')
      ..info('  - Feature directory deleted')
      ..info('');

    return ExitCode.success.code;
  }

  /// Removes the cubit registration and imports from app_page.dart.
  void _removeCubitFromAppPage({
    required String projectPath,
    required String projectName,
    required String featurePath,
    required String compositeSnakeName,
    required String pascalName,
  }) {
    final appPageFile = File('$projectPath/lib/app/view/app_page.dart');
    if (!appPageFile.existsSync()) {
      _logger.warn('app_page.dart not found — skipping cubit removal.');
      return;
    }

    final progress = _logger.progress('Removing cubit from app_page.dart');
    var content = appPageFile.readAsStringSync();

    // Remove import lines for this feature's cubit and repository impl
    final repoImport = "import 'package:$projectName/features/"
        '$featurePath/data/repository/'
        "${compositeSnakeName}_repository_impl.dart';";
    final cubitImport = "import 'package:$projectName/features/"
        "$featurePath/presentation/cubit/cubit.dart';";

    content = content.replaceAll('$repoImport\n', '');
    content = content.replaceAll('$cubitImport\n', '');
    // Handle case where import is at end of file without trailing newline
    content = content.replaceAll(repoImport, '');
    content = content.replaceAll(cubitImport, '');

    // Remove the BlocProvider block for this feature's cubit.
    // Match the full BlocProvider(...XCubit...) block with surrounding
    // whitespace and trailing comma.
    final blocProviderPattern = RegExp(
      r'\s*BlocProvider\(\s*\n'
      r'\s*create:\s*\(context\)\s*=>\s*'
      '${pascalName}Cubit'
      r'\([^)]*\)\s*,?\s*\n'
      r'\s*\),?',
    );
    content = content.replaceAll(blocProviderPattern, '');

    // Also handle single-line variant or different formatting
    final blocProviderPatternAlt = RegExp(
      r'\s*BlocProvider\(\s*'
      r'create:\s*\(context\)\s*=>\s*'
      '${pascalName}Cubit'
      r'\([\s\S]*?\),\s*\),?',
    );
    if (blocProviderPattern.firstMatch(content) == null) {
      content = content.replaceAll(blocProviderPatternAlt, '');
    }

    // Clean up double blank lines
    content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    appPageFile.writeAsStringSync(content);
    progress.complete('Cubit removed from app_page.dart');
  }

  /// Removes route entries from go_router files.
  void _removeRouteFromRouter({
    required String projectPath,
    required String projectName,
    required String featurePath,
    required String compositeSnakeName,
    required String pascalName,
    required String camelName,
    required String routePath,
  }) {
    final routerDir = '$projectPath/lib/go_router';

    // 1. Remove import from exports.dart
    final exportsFile = File('$routerDir/exports.dart');
    if (exportsFile.existsSync()) {
      final progress =
          _logger.progress('Removing screen import from exports.dart');
      var content = exportsFile.readAsStringSync();

      final screenImport = "import 'package:$projectName/features/"
          '$featurePath/presentation/views/'
          "${compositeSnakeName}_screen.dart';";

      content = content.replaceAll('$screenImport\n\n', '');
      content = content.replaceAll('$screenImport\n', '');
      content = content.replaceAll(screenImport, '');

      // Clean up double blank lines
      content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');

      exportsFile.writeAsStringSync(content);
      progress.complete('Screen import removed from exports.dart');
    } else {
      _logger.warn(
        'go_router/exports.dart not found — skipping import removal.',
      );
    }

    // 2. Remove GoRoute from router.dart
    final routerFile = File('$routerDir/router.dart');
    if (routerFile.existsSync()) {
      final progress = _logger.progress('Removing route from router.dart');
      var content = routerFile.readAsStringSync();

      // Remove the GoRoute block for this feature
      final goRoutePattern = RegExp(
        r'\s*GoRoute\(\s*\n'
        r'\s*name:\s*AppRouteNames\.'
        '${camelName}Screen'
        r',\s*\n'
        r'\s*path:\s*AppRoutes\.'
        '${camelName}Screen'
        r',\s*\n'
        r'\s*builder:\s*\(context,\s*state\)\s*=>\s*'
        r'const\s+'
        '${pascalName}Screen'
        r'\(\),?\s*\n'
        r'\s*\),?',
      );
      content = content.replaceAll(goRoutePattern, '');

      // Clean up double blank lines
      content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');

      routerFile.writeAsStringSync(content);
      progress.complete('Route removed from router.dart');
    } else {
      _logger.warn(
        'go_router/router.dart not found — skipping route removal.',
      );
    }

    // 3. Remove route constants from routes.dart
    final routesFile = File('$routerDir/routes.dart');
    if (routesFile.existsSync()) {
      final progress =
          _logger.progress('Removing route constants from routes.dart');
      var content = routesFile.readAsStringSync();

      // Remove from both AppRoutes and AppRouteNames classes
      final constPattern = RegExp(
        '  static const ${camelName}Screen'
        " = '[^']*';\n",
      );
      content = content.replaceAll(constPattern, '');

      // Clean up double blank lines
      content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');

      routesFile.writeAsStringSync(content);
      progress.complete('Route constants removed from routes.dart');
    } else {
      _logger.warn(
        'go_router/routes.dart not found — skipping route constant removal.',
      );
    }
  }
}
