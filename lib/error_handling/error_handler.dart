import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'logging_service.dart';

class MyErrorsHandler {
  static Future<void> initialize() async {
    // Initialize error logging service
    await LoggingService.initialize();
  }

  static void onErrorDetails(FlutterErrorDetails details) {
    // Display a user-friendly error message
    FlutterError.presentError(details);

    // Log the error to a service
    LoggingService.log(details);
  }

  static void onError(dynamic error, StackTrace stackTrace) {
    // Display a user-friendly error message
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'my_app',
      context: ErrorDescription('while processing a user request'),
      informationCollector: () sync* {
        yield ErrorDescription('This is additional information.');
      },
    ));

    // Log the error to a service
    LoggingService.logError(error, stackTrace);
  }
}
