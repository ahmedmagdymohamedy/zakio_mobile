import 'package:firebase_database/firebase_database.dart';
import 'package:zakio/data/repositories/app_config/app_config.dart';

const String APP_CONFIG_PATH = "app_config";

abstract class RealtimeDatabaseManager {
  static FirebaseDatabase database = FirebaseDatabase.instance;

  static void _listenToData(String path, Function(Map<String, dynamic>) onData) {
    print("object");
    database.ref(path).onValue.listen((DatabaseEvent event) {
      print(event.snapshot.value);
      final data = event.snapshot.value as Map<String, dynamic>?;
      onData(data!);
    });
  }

  static void listenAppConfig(Function(AppConfig) onData) {
    _listenToData(APP_CONFIG_PATH, (data) {
      print(data);
      onData(AppConfig.fromJson(data));
    });
  }
}
