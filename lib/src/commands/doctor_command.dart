import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

/// Checks project health: cubit registration, route wiring,
/// route constants, import consistency, and localization consistency.
class DoctorCommand extends Command<int> {
  DoctorCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get description =>
      'Check project health (cubit registration, '
      'route wiring, localization consistency).';

  @override
  String get name => 'doctor';

  @override
  Future<int> run() async {
    // Ensure we're inside a Flutter project
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      _logger.err(
        'No pubspec.yaml found. '
        'Run this command from inside a Flutter project.',
      );
      return ExitCode.usage.code;
    }

    // Read project name from pubspec.yaml
    final pubspecContent = pubspecFile.readAsStringSync();
    final nameMatch = RegExp(r'^name:\s*(.+)$', multiLine: true)
        .firstMatch(pubspecContent);
    final projectName =
        nameMatch != null ? nameMatch.group(1)!.trim() : 'unknown';

    _logger
      ..info('')
      ..info(
        'Running doctor checks for ${lightCyan.wrap(projectName)}...',
      )
      ..info('');

    var passed = 0;
    var issues = 0;

    // ── Check 1: Cubit Registration ──
    final cubitResult = _checkCubitRegistration();
    if (cubitResult) {
      passed++;
    } else {
      issues++;
    }

    // ── Check 2: Route Wiring ──
    final routeWiringResult = _checkRouteWiring();
    if (routeWiringResult) {
      passed++;
    } else {
      issues++;
    }

    // ── Check 3: Route Constants ──
    final routeConstantsResult = _checkRouteConstants();
    if (routeConstantsResult) {
      passed++;
    } else {
      issues++;
    }

    // ── Check 4: Import Consistency ──
    final importResult = _checkImportConsistency();
    if (importResult) {
      passed++;
    } else {
      issues++;
    }

    // ── Check 5: Localization Consistency ──
    final l10nResult = _checkLocalizationConsistency();
    if (l10nResult) {
      passed++;
    } else {
      issues++;
    }

    // Summary
    _logger.info('');
    if (issues == 0) {
      _logger.success('$passed checks passed, 0 issues found');
    } else {
      _logger.info('$passed checks passed, $issues issues found');
    }
    _logger.info('');

    return issues == 0 ? ExitCode.success.code : ExitCode.software.code;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Check 1: Cubit Registration
  // ────────────────────────────────────────────────────────────────────────

  bool _checkCubitRegistration() {
    _logger.info('${lightCyan.wrap('Cubit Registration')}');

    final featuresDir = Directory('lib/features');
    if (!featuresDir.existsSync()) {
      _logger.info('  ${green.wrap('✓')} No lib/features/ directory — skipped');
      return true;
    }

    final appPageFile = File('lib/app/view/app_page.dart');
    if (!appPageFile.existsSync()) {
      _logger.info(
        '  ${green.wrap('✓')} No lib/app/view/app_page.dart — skipped',
      );
      return true;
    }

    final appPageContent = appPageFile.readAsStringSync();

    // Find all cubit files
    final cubitFiles = featuresDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('cubit.dart'))
        .toList();

    if (cubitFiles.isEmpty) {
      _logger.info('  ${green.wrap('✓')} No cubits found — nothing to check');
      return true;
    }

    final classNameRegex = RegExp(r'class\s+(\w+Cubit)\s+extends');
    final unregistered = <String>[];

    for (final file in cubitFiles) {
      final content = file.readAsStringSync();
      final matches = classNameRegex.allMatches(content);
      for (final match in matches) {
        final className = match.group(1)!;
        if (!appPageContent.contains(className)) {
          unregistered.add(className);
        }
      }
    }

    if (unregistered.isEmpty) {
      _logger.info(
        '  ${green.wrap('✓')} All cubits registered in MultiBlocProvider',
      );
      return true;
    } else {
      _logger.info(
        '  ${red.wrap('✗')} ${unregistered.length} unregistered cubit(s):',
      );
      for (final name in unregistered) {
        _logger.info('      - $name');
      }
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Check 2: Route Wiring
  // ────────────────────────────────────────────────────────────────────────

  bool _checkRouteWiring() {
    _logger.info('${lightCyan.wrap('Route Wiring')}');

    final featuresDir = Directory('lib/features');
    if (!featuresDir.existsSync()) {
      _logger.info('  ${green.wrap('✓')} No lib/features/ directory — skipped');
      return true;
    }

    final routerFile = File('lib/go_router/router.dart');
    final exportsFile = File('lib/go_router/exports.dart');

    final routerContent =
        routerFile.existsSync() ? routerFile.readAsStringSync() : '';
    final exportsContent =
        exportsFile.existsSync() ? exportsFile.readAsStringSync() : '';

    // Find all screen files
    final screenFiles = featuresDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('_screen.dart'))
        .toList();

    if (screenFiles.isEmpty) {
      _logger.info('  ${green.wrap('✓')} No screens found — nothing to check');
      return true;
    }

    final classNameRegex = RegExp(r'class\s+(\w+Screen)\s+extends');
    final issueMessages = <String>[];

    for (final file in screenFiles) {
      final content = file.readAsStringSync();
      final matches = classNameRegex.allMatches(content);
      for (final match in matches) {
        final className = match.group(1)!;

        final inRouter = routerContent.contains(className);
        final inExports = exportsContent.contains(className) ||
            exportsContent.contains(
              file.path.split('lib/').last,
            );

        if (!inRouter && !inExports) {
          issueMessages.add('$className — missing from router and exports');
        } else if (!inRouter) {
          issueMessages.add('$className — missing from router.dart');
        } else if (!inExports) {
          issueMessages.add('$className — missing from exports.dart');
        }
      }
    }

    if (issueMessages.isEmpty) {
      _logger.info('  ${green.wrap('✓')} All screens wired in router');
      return true;
    } else {
      _logger.info(
        '  ${red.wrap('✗')} ${issueMessages.length} unwired screen(s):',
      );
      for (final msg in issueMessages) {
        _logger.info('      - $msg');
      }
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Check 3: Route Constants
  // ────────────────────────────────────────────────────────────────────────

  bool _checkRouteConstants() {
    _logger.info('${lightCyan.wrap('Route Constants')}');

    final routerFile = File('lib/go_router/router.dart');
    final routesFile = File('lib/go_router/routes.dart');

    if (!routerFile.existsSync()) {
      _logger.info(
        '  ${green.wrap('✓')} No lib/go_router/router.dart — skipped',
      );
      return true;
    }
    if (!routesFile.existsSync()) {
      _logger.info(
        '  ${green.wrap('✓')} No lib/go_router/routes.dart — skipped',
      );
      return true;
    }

    final routerContent = routerFile.readAsStringSync();
    final routesContent = routesFile.readAsStringSync();

    // Extract route paths from router.dart
    // e.g., path: '/home' or path: AppRoutes.home
    final pathRegex = RegExp(r'''path:\s*['"](/[^'"]*?)['"]''');
    final pathMatches = pathRegex.allMatches(routerContent);

    final missingConstants = <String>[];

    for (final match in pathMatches) {
      final routePath = match.group(1)!;
      // Skip the root path
      if (routePath == '/') continue;

      // Check if the path literal appears in routes.dart (AppRoutes constants)
      if (!routesContent.contains("'$routePath'") &&
          !routesContent.contains('"$routePath"')) {
        missingConstants.add(routePath);
      }
    }

    if (missingConstants.isEmpty) {
      _logger.info(
        '  ${green.wrap('✓')} All routes have matching constants',
      );
      return true;
    } else {
      _logger.info(
        '  ${red.wrap('✗')} ${missingConstants.length} '
        'route(s) missing constants:',
      );
      for (final path in missingConstants) {
        _logger.info('      - $path');
      }
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Check 4: Import Consistency
  // ────────────────────────────────────────────────────────────────────────

  bool _checkImportConsistency() {
    _logger.info('${lightCyan.wrap('Import Consistency')}');

    final exportsFile = File('lib/go_router/exports.dart');
    if (!exportsFile.existsSync()) {
      _logger.info(
        '  ${green.wrap('✓')} No lib/go_router/exports.dart — skipped',
      );
      return true;
    }

    final content = exportsFile.readAsStringSync();

    // Match both export and import statements
    final importRegex = RegExp(r'''(?:export|import)\s+['"](.+?)['"]''');
    final matches = importRegex.allMatches(content);

    final brokenImports = <String>[];

    for (final match in matches) {
      final importPath = match.group(1)!;

      // Skip dart: and package: imports
      if (importPath.startsWith('dart:') ||
          importPath.startsWith('package:')) {
        continue;
      }

      // Resolve relative path from the exports file location
      final exportsDir = exportsFile.parent.path;
      final resolvedPath = _resolveRelativePath(exportsDir, importPath);
      if (!File(resolvedPath).existsSync()) {
        brokenImports.add(importPath);
      }
    }

    if (brokenImports.isEmpty) {
      _logger.info(
        '  ${green.wrap('✓')} All imports in exports.dart '
        'point to existing files',
      );
      return true;
    } else {
      _logger.info(
        '  ${red.wrap('✗')} ${brokenImports.length} broken import(s):',
      );
      for (final path in brokenImports) {
        _logger.info('      - $path');
      }
      return false;
    }
  }

  /// Resolves a relative import path from [fromDir] to an absolute file path.
  String _resolveRelativePath(String fromDir, String relativePath) {
    final uri = Uri.parse(relativePath);
    final fromUri = Uri.directory(fromDir);
    return fromUri.resolve(uri.toString()).toFilePath();
  }

  // ────────────────────────────────────────────────────────────────────────
  // Check 5: Localization Consistency
  // ────────────────────────────────────────────────────────────────────────

  bool _checkLocalizationConsistency() {
    _logger.info('${lightCyan.wrap('Localization Consistency')}');

    final arbDir = Directory('lib/l10n/arb');
    if (!arbDir.existsSync()) {
      _logger.info(
        '  ${green.wrap('✓')} No lib/l10n/arb/ directory — skipped',
      );
      return true;
    }

    final arbFiles = arbDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.arb'))
        .toList();

    if (arbFiles.isEmpty) {
      _logger.info('  ${green.wrap('✓')} No ARB files found — skipped');
      return true;
    }

    if (arbFiles.length == 1) {
      _logger.info(
        '  ${green.wrap('✓')} Only one ARB file — nothing to compare',
      );
      return true;
    }

    // Parse all ARB files and collect keys
    // (excluding @@-prefixed metadata keys)
    final fileKeys = <String, Set<String>>{};
    final allKeys = <String>{};

    for (final file in arbFiles) {
      try {
        final content = file.readAsStringSync();
        final data =
            jsonDecode(content) as Map<String, dynamic>;
        final keys = data.keys
            .where((k) => !k.startsWith('@'))
            .toSet();
        final fileName = file.uri.pathSegments.last;
        fileKeys[fileName] = keys;
        allKeys.addAll(keys);
      } on FormatException catch (e) {
        _logger.info(
          '  ${red.wrap('✗')} Failed to parse ${file.path}: $e',
        );
        return false;
      }
    }

    // Compare each file against the union of all keys
    final missingEntries = <String>[];

    for (final entry in fileKeys.entries) {
      final missing = allKeys.difference(entry.value);
      for (final key in missing) {
        missingEntries.add('$key missing from ${entry.key}');
      }
    }

    if (missingEntries.isEmpty) {
      _logger.info(
        '  ${green.wrap('✓')} All ARB files have consistent keys',
      );
      return true;
    } else {
      _logger.info(
        '  ${red.wrap('✗')} ${missingEntries.length} inconsistency(ies):',
      );
      for (final msg in missingEntries) {
        _logger.info('      - $msg');
      }
      return false;
    }
  }
}
