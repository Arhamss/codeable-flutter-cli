const l10nDartTemplate = '''
export 'package:{{project_name}}/l10n/gen/app_localizations.dart';
export 'package:{{project_name}}/l10n/localization_service.dart';

import 'package:flutter/material.dart';
import 'package:{{project_name}}/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
''';

const localizationServiceTemplate = '''
import 'package:{{project_name}}/l10n/gen/app_localizations.dart';

/// Static localization accessor for use in non-widget code
/// (validators, formatters, models, utilities) where BuildContext
/// is not available.
///
/// In widgets/screens, prefer `context.l10n.keyName` instead.
///
/// Usage:
/// ```dart
/// import 'package:{{project_name}}/l10n/localization_service.dart';
///
/// final text = Localization.appName;
/// ```
class Localization {
  Localization._();

  static late AppLocalizations _instance;

  /// Called automatically by AppView on every build/locale change.
  /// Do not call manually.
  static void update(AppLocalizations localizations) {
    _instance = localizations;
  }

  // ── General ──────────────────────────────────────────────

  static String get appName => _instance.appName;
  static String get login => _instance.login;
  static String get logout => _instance.logout;
  static String get home => _instance.home;
  static String get loginToContinue => _instance.loginToContinue;
  static String get somethingWentWrong => _instance.somethingWentWrong;
}
''';

const l10nYamlTemplate = '''
arb-dir: lib/l10n/arb
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n/gen
nullable-getter: false
header: "// dart format off\\n// coverage:ignore-file"
''';

const appEnArbTemplate = '''
{
  "@@locale": "en",
  "appName": "{{app_name}}",
  "@appName": {
    "description": "The name of the application"
  },
  "login": "Login",
  "@login": {
    "description": "Login button text"
  },
  "logout": "Logout",
  "@logout": {
    "description": "Logout button text"
  },
  "home": "Home",
  "@home": {
    "description": "Home screen title"
  },
  "loginToContinue": "Log in to Continue",
  "@loginToContinue": {
    "description": "Login screen title"
  },
  "somethingWentWrong": "Something went wrong. Please try again later.",
  "@somethingWentWrong": {
    "description": "Generic error message"
  }
}
''';

const appEsArbTemplate = '''
{
  "@@locale": "es",
  "appName": "{{app_name}}",
  "login": "Iniciar sesi\\u00f3n",
  "logout": "Cerrar sesi\\u00f3n",
  "home": "Inicio",
  "loginToContinue": "Inicia sesi\\u00f3n para continuar",
  "somethingWentWrong": "Algo sali\\u00f3 mal. Por favor, int\\u00e9ntalo de nuevo m\\u00e1s tarde."
}
''';
