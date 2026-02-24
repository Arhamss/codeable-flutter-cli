import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

/// Changes the app display name across Android, iOS, l10n, and constants.
class ChangeAppNameCommand extends Command<int> {
  ChangeAppNameCommand({required Logger logger}) : _logger = logger {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'The new app display name (e.g., "My App").',
    );
  }

  final Logger _logger;

  @override
  String get description =>
      'Change the app display name across Android, iOS, l10n, and constants.';

  @override
  String get name => 'change-app-name';

  @override
  String get invocation =>
      'codeable_cli change-app-name --name "New Name"';

  @override
  Future<int> run() async {
    if (!File('pubspec.yaml').existsSync()) {
      _logger.err(
        'No pubspec.yaml found. '
        'Run this command from inside a Flutter project.',
      );
      return ExitCode.usage.code;
    }

    var newName = argResults?['name'] as String?;
    if (newName == null || newName.isEmpty) {
      newName = _logger.prompt(
        'What is the new app display name? (e.g., My App)',
      );
    }

    if (newName.trim().isEmpty) {
      _logger.err('App name cannot be empty.');
      return ExitCode.usage.code;
    }

    _logger
      ..info('')
      ..info('Changing app name to ${lightCyan.wrap(newName)}...')
      ..info('');

    var hadErrors = false;

    // Step 1: Update Android build.gradle.kts manifest placeholders
    hadErrors |= !_updateAndroidBuildGradle(newName);

    // Step 2: Update app constants
    _updateAppConstants(newName);

    // Step 3: Update l10n ARB files
    _updateL10nFiles(newName);

    // Step 4: Update iOS FLAVOR_APP_NAME in project.pbxproj
    hadErrors |= !_updateIosDisplayName(newName);

    if (hadErrors) {
      _logger.warn('Some files could not be updated. Check the logs above.');
    } else {
      _logger
        ..info('')
        ..success('App display name changed to "$newName"!')
        ..info('');
    }

    return hadErrors ? ExitCode.software.code : ExitCode.success.code;
  }

  /// Updates `manifestPlaceholders["appName"]` for all flavors in
  /// `android/app/build.gradle.kts`.
  bool _updateAndroidBuildGradle(String newName) {
    final progress = _logger.progress('Updating Android build.gradle.kts');
    final file = File('android/app/build.gradle.kts');
    if (!file.existsSync()) {
      progress.fail('android/app/build.gradle.kts not found');
      return false;
    }

    var content = file.readAsStringSync();

    // Update production flavor: manifestPlaceholders["appName"] = "..."
    content = content.replaceAllMapped(
      RegExp(
        r'(create\("production"\)\s*\{[^}]*manifestPlaceholders\["appName"\]\s*=\s*)"[^"]*"',
      ),
      (m) => '${m.group(1)}"$newName"',
    );

    // Update staging flavor
    content = content.replaceAllMapped(
      RegExp(
        r'(create\("staging"\)\s*\{[^}]*manifestPlaceholders\["appName"\]\s*=\s*)"[^"]*"',
      ),
      (m) => '${m.group(1)}"$newName [STG]"',
    );

    // Update development flavor
    content = content.replaceAllMapped(
      RegExp(
        r'(create\("development"\)\s*\{[^}]*manifestPlaceholders\["appName"\]\s*=\s*)"[^"]*"',
      ),
      (m) => '${m.group(1)}"$newName [DEV]"',
    );

    file.writeAsStringSync(content);
    progress.complete('Android build.gradle.kts updated');
    return true;
  }

  /// Updates `appName` in `lib/constants/app_constants.dart`.
  void _updateAppConstants(String newName) {
    final file = File('lib/constants/app_constants.dart');
    if (!file.existsSync()) return;

    final progress = _logger.progress('Updating app_constants.dart');
    var content = file.readAsStringSync();

    final regex = RegExp(
      r"static\s+const\s+String\s+appName\s*=\s*'[^']*'",
    );
    if (regex.hasMatch(content)) {
      content = content.replaceFirst(
        regex,
        "static const String appName = '$newName'",
      );
      file.writeAsStringSync(content);
      progress.complete('app_constants.dart updated');
    } else {
      progress.fail('appName constant not found in app_constants.dart');
    }
  }

  /// Updates `"appName"` in all ARB localization files under `lib/l10n/`.
  void _updateL10nFiles(String newName) {
    final l10nDir = Directory('lib/l10n');
    if (!l10nDir.existsSync()) return;

    final arbFiles = l10nDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.arb'));

    for (final file in arbFiles) {
      var content = file.readAsStringSync();
      final regex = RegExp(r'"appName"\s*:\s*"[^"]*"');
      if (regex.hasMatch(content)) {
        final progress = _logger.progress(
          'Updating ${file.uri.pathSegments.last}',
        );
        content = content.replaceFirst(regex, '"appName": "$newName"');
        file.writeAsStringSync(content);
        progress.complete('${file.uri.pathSegments.last} updated');
      }
    }
  }

  /// Updates `FLAVOR_APP_NAME` entries in iOS `project.pbxproj`.
  bool _updateIosDisplayName(String newName) {
    final progress = _logger.progress('Updating iOS display name');
    final file = File('ios/Runner.xcodeproj/project.pbxproj');
    if (!file.existsSync()) {
      progress.fail('ios/Runner.xcodeproj/project.pbxproj not found');
      return false;
    }

    var content = file.readAsStringSync();

    // Match FLAVOR_APP_NAME = "..."; entries
    final regex = RegExp(r'FLAVOR_APP_NAME\s*=\s*"[^"]*"');
    final matches = regex.allMatches(content).toList();

    if (matches.isEmpty) {
      progress.fail('No FLAVOR_APP_NAME found in project.pbxproj');
      return false;
    }

    // Each build configuration has FLAVOR_APP_NAME set with optional suffix
    // Production configs have just the name, staging has [STG], dev has [DEV]
    content = content.replaceAllMapped(regex, (match) {
      final original = match.group(0)!;
      if (original.contains('[STG]')) {
        return 'FLAVOR_APP_NAME = "$newName [STG]"';
      } else if (original.contains('[DEV]')) {
        return 'FLAVOR_APP_NAME = "$newName [DEV]"';
      }
      return 'FLAVOR_APP_NAME = "$newName"';
    });

    file.writeAsStringSync(content);
    progress.complete(
      'iOS display name updated (${matches.length} entries)',
    );
    return true;
  }
}
