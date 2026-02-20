import 'package:zakio/app/app.dart';
import 'package:flutter/cupertino.dart';

/// static function to navigate with on PageRoute Type.
/// to change it any time you need.

class AppRouter {
  static void logEventOnScreenNavigated(Widget pageWidget) {
    // Log navigat event.
  }

  static PageRoute<T> getPageRoute<T>(Widget pageWidget) {
    logEventOnScreenNavigated(pageWidget);
    return CupertinoPageRoute(
      builder: (context) => pageWidget,
    );
  }

  static Future<T?> push<T>(Widget child) => Navigator.push(
        appContext,
        getPageRoute<T>(child),
      );

  static Future<T?> pushReplacement<T>(Widget child) => Navigator.pushReplacement(
        appContext,
        getPageRoute<T>(child),
      );

  static Future<T?> pushAndRemoveUntil<T>(Widget child, bool Function(Route<dynamic>) predicate) => Navigator.pushAndRemoveUntil(
        appContext,
        getPageRoute<T>(child),
        predicate,
      );
}
