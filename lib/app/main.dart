import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zakio/app/app.dart';
import 'package:zakio/core/managers/shared_preferences_manager.dart';
import 'package:zakio/core/resources/app_assets.dart';
import 'package:zakio/core/resources/app_languages.dart';
import 'package:zakio/firebase_options.dart';

//final NotificationManager notificationManager = ;
Future<void> runZakioApp() async {
  // Start point of the project ..
  // here you can create an initialization for any plugin that require init before run app.

  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferencesManager.init();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Future.wait([]);

  runApp(EasyLocalization(supportedLocales: [for (var value in LanguageType.values) Locale(value.getValue())], path: AppAssets.localizationPath, fallbackLocale: Locale(LanguageType.ENGLISH.getValue()), child: const MyApp()));
}
