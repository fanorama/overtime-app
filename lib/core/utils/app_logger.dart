import 'package:logger/logger.dart';

/// Global logger instance untuk aplikasi
///
/// Usage:
/// ```dart
/// import 'package:overtime_app/core/utils/app_logger.dart';
///
/// appLogger.d('Debug message');
/// appLogger.i('Info message');
/// appLogger.w('Warning message');
/// appLogger.e('Error message');
/// ```
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// Logger untuk production (minimal logging)
final productionLogger = Logger(
  printer: SimplePrinter(colors: false),
  level: Level.warning, // Only log warnings and errors in production
);
