import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:zakio/core/managers/logger_manager.dart';
import 'package:zakio/core/utils/utils.dart';

/// Firebase App Check: proves to Firebase that every request comes from the real Zakio app on a
/// real device — Play Integrity on Android, App Attest on iOS.
///
/// Mobile only: Zakio ships no web or desktop app, so other platforms skip it.
/// Debug builds use the debug provider. Its token is printed in the device log on first run and
/// must be added once under Firebase console → App Check → Apps → Manage debug tokens.
abstract class AppCheckManager {
  /// Runs right after `Firebase.initializeApp` and before any other Firebase call. Until it runs,
  /// Android has no provider and iOS falls back to DeviceCheck (not set up for Zakio), so an early
  /// request is refused once App Check is enforced.
  static Future<void> init() async {
    if (!Utils.isMobileApp) return;
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode ? const AndroidDebugProvider() : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode ? const AppleDebugProvider() : const AppleAppAttestProvider(),
      );
    } catch (error, stackTrace) {
      LoggerManager.error('App Check activation failed', error, stackTrace);
    }
  }
}
