import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:codeable_cli/src/template_engine.dart';
import 'package:codeable_cli/src/templates/feature_templates.dart';

class FeatureGenerator {
  const FeatureGenerator({required Logger logger}) : _logger = logger;

  final Logger _logger;

  /// Generates a feature module with clean architecture layers.
  Future<bool> generate({
    required String featureName,
    required String projectPath,
  }) async {
    final snakeName = TemplateEngine.toSnakeCase(featureName)
        .replaceAll(RegExp('[^a-z0-9_]'), '');
    final pascalName = TemplateEngine.toPascalCase(snakeName);
    final camelName = TemplateEngine.toCamelCase(snakeName);

    // Detect project name from pubspec
    final pubspecFile = File('$projectPath/pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      _logger.err('pubspec.yaml not found. Are you in a Flutter project?');
      return false;
    }
    final pubspecContent = pubspecFile.readAsStringSync();
    final nameMatch = RegExp(r'^name:\s*(.+)$', multiLine: true)
        .firstMatch(pubspecContent);
    if (nameMatch == null) {
      _logger.err('Could not parse project name from pubspec.yaml');
      return false;
    }
    final projectName = nameMatch.group(1)!.trim();

    final progress = _logger.progress('Creating feature: $snakeName');

    final vars = {
      'project_name': projectName,
      'feature_name': snakeName,
      'FeatureName': pascalName,
    };

    final featuresDir = '$projectPath/lib/features/$snakeName';

    // Create directory structure
    final dirs = [
      '$featuresDir/data/models',
      '$featuresDir/data/repository',
      '$featuresDir/domain/repository',
      '$featuresDir/presentation/cubit',
      '$featuresDir/presentation/views',
      '$featuresDir/presentation/widgets',
    ];

    for (final dir in dirs) {
      Directory(dir).createSync(recursive: true);
    }

    // Write template files
    final files = <String, String>{
      '$featuresDir/domain/repository/${snakeName}_repository.dart':
          TemplateEngine.render(featureRepositoryTemplate, vars),
      '$featuresDir/data/repository/${snakeName}_repository_impl.dart':
          TemplateEngine.render(featureRepositoryImplTemplate, vars),
      '$featuresDir/data/models/${snakeName}_model.dart':
          TemplateEngine.render(featureModelTemplate, vars),
      '$featuresDir/presentation/cubit/cubit.dart':
          TemplateEngine.render(featureCubitTemplate, vars),
      '$featuresDir/presentation/cubit/state.dart':
          TemplateEngine.render(featureStateTemplate, vars),
      '$featuresDir/presentation/views/${snakeName}_screen.dart':
          TemplateEngine.render(featureScreenTemplate, vars),
    };

    for (final entry in files.entries) {
      File(entry.key).writeAsStringSync(entry.value);
    }

    progress.complete('Feature $snakeName created');

    // Auto-register cubit in app_page.dart
    _registerCubitInAppPage(
      projectPath: projectPath,
      projectName: projectName,
      snakeName: snakeName,
      pascalName: pascalName,
    );

    // Auto-add route to go_router
    _addRouteToRouter(
      projectPath: projectPath,
      projectName: projectName,
      snakeName: snakeName,
      pascalName: pascalName,
      camelName: camelName,
    );

    _logger.info('');
    _logger.success('Feature $snakeName fully wired up:');
    _logger.info('  - Cubit registered in app_page.dart');
    _logger.info('  - Route added to go_router');
    _logger.info(
      '  - Navigate with: context.goNamed(AppRouteNames.${camelName}Screen)',
    );

    return true;
  }

  /// Registers the cubit in app_page.dart's MultiBlocProvider.
  void _registerCubitInAppPage({
    required String projectPath,
    required String projectName,
    required String snakeName,
    required String pascalName,
  }) {
    final appPageFile = File('$projectPath/lib/app/view/app_page.dart');
    if (!appPageFile.existsSync()) {
      _logger.warn('app_page.dart not found — skipping cubit registration.');
      return;
    }

    var content = appPageFile.readAsStringSync();

    // Add imports before the class declaration
    final repoImport =
        "import 'package:$projectName/features/$snakeName/data/repository/"
        "${snakeName}_repository_impl.dart';";
    final cubitImport =
        "import 'package:$projectName/features/$snakeName/presentation/"
        "cubit/cubit.dart';";

    // Find the last import line and add after it
    final importPattern = RegExp(r"^import\s+'[^']+';$", multiLine: true);
    final importMatches = importPattern.allMatches(content).toList();
    if (importMatches.isNotEmpty) {
      final lastImportEnd = importMatches.last.end;
      content = '${content.substring(0, lastImportEnd)}\n'
          '$repoImport\n'
          '$cubitImport'
          '${content.substring(lastImportEnd)}';
    }

    // Add BlocProvider before the closing of providers list
    // Find the pattern: ], followed by child: const AppView()
    final providersEndPattern = RegExp(
      r'(\s*)\],\s*\n(\s*)child:\s*const\s+AppView\(\)',
    );
    final providersMatch = providersEndPattern.firstMatch(content);
    if (providersMatch != null) {
      final blocProvider = '          BlocProvider(\n'
          '            create: (context) => ${pascalName}Cubit(\n'
          '              repository: ${pascalName}RepositoryImpl(),\n'
          '            ),\n'
          '          ),\n';
      content = '${content.substring(0, providersMatch.start)}\n'
          '$blocProvider'
          '${content.substring(providersMatch.start)}';
    }

    appPageFile.writeAsStringSync(content);
  }

  /// Adds route to go_router (exports.dart, router.dart, routes.dart).
  void _addRouteToRouter({
    required String projectPath,
    required String projectName,
    required String snakeName,
    required String pascalName,
    required String camelName,
  }) {
    final routerDir = '$projectPath/lib/go_router';

    // 1. Add import to exports.dart
    final exportsFile = File('$routerDir/exports.dart');
    if (exportsFile.existsSync()) {
      var content = exportsFile.readAsStringSync();
      final screenImport =
          "import 'package:$projectName/features/$snakeName/presentation/"
          "views/${snakeName}_screen.dart';";

      // Insert before "part 'router.dart';"
      if (!content.contains(screenImport)) {
        content = content.replaceFirst(
          "part 'router.dart';",
          "$screenImport\n\npart 'router.dart';",
        );
        exportsFile.writeAsStringSync(content);
      }
    } else {
      _logger.warn(
        'go_router/exports.dart not found — skipping route import.',
      );
    }

    // 2. Add GoRoute to router.dart
    final routerFile = File('$routerDir/router.dart');
    if (routerFile.existsSync()) {
      var content = routerFile.readAsStringSync();

      final newRoute = 'GoRoute(\n'
          "        name: AppRouteNames.${camelName}Screen,\n"
          "        path: AppRoutes.${camelName}Screen,\n"
          '        builder: (context, state) => '
          'const ${pascalName}Screen(),\n'
          '      ),';

      // Insert before "// TODO: Add more routes here" or before the closing ],
      if (content.contains('// TODO: Add more routes here')) {
        content = content.replaceFirst(
          '      // TODO: Add more routes here',
          '      $newRoute\n      // TODO: Add more routes here',
        );
      } else {
        // Find the last GoRoute closing and add after it
        final lastRouteClose = content.lastIndexOf(
          RegExp(r'\),\s*\n\s*\],'),
        );
        if (lastRouteClose != -1) {
          // Find the end of "),"
          final endOfLastRoute = content.indexOf('),', lastRouteClose);
          if (endOfLastRoute != -1) {
            final insertPos = endOfLastRoute + 2;
            content = '${content.substring(0, insertPos)}\n'
                '      $newRoute'
                '${content.substring(insertPos)}';
          }
        }
      }
      routerFile.writeAsStringSync(content);
    } else {
      _logger.warn('go_router/router.dart not found — skipping route add.');
    }

    // 3. Add route constants to routes.dart
    final routesFile = File('$routerDir/routes.dart');
    if (routesFile.existsSync()) {
      var content = routesFile.readAsStringSync();

      // Add to AppRoutes class
      final appRoutesPattern = RegExp(
        r'(class AppRoutes \{[^}]*)(})',
      );
      final routesMatch = appRoutesPattern.firstMatch(content);
      if (routesMatch != null) {
        final routeEntry = "  static const ${camelName}Screen = "
            "'/$snakeName';\n";
        final routesBody = routesMatch.group(1)!;
        if (!routesBody.contains('${camelName}Screen')) {
          content = content.replaceFirst(
            routesMatch.group(0)!,
            '$routesBody$routeEntry${routesMatch.group(2)!}',
          );
        }
      }

      // Add to AppRouteNames class
      final appRouteNamesPattern = RegExp(
        r'(class AppRouteNames \{[^}]*)(})',
      );
      final namesMatch = appRouteNamesPattern.firstMatch(content);
      if (namesMatch != null) {
        final nameEntry = "  static const ${camelName}Screen = "
            "'$camelName';\n";
        final namesBody = namesMatch.group(1)!;
        if (!namesBody.contains('${camelName}Screen')) {
          content = content.replaceFirst(
            namesMatch.group(0)!,
            '$namesBody$nameEntry${namesMatch.group(2)!}',
          );
        }
      }

      routesFile.writeAsStringSync(content);
    } else {
      _logger.warn(
        'go_router/routes.dart not found — skipping route constants.',
      );
    }
  }
}
