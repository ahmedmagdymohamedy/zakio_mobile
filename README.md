# zee

## App Icon Generate
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml

## for build 
dart run build_runner build --delete-conflicting-outputs

## Create easy_localization auto-generated classes
flutter pub run easy_localization:generate -S ./assets/translations -f keys -o locale_keys.g.dart

# App Environments:

## dev Environment
build:
    flutter build apk -t lib/dev_main.dart
    flutter build ios -t lib/dev_main.dart
run:
    flutter run -t lib/dev_main.dart

## live Environment
build:
    flutter build apk -t lib/live_main.dart
    flutter build aab -t lib/live_main.dart
    flutter build ios -t lib/live_main.dart
run:
    flutter run -t lib/live_main.dart
