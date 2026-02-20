import 'package:zakio/app/main.dart';
import 'package:zakio/core/flavors/flavors_config.dart';

Future<void> main() async {
  FlavorsConfig(
    isTest: true,
    enableTestingTools: true,
  );

  runZakioApp();
}
