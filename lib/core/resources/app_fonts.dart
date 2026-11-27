//
//
// here all fonts userd on the application
//
// why you must to get it from a function not var?
// becouse if you change language and have some fonts to other language change it.
//
// Family names must match the `fonts:` section in pubspec.yaml.
//

import 'package:flutter/material.dart';
import 'package:zakio/core/extensions/build_context_ext.dart';

class AppFonts {
  // Cairo covers both Arabic and Latin, so it is used for both languages for now.
  static const String _cairo = "Cairo";

  // en
  static const String _enHeaders = _cairo;
  static const String _enTitles = _cairo;
  static const String _enBody = _cairo;

  // ar
  static const String _arHeaders = _cairo;
  static const String _arTitles = _cairo;
  static const String _arBody = _cairo;

  // geters
  static String headersFont(BuildContext context) => context.isArabic ? _arHeaders : _enHeaders;
  static String titlesFont(BuildContext context) => context.isArabic ? _arTitles : _enTitles;
  static String bodyFont(BuildContext context) => context.isArabic ? _arBody : _enBody;
}
