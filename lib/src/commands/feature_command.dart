import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:codeable_cli/src/generators/feature_generator.dart';

class FeatureCommand extends Command<int> {
  FeatureCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addOption(
        'role',
        abbr: 'r',
        help: 'Role prefix for the feature (e.g., customer, admin). '
            'Places the feature under features/<role>/ and prefixes all '
            'file names, class names, and routes with the role.',
      )
      ..addFlag(
        'pick-role',
        abbr: 'R',
        help: 'Interactively pick a role from existing role directories.',
        negatable: false,
      );
  }

  final Logger _logger;

  @override
  String get description =>
      'Create a new feature module with clean architecture.';

  @override
  String get name => 'feature';

  @override
  String get invocation =>
      'codeable_cli feature <feature_name> [--role <role> | --pick-role]';

  @override
  Future<int> run() async {
    final args = argResults?.rest;
    if (args == null || args.isEmpty) {
      _logger.err('Please provide a feature name.');
      _logger.info(
        'Usage: codeable_cli feature <feature_name> [--role <role> | --pick-role]',
      );
      return ExitCode.usage.code;
    }

    final featureName = args.first;
    var role = argResults?['role'] as String?;
    final pickRole = argResults?['pick-role'] as bool? ?? false;

    // Check we're in a Flutter project
    final pubspecFile =
        File('${Directory.current.path}/pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      _logger.err(
        'No pubspec.yaml found. '
        'Run this command from the root of a Flutter project.',
      );
      return ExitCode.usage.code;
    }

    // Only prompt for role when --pick-role flag is used
    if (pickRole && role == null) {
      final featuresDir =
          Directory('${Directory.current.path}/lib/features');
      if (featuresDir.existsSync()) {
        final roleDirs = featuresDir
            .listSync()
            .whereType<Directory>()
            .map(
              (d) => d.uri.pathSegments
                  .where((s) => s.isNotEmpty)
                  .last,
            )
            .toList()
          ..sort();

        if (roleDirs.isNotEmpty) {
          role = _logger.chooseOne<String>(
            'Which role should this feature belong to?',
            choices: roleDirs,
          );
        } else {
          _logger.warn('No role directories found under lib/features/.');
        }
      } else {
        _logger.warn('No features directory found.');
      }
    }

    // Check if feature already exists
    final featureDirPath = role != null
        ? '${Directory.current.path}/lib/features/$role/$featureName'
        : '${Directory.current.path}/lib/features/$featureName';
    final featureDir = Directory(featureDirPath);
    if (featureDir.existsSync()) {
      final overwrite = _logger.confirm(
        'Feature $featureName already exists. Overwrite?',
        defaultValue: false,
      );
      if (!overwrite) {
        _logger.info('Aborted.');
        return ExitCode.success.code;
      }
    }

    final generator = FeatureGenerator(logger: _logger);
    final success = await generator.generate(
      featureName: featureName,
      projectPath: Directory.current.path,
      role: role,
    );

    return success ? ExitCode.success.code : ExitCode.software.code;
  }
}
