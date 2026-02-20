//
//
// here all fonts userd on the application
//
// why you must to get it from a function not var?
// becouse if you change language and have some fonts to other language change it.
//

import 'package:flutter/material.dart';
import 'package:zakio/core/extensions/build_context_ext.dart';

class AppFonts {
  // en
  static const String _ballPill = "ball_pill";
  static const String _neueMontreal = "neue_montreal";

  // ar
  static const String _zeeArabic = "zee_arabic";
  static const String _muhammadMusaAlbazi = "muhammad_musa_albazi";
  static const String _zuhairAlbaziNaskh = "zuhair_albazi_naskh";

  // geters
  static String  headersFont (BuildContext context) => context.isArabic ? _zeeArabic : _ballPill;
  static String  titlesFont (BuildContext context) => context.isArabic ? _muhammadMusaAlbazi : _neueMontreal;
  static String  bodyFont (BuildContext context) => context.isArabic ? _zuhairAlbaziNaskh : _neueMontreal;
}
