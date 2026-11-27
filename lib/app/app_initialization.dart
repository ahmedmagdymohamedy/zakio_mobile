import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zakio/core/managers/shared_preferences_manager.dart';
import 'package:zakio/firebase_options.dart';

class AppInitialization {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    await Future.wait([
      SharedPreferencesManager.init(),
      EasyLocalization.ensureInitialized(),
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    ]);
  }
}
