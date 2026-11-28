import 'package:flutter/foundation.dart';

// any function that will used in more than screen on
// app and can make some thing easy to you, you can add it
// here as a static function.

abstract class Utils {
  /// True on the platforms Zakio ships as an app: Android and iOS.
  /// The web is an information page only, and desktop builds are not shipped.
  static bool get isMobileApp => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
}
