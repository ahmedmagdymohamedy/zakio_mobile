import 'package:logger/logger.dart';

/// The app's one logger — use it instead of `print` / `debugPrint`.
///
/// Logs show in debug builds only (the default `DevelopmentFilter`).
/// Never log secrets or personal data: tokens, passwords, emails, or anything about a child.
abstract class LoggerManager {
  static final Logger _logger = Logger();

  static void debug(String message) => _logger.d(message);

  static void info(String message) => _logger.i(message);

  static void warning(String message, [Object? error, StackTrace? stackTrace]) => _logger.w(message, error: error, stackTrace: stackTrace);

  static void error(String message, [Object? error, StackTrace? stackTrace]) => _logger.e(message, error: error, stackTrace: stackTrace);
}
