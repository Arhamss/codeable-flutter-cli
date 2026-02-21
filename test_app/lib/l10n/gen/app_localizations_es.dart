// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'TestApp';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get home => 'Inicio';

  @override
  String get loginToContinue => 'Inicia sesión para continuar';

  @override
  String get somethingWentWrong => 'Algo salió mal. Por favor, inténtalo de nuevo más tarde.';
}
