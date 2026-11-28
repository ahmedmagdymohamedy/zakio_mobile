import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:zakio/core/managers/logger_manager.dart';
import 'package:zakio/core/utils/utils.dart';

/// Crash reporting through Firebase Crashlytics — Android and iOS only.
///
/// Every Flutter framework error and every uncaught async error is recorded as fatal. Debug
/// builds collect nothing, so development crashes never reach the dashboard. Release builds are
/// obfuscated: their stack traces are readable only because `scripts/deploy_stores.sh` uploads
/// each release's symbols to Crashlytics before the store upload.
abstract class CrashlyticsManager {
  /// Runs once at startup, after `Firebase.initializeApp`. A failure here is logged and never
  /// stops the app from starting.
  static Future<void> init() async {
    if (!Utils.isMobileApp) return;
    try {
      final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
      FlutterError.onError = crashlytics.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
        crashlytics.recordError(error, stackTrace, fatal: true);
        return true;
      };
    } catch (error, stackTrace) {
      LoggerManager.error('Crashlytics setup failed', error, stackTrace);
    }
  }
}
