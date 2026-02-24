import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zakio/core/managers/shared_preferences_manager.dart';
import 'package:zakio/firebase_options.dart';
import 'package:zakio_core/zakio_core.dart';

class AppInitialization {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    await Future.wait([
      ZakioCore.init(),
      SharedPreferencesManager.init(),
      EasyLocalization.ensureInitialized(),
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      Supabase.initialize(
        url: "https://fqsfcpwekbhtrybzdubb.supabase.co",
        anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxc2ZjcHdla2JodHJ5YnpkdWJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE3NDgwNjMsImV4cCI6MjA4NzMyNDA2M30.CegyAJQ2Z4UY78g_Q8ikwVjXNxFLKFuIAaTFAIb4Sj4",
      ),
    ]);
  }
}
