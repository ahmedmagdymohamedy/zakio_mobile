import 'package:firebase_database/firebase_database.dart';
import 'package:zakio/data/models/app_config/app_config.dart';

const String _appConfigPath = "app_config";

abstract class RealtimeDatabaseManager {
  static FirebaseDatabase database = FirebaseDatabase.instance;

  static void _listenToData(String path, Function(Map<String, dynamic>) onData) {
    database.ref(path).onValue.listen((DatabaseEvent event) {
      // Realtime Database returns Map<Object?, Object?>, not Map<String, dynamic>.
      final value = event.snapshot.value;
      if (value is Map) onData(Map<String, dynamic>.from(value));
    });
  }

  static void listenAppConfig(Function(AppConfig) onData) {
    _listenToData(_appConfigPath, (data) => onData(AppConfig.fromJson(data)));
  }
}
