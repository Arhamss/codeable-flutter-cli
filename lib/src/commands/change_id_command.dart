import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

/// Changes the application/bundle identifier for both Android and iOS.
class ChangeIdCommand extends Command<int> {
  ChangeIdCommand({required Logger logger}) : _logger = logger {
    argParser.addOption(
      'id',
      help: 'The new application ID (reverse domain, e.g., com.example.app).',
    );
  }

  final Logger _logger;

  @override
  String get description =>
      'Change the application/bundle identifier for Android and iOS.';

  @override
  String get name => 'change-id';

  @override
  String get invocation => 'codeable_cli change-id --id <new_id>';

  @override
  Future<int> run() async {
    // Ensure we're inside a Flutter project
    if (!File('pubspec.yaml').existsSync()) {
      _logger.err(
        'No pubspec.yaml found. Run this command from inside a Flutter project.',
      );
      return ExitCode.usage.code;
    }

    // Get new ID
    var newId = argResults?['id'] as String?;
    if (newId == null || newId.isEmpty) {
      newId = _logger.prompt(
        'What is the new application ID? (e.g., com.example.app)',
      );
    }

    if (!_isValidAppId(newId)) {
      _logger.err(
        'Invalid application ID. Use reverse domain format '
        '(e.g., com.example.app).',
      );
      return ExitCode.usage.code;
    }

    _logger.info('');
    _logger.info('Changing app ID to ${lightCyan.wrap(newId)}...');
    _logger.info('');

    var hadErrors = false;

    // Step 1: Update Android build.gradle.kts
    hadErrors |= !_updateAndroidBuildGradle(newId);

    // Step 2: Update Android AndroidManifest.xml (if package attribute exists)
    _updateAndroidManifest(newId);

    // Step 3: Update iOS project.pbxproj
    hadErrors |= !_updateIosBundleId(newId);

    if (hadErrors) {
      _logger.warn('Some files could not be updated. Check the logs above.');
    } else {
      _logger
        ..info('')
        ..success('Application ID changed to "$newId"!')
        ..info('')
        ..info('Note: If you use Firebase, update your Firebase config files')
        ..info('(google-services.json, GoogleService-Info.plist) to match.')
        ..info('');
    }

    return hadErrors ? ExitCode.software.code : ExitCode.success.code;
  }

  /// Updates `namespace` and `applicationId` in `android/app/build.gradle.kts`.
  bool _updateAndroidBuildGradle(String newId) {
    final progress = _logger.progress('Updating Android build.gradle.kts');
    final file = File('android/app/build.gradle.kts');
    if (!file.existsSync()) {
      progress.fail('android/app/build.gradle.kts not found');
      return false;
    }

    var content = file.readAsStringSync();

    // Replace namespace = "..."
    final namespaceRegex = RegExp(r'namespace\s*=\s*"[^"]*"');
    if (namespaceRegex.hasMatch(content)) {
      content = content.replaceFirst(
        namespaceRegex,
        'namespace = "$newId"',
      );
    }

    // Replace applicationId = "..."
    final appIdRegex = RegExp(r'applicationId\s*=\s*"[^"]*"');
    if (appIdRegex.hasMatch(content)) {
      content = content.replaceFirst(
        appIdRegex,
        'applicationId = "$newId"',
      );
    }

    file.writeAsStringSync(content);
    progress.complete('Android build.gradle.kts updated');
    return true;
  }

  /// Updates the `package` attribute in AndroidManifest.xml if present.
  void _updateAndroidManifest(String newId) {
    final file = File('android/app/src/main/AndroidManifest.xml');
    if (!file.existsSync()) return;

    var content = file.readAsStringSync();
    final packageRegex = RegExp(r'package="[^"]*"');
    if (packageRegex.hasMatch(content)) {
      final progress = _logger.progress('Updating AndroidManifest.xml');
      content = content.replaceFirst(
        packageRegex,
        'package="$newId"',
      );
      file.writeAsStringSync(content);
      progress.complete('AndroidManifest.xml updated');
    }
  }

  /// Updates `PRODUCT_BUNDLE_IDENTIFIER` in iOS project.pbxproj.
  bool _updateIosBundleId(String newId) {
    final progress = _logger.progress('Updating iOS bundle identifier');
    final file = File('ios/Runner.xcodeproj/project.pbxproj');
    if (!file.existsSync()) {
      progress.fail('ios/Runner.xcodeproj/project.pbxproj not found');
      return false;
    }

    var content = file.readAsStringSync();

    // Match Runner's PRODUCT_BUNDLE_IDENTIFIER (not RunnerTests)
    // Replace only lines that don't end with .RunnerTests
    final bundleIdRegex = RegExp(
      r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*[^;]+;',
    );

    final matches = bundleIdRegex.allMatches(content).toList();
    if (matches.isEmpty) {
      progress.fail('No PRODUCT_BUNDLE_IDENTIFIER found in project.pbxproj');
      return false;
    }

    // Replace each match: if it contained .RunnerTests, keep that suffix
    content = content.replaceAllMapped(bundleIdRegex, (match) {
      final original = match.group(0)!;
      if (original.contains('RunnerTests')) {
        return 'PRODUCT_BUNDLE_IDENTIFIER = $newId.RunnerTests;';
      }
      return 'PRODUCT_BUNDLE_IDENTIFIER = $newId;';
    });

    file.writeAsStringSync(content);
    progress.complete(
      'iOS bundle identifier updated (${matches.length} entries)',
    );
    return true;
  }

  bool _isValidAppId(String id) {
    return RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch(id);
  }
}
