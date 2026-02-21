import 'dart:io';
import 'dart:math';

import 'package:mason_logger/mason_logger.dart';

class KeystoreGenerator {
  const KeystoreGenerator({required Logger logger}) : _logger = logger;

  final Logger _logger;

  /// Generates a keystore file and key.properties for the project.
  Future<bool> generate({
    required String projectPath,
    required String projectName,
    required String orgName,
  }) async {
    final progress = _logger.progress('Generating keystore');

    try {
      final password = _generatePassword(16);
      final keystorePath = '$projectPath/android/app/upload-keystore.jks';
      final keyPropertiesPath = '$projectPath/android/key.properties';

      // Generate JKS keystore using keytool
      final result = await Process.run(
        'keytool',
        [
          '-genkey',
          '-v',
          '-keystore',
          keystorePath,
          '-keyalg',
          'RSA',
          '-keysize',
          '2048',
          '-validity',
          '10000',
          '-alias',
          'upload',
          '-dname',
          'CN=$projectName,OU=Dev,O=$orgName,L=Unknown,ST=Unknown,C=US',
          '-storepass',
          password,
          '-keypass',
          password,
        ],
      );

      if (result.exitCode != 0) {
        progress.fail('Failed to generate keystore');
        _logger.err('keytool error: ${result.stderr}');
        return false;
      }

      // Write key.properties
      final keyPropertiesContent = '''
storePassword=$password
keyPassword=$password
keyAlias=upload
storeFile=upload-keystore.jks
''';
      File(keyPropertiesPath).writeAsStringSync(keyPropertiesContent);

      // Add to .gitignore
      final gitignorePath = '$projectPath/.gitignore';
      final gitignoreFile = File(gitignorePath);
      var gitignoreContent = '';
      if (gitignoreFile.existsSync()) {
        gitignoreContent = gitignoreFile.readAsStringSync();
      }

      final entriesToAdd = <String>[];
      if (!gitignoreContent.contains('key.properties')) {
        entriesToAdd.add('**/android/key.properties');
      }
      if (!gitignoreContent.contains('*.jks')) {
        entriesToAdd.add('**/*.jks');
      }
      if (!gitignoreContent.contains('*.keystore')) {
        entriesToAdd.add('**/*.keystore');
      }

      if (entriesToAdd.isNotEmpty) {
        final addition =
            '\n# Keystore files\n${entriesToAdd.join('\n')}\n';
        gitignoreFile.writeAsStringSync(
          gitignoreContent + addition,
        );
      }

      progress.complete('Keystore generated');
      _logger.info(
        '  ${lightCyan.wrap('Password')}: $password '
        '(saved in android/key.properties)',
      );
      return true;
    } catch (e) {
      progress.fail('Keystore generation failed: $e');
      return false;
    }
  }

  String _generatePassword(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }
}
