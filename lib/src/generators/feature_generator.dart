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
      '$featuresDir/presentation/widgets/.gitkeep': '',
    };

    for (final entry in files.entries) {
      File(entry.key).writeAsStringSync(entry.value);
    }

    progress.complete('Feature $snakeName created');

    _logger.info('');
    _logger.info('Next steps:');
    _logger.info(
      '  1. Register ${pascalName}Cubit in lib/app/view/app_page.dart',
    );
    _logger.info(
      '  2. Add route for ${pascalName}Screen in lib/go_router/',
    );

    return true;
  }
}
