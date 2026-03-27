import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:codeable_cli/src/template_engine.dart';
import 'package:codeable_cli/src/templates/bottom_sheet_templates.dart';

class BottomSheetCommand extends Command<int> {
  BottomSheetCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addOption(
        'feature',
        abbr: 'f',
        help: 'Feature path relative to lib/features/ '
            '(e.g., customer/orders or orders).',
      )
      ..addOption(
        'type',
        abbr: 't',
        help: 'Type of bottom sheet to generate.',
        allowed: ['action', 'confirmation', 'form', 'custom'],
        defaultsTo: 'action',
      );
  }

  final Logger _logger;

  @override
  String get description =>
      'Generate a bottom sheet widget inside an existing feature.';

  @override
  String get name => 'bottom-sheet';

  @override
  String get invocation =>
      'codeable_cli bottom-sheet <sheet_name> '
      '--feature <feature_path> [--type action|confirmation|form|custom]';

  @override
  Future<int> run() async {
    final args = argResults?.rest;
    if (args == null || args.isEmpty) {
      _logger.err('Please provide a sheet name.');
      _logger.info(invocation);
      return ExitCode.usage.code;
    }

    final sheetName = args.first;
    var featurePath = argResults?['feature'] as String?;
    final sheetType = argResults?['type'] as String? ?? 'action';

    // Check we're in a Flutter project
    final pubspecFile = File(
      '${Directory.current.path}/pubspec.yaml',
    );
    if (!pubspecFile.existsSync()) {
      _logger.err(
        'No pubspec.yaml found. '
        'Run this command from the root of a Flutter project.',
      );
      return ExitCode.usage.code;
    }

    // Parse project name
    final pubspecContent = pubspecFile.readAsStringSync();
    final nameMatch = RegExp(r'^name:\s*(.+)$', multiLine: true)
        .firstMatch(pubspecContent);
    if (nameMatch == null) {
      _logger.err('Could not parse project name from pubspec.yaml');
      return ExitCode.software.code;
    }
    final projectName = nameMatch.group(1)!.trim();

    // Prompt for feature if not provided
    if (featurePath == null) {
      final featuresDir = Directory(
        '${Directory.current.path}/lib/features',
      );
      if (!featuresDir.existsSync()) {
        _logger.err('No lib/features/ directory found.');
        return ExitCode.usage.code;
      }

      final features = _listFeatures(featuresDir, '');
      if (features.isEmpty) {
        _logger.err('No features found under lib/features/.');
        return ExitCode.usage.code;
      }

      featurePath = _logger.chooseOne<String>(
        'Which feature should this bottom sheet belong to?',
        choices: features,
      );
    }

    // Validate feature exists
    final featureDir = Directory(
      '${Directory.current.path}/lib/features/$featurePath',
    );
    if (!featureDir.existsSync()) {
      _logger.err(
        'Feature not found at lib/features/$featurePath',
      );
      return ExitCode.usage.code;
    }

    // Ensure widgets directory exists
    final widgetsDir = Directory(
      '${featureDir.path}/presentation/widgets',
    );
    widgetsDir.createSync(recursive: true);

    // Build naming
    final snakeSheet = TemplateEngine.toSnakeCase(sheetName)
        .replaceAll(RegExp('[^a-z0-9_]'), '');

    // Derive feature prefix from the feature directory name
    // e.g., "customer/orders" -> prefix is "customer_orders"
    final featurePrefix = featurePath
        .replaceAll('/', '_')
        .replaceAll(RegExp('[^a-z0-9_]'), '');
    final prefixedSnake = '${featurePrefix}_$snakeSheet';
    final prefixedPascal = TemplateEngine.toPascalCase(prefixedSnake);

    // Make a readable title from the sheet name
    final sheetTitle = snakeSheet
        .split('_')
        .map(
          (w) => w.isEmpty
              ? ''
              : '${w[0].toUpperCase()}${w.substring(1)}',
        )
        .join(' ');

    final vars = {
      'project_name': projectName,
      'SheetName': prefixedPascal,
      'sheet_title': sheetTitle,
    };

    // Pick template
    final template = switch (sheetType) {
      'confirmation' => confirmationSheetTemplate,
      'form' => formSheetTemplate,
      'custom' => customSheetTemplate,
      _ => actionSheetTemplate,
    };

    final fileName = '${prefixedSnake}_sheet.dart';
    final filePath = '${widgetsDir.path}/$fileName';

    if (File(filePath).existsSync()) {
      final overwrite = _logger.confirm(
        'File $fileName already exists. Overwrite?',
        defaultValue: false,
      );
      if (!overwrite) {
        _logger.info('Aborted.');
        return ExitCode.success.code;
      }
    }

    final progress = _logger.progress(
      'Creating $sheetType bottom sheet: $prefixedSnake',
    );

    final content = TemplateEngine.render(template, vars);
    File(filePath).writeAsStringSync(content);

    progress.complete('Bottom sheet created');

    _logger
      ..info('')
      ..success('Created $fileName')
      ..info(
        '  File: lib/features/$featurePath/'
        'presentation/widgets/$fileName',
      )
      ..info('')
      ..info('Usage:')
      ..info(
        '  ${prefixedPascal}Sheet.show(context, ...);',
      );

    return ExitCode.success.code;
  }

  /// Recursively lists feature paths relative to the features dir.
  /// Returns paths like "customer/orders", "admin/dashboard", "auth".
  List<String> _listFeatures(Directory dir, String prefix) {
    final features = <String>[];
    for (final entity in dir.listSync()) {
      if (entity is Directory) {
        final name = entity.uri.pathSegments
            .where((s) => s.isNotEmpty)
            .last;
        final path = prefix.isEmpty ? name : '$prefix/$name';

        // It's a feature if it has presentation/ or data/ subdirs
        final hasPresentation = Directory(
          '${entity.path}/presentation',
        ).existsSync();
        final hasData = Directory(
          '${entity.path}/data',
        ).existsSync();

        if (hasPresentation || hasData) {
          features.add(path);
        } else {
          // Could be a role directory — recurse
          features.addAll(_listFeatures(entity, path));
        }
      }
    }
    features.sort();
    return features;
  }
}
