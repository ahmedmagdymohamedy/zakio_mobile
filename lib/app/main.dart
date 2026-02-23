import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zakio/app/app.dart';
import 'package:zakio/app/app_initialization.dart';
import 'package:zakio/core/resources/app_assets.dart';
import 'package:zakio/core/resources/app_languages.dart';

//final NotificationManager notificationManager = ;
Future<void> runZakioApp() async {
  // Start point of the project ..
  // here you can create an initialization for any plugin that require init before run app.
  await AppInitialization.init();

  runApp(
    EasyLocalization(
      supportedLocales: [for (var value in LanguageType.values) Locale(value.getValue())],
      path: AppAssets.localizationPath,
      fallbackLocale: Locale(LanguageType.ENGLISH.getValue()),
      child: const MyApp(),
    ),
  );
}
