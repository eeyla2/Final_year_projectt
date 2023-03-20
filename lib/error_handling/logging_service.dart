import 'dart:async';
import 'dart:developer' as devtools show log;

class LoggingService {
  static Future<void> initialize() async {
    // Initialize the logging service
  }

  static void log(dynamic message) {
    // Log an informational message
    devtools.log('[INFO] $message');
  }

  static void logError(dynamic error, StackTrace stackTrace) {
    // Log an error message
    devtools.log('[ERROR] $error\n$stackTrace');
  }
}
