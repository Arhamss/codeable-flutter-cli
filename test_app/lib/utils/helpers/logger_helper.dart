import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      lineLength: 5000,
      colors: false,
      methodCount: 0,
      errorMethodCount: 20,
    ),
  );

  static void info(String message) {
    _logger.i(message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void debug(String message) {
    _logger.d(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void verbose(String message) {
    _logger.t(message);
  }
}
