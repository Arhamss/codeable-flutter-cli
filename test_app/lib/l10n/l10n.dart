export 'package:test_app/l10n/gen/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:test_app/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
