import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:codeable_cli/src/generators/project_generator.dart';

class CreateCommand extends Command<int> {
  CreateCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'The project name (snake_case).',
      )
      ..addOption(
        'org',
        abbr: 'o',
        help: 'The organization/app identifier (e.g., com.example.app).',
      )
      ..addOption(
        'description',
        abbr: 'd',
        help: 'The project description.',
        defaultsTo: 'A new Flutter project',
      )
      ..addOption(
        'output',
        help: 'Output directory.',
        defaultsTo: '.',
      )
      ..addOption(
        'roles',
        help: 'Comma-separated list of role directories to create '
            'under features/ (e.g., customer,admin).',
      );
  }

  final Logger _logger;

  @override
  String get description =>
      'Create a new Flutter project with Codeable architecture.';

  @override
  String get name => 'create';

  @override
  Future<int> run() async {
    // Get project name
    var projectName = argResults?['name'] as String?;
    if (projectName == null || projectName.isEmpty) {
      projectName = _logger.prompt(
        'What is the project name?',
        defaultValue: 'my_app',
      );
    }

    // Get org name
    var orgName = argResults?['org'] as String?;
    if (orgName == null || orgName.isEmpty) {
      orgName = _logger.prompt(
        'What is the app identifier? (e.g., com.example.app)',
        defaultValue: 'com.example.app',
      );
    }

    // Get description
    final description =
        argResults?['description'] as String? ?? 'A new Flutter project';

    final outputDir = argResults?['output'] as String? ?? '.';

    // Validate inputs
    if (!_isValidProjectName(projectName)) {
      _logger.err(
        'Invalid project name. Use lowercase letters, numbers, and underscores.',
      );
      return ExitCode.usage.code;
    }

    if (!_isValidOrgName(orgName)) {
      _logger.err(
        'Invalid org name. Use a reverse domain format (e.g., com.example.app).',
      );
      return ExitCode.usage.code;
    }

    // Check if directory already exists
    final targetDir = Directory('$outputDir/$projectName');
    if (targetDir.existsSync()) {
      final overwrite = _logger.confirm(
        'Directory $projectName already exists. Overwrite?',
        defaultValue: false,
      );
      if (!overwrite) {
        _logger.info('Aborted.');
        return ExitCode.success.code;
      }
      targetDir.deleteSync(recursive: true);
    }

    _logger.info('');
    _logger.info(
      'Creating ${lightCyan.wrap(projectName)} '
      'with org ${lightCyan.wrap(orgName)}...',
    );
    _logger.info('');

    // Parse roles
    final rolesRaw = argResults?['roles'] as String?;
    final roles = rolesRaw != null
        ? rolesRaw
            .split(',')
            .map((r) => r.trim())
            .where((r) => r.isNotEmpty)
            .toList()
        : <String>[];

    final generator = ProjectGenerator(logger: _logger);
    final success = await generator.generate(
      projectName: projectName,
      orgName: orgName,
      description: description,
      outputPath: outputDir,
      roles: roles,
    );

    return success ? ExitCode.success.code : ExitCode.software.code;
  }

  bool _isValidProjectName(String name) {
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name);
  }

  bool _isValidOrgName(String name) {
    return RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch(name);
  }
}
