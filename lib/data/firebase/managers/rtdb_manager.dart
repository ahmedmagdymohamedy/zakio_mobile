import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/// Firebase Realtime Database (project zakio-2e280, region europe-west1).
abstract class RtdbManager {
  static const String databaseUrl = "https://zakio-2e280-default-rtdb.europe-west1.firebasedatabase.app";

  static final FirebaseDatabase database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: databaseUrl,
  );
}
