import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:my_dart_cli/src/generators/feature_generator.dart';

class FeatureCommand extends Command<int> {
  FeatureCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get description => 'Create a new feature module with clean architecture.';

  @override
  String get name => 'feature';

  @override
  String get invocation => 'codeable_cli feature <feature_name>';

  @override
  Future<int> run() async {
    final args = argResults?.rest;
    if (args == null || args.isEmpty) {
      _logger.err('Please provide a feature name.');
      _logger.info('Usage: codeable_cli feature <feature_name>');
      return ExitCode.usage.code;
    }

    final featureName = args.first;

    // Check we're in a Flutter project
    final pubspecFile = File('${Directory.current.path}/pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      _logger.err(
        'No pubspec.yaml found. '
        'Run this command from the root of a Flutter project.',
      );
      return ExitCode.usage.code;
    }

    // Check if feature already exists
    final featureDir = Directory(
      '${Directory.current.path}/lib/features/$featureName',
    );
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
    );

    return success ? ExitCode.success.code : ExitCode.software.code;
  }
}
