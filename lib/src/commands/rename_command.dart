import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

/// Renames a Flutter project: updates package name in pubspec.yaml,
/// rewrites all `package:old_name/` imports, and renames the project folder.
class RenameCommand extends Command<int> {
  RenameCommand({required Logger logger}) : _logger = logger {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'The new project name (snake_case).',
    );
  }

  final Logger _logger;

  @override
  String get description =>
      'Rename the Flutter project (package name, imports, and folder).';

  @override
  String get name => 'rename';

  @override
  String get invocation => 'codeable_cli rename --name <new_name>';

  @override
  Future<int> run() async {
    // Ensure we're inside a Flutter project
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      _logger.err(
        'No pubspec.yaml found. Run this command from inside a Flutter project.',
      );
      return ExitCode.usage.code;
    }

    // Get new name
    var newName = argResults?['name'] as String?;
    if (newName == null || newName.isEmpty) {
      newName = _logger.prompt('What is the new project name?');
    }

    if (!_isValidProjectName(newName)) {
      _logger.err(
        'Invalid project name. Use lowercase letters, numbers, '
        'and underscores (must start with a letter).',
      );
      return ExitCode.usage.code;
    }

    // Read current name from pubspec.yaml
    final pubspecContent = pubspecFile.readAsStringSync();
    final nameMatch = RegExp(r'^name:\s*(.+)$', multiLine: true)
        .firstMatch(pubspecContent);
    if (nameMatch == null) {
      _logger.err('Could not find "name:" field in pubspec.yaml.');
      return ExitCode.software.code;
    }
    final oldName = nameMatch.group(1)!.trim();

    if (oldName == newName) {
      _logger.info('Project is already named "$newName". Nothing to do.');
      return ExitCode.success.code;
    }

    _logger.info('');
    _logger.info(
      'Renaming ${lightCyan.wrap(oldName)} → ${lightCyan.wrap(newName)}...',
    );
    _logger.info('');

    // Step 1: Update pubspec.yaml
    final pubspecProgress = _logger.progress('Updating pubspec.yaml');
    final updatedPubspec = pubspecContent.replaceFirst(
      RegExp('^name:\\s*.+\$', multiLine: true),
      'name: $newName',
    );
    pubspecFile.writeAsStringSync(updatedPubspec);
    pubspecProgress.complete('pubspec.yaml updated');

    // Step 2: Rename all package imports in Dart files
    final importProgress = _logger.progress('Updating import statements');
    final libDir = Directory('lib');
    final testDir = Directory('test');
    var filesUpdated = 0;

    for (final dir in [libDir, testDir]) {
      if (dir.existsSync()) {
        filesUpdated += _updateImportsInDirectory(dir, oldName, newName);
      }
    }
    importProgress.complete('Updated imports in $filesUpdated files');

    // Step 3: Rename project folder
    final currentDir = Directory.current;
    final currentDirName = currentDir.uri.pathSegments
        .where((s) => s.isNotEmpty)
        .last;

    if (currentDirName == oldName) {
      final parentPath = currentDir.parent.path;
      final newPath = '$parentPath/$newName';
      if (Directory(newPath).existsSync()) {
        _logger.warn(
          'Cannot rename folder: "$newPath" already exists. '
          'Please rename the folder manually.',
        );
      } else {
        final folderProgress = _logger.progress('Renaming project folder');
        await currentDir.rename(newPath);
        folderProgress.complete('Folder renamed to $newName');
      }
    } else {
      _logger.info(
        'Folder name "$currentDirName" differs from old project name. '
        'Skipping folder rename.',
      );
    }

    // Step 4: Run flutter pub get
    final pubGetProgress = _logger.progress('Running flutter pub get');
    final pubGetResult = await Process.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory:
          currentDirName == oldName && !Directory.current.existsSync()
              ? '${currentDir.parent.path}/$newName'
              : null,
    );

    if (pubGetResult.exitCode != 0) {
      pubGetProgress.fail('flutter pub get failed');
      _logger.err(pubGetResult.stderr.toString());
    } else {
      pubGetProgress.complete('Dependencies resolved');
    }

    _logger
      ..info('')
      ..success('Project renamed from "$oldName" to "$newName"!')
      ..info('');

    return ExitCode.success.code;
  }

  /// Recursively updates all `package:oldName/` imports to
  /// `package:newName/` in `.dart` files within [dir].
  /// Returns the number of files modified.
  int _updateImportsInDirectory(
    Directory dir,
    String oldName,
    String newName,
  ) {
    var count = 0;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = entity.readAsStringSync();
        if (content.contains('package:$oldName/')) {
          entity.writeAsStringSync(
            content.replaceAll('package:$oldName/', 'package:$newName/'),
          );
          count++;
        }
      }
    }
    return count;
  }

  bool _isValidProjectName(String name) {
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name);
  }
}
