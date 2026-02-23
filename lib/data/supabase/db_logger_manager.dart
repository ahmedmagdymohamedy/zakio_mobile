import 'package:logger/logger.dart';

class DBLoggerManager {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 90,
      colors: false, // Fixed the weird terminal characters by turning off ANSI colors
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  static void logResponse(String operation, String tableName, dynamic data) {
    _logger.i({
      'Table': tableName,
      'Operation': operation,
      'Data': data,
    });
  }

  static void logError(String operation, String tableName, dynamic error, [StackTrace? stackTrace]) {
    _logger.e(
      {
        'Table': tableName,
        'Operation': operation,
      },
      error: error,
      stackTrace: stackTrace,
    );
  }
}
