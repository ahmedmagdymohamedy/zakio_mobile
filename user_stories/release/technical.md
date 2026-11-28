# Release — Technical
_`scripts/deploy_stores.sh`: obfuscated AAB → Crashlytics → Play internal; obfuscated IPA → Crashlytics → TestFlight. Ported from sweetgathering's script._

## How it works
`./scripts/deploy_stores.sh` runs a preflight that collects every problem, and builds or uploads nothing unless it passes. `--check` runs only that preflight.

It then reads the version from `pubspec.yaml` (never writes it) and drops `.dart_tool/flutter_build`, so the AOT compile — and with it the symbol files — always runs.

The two phases:
- **Android:**
  1. `flutter build appbundle --release -t lib/live_main.dart --obfuscate --split-debug-info=build_symbols/<ver>/android`;
  2. `firebase crashlytics:symbols:upload`;
  3. the Play Developer API (service-account JWT → edit → bundle upload → `internal` track → commit).
- **iOS:**
  1. `flutter build ipa` with the same flags (`…/ios`);
  2. the archive's dSYMs go to Crashlytics through the SDK's `upload-symbols`, after a UUID match against the kept `.symbols`;
  3. `xcrun altool --validate-app`, then `--upload-app`.

The details and the setup are in `scripts/README_release.md`.

## Key components
- `scripts/deploy_stores.sh` — entry point: options, preflight, version, phases.
- `scripts/release/common.sh` — output helpers, the problem collector and `enforce_preflight`.
- `scripts/release/crashlytics_symbols.sh` — `upload_android_symbols`, `upload_ios_dsyms`, and `ios_upload_symbols_tool`. The tool is looked up in the Swift Package checkout first, then in Pods.
- `scripts/release/play_upload.sh` — `play_authenticate` and `play_upload_bundle`.
- `android/app/build.gradle.kts` — release signing from `android/key.properties` (the upload key shared with sweetgathering).

## Data & state
- **Version:** `pubspec.yaml` `version:` is the only source. The first release was `1.0.0+1` (2026-11-28).
- **Symbols:** `build_symbols/<version>+<build>/{android,ios}`, gitignored and kept forever; `.crashlytics/` is the tool cache (gitignored).
- **Secrets, never committed:**
  - `android/key.properties`;
  - `android/play-service-account.json` — service account `la3bangy-play-deploy@sweet-gathering-99f2b`, shared with sweetgathering;
  - `APPLE_APP_SPECIFIC_PASSWORD` in `~/.zshrc`.
- **Google Play:** app ID 4973991112940700831 (Megz Games). The service account has app permissions for Zakio: *Release to testing tracks* plus view app information.
- **Play App Signing:** Play generated its key on the first upload, SHA-256 `C4:A3:F8:B2:…:C4:B6:42:E3`. The upload key's SHA-256 is `6B:5A:FD:B9:…:B4:43:DD:C5`.
- **App Store Connect:** app 6840201048 (SKU `zakio`), team `7TR5648CPX`, automatic signing.
- `ios/Runner/Info.plist`: `ITSAppUsesNonExemptEncryption = false` (owner approved 2026-11-28, same as sweetgathering).

## Important flows
1. Bump `pubspec.yaml` by hand.
2. `./scripts/deploy_stores.sh --check`.
3. `./scripts/deploy_stores.sh` (or `--android-only` / `--ios-only`).
4. If a symbol upload fails, the run stops before the store upload. Retry with `--skip-build --<platform>-only`.

## Integrations & dependencies
- Google Play Developer API (androidpublisher v3).
- Firebase CLI (`crashlytics:symbols:upload`).
- The Crashlytics `upload-symbols` tool from `firebase-ios-sdk`.
- Xcode `altool` and `dwarfdump`.
- `jq`, `openssl`, `curl`, `java`.

## Edge cases & failure handling
- **A version code already used:** Play refuses it, and the script says to raise `+N`.
- **A brand-new Play app:** the API accepted the very first upload once the service account had app access. No manual first upload was needed.
- **"The caller does not have permission":** the service account has no access to the app.
- **Crashlytics Gradle plugin 3.x needs Google Services ≥ 4.4.1.** Zakio pins **2.8.1** with Google Services 4.3.15 and AGP 8.9.1, the combination proven in sweetgathering.
- **iOS minimum is 15.0,** because the Firebase Swift packages require it.

## Security & permissions
- No secret is echoed. The Play private key exists only in a `chmod 600` temp file during the run.
- The service account cannot release to production.

## Platform notes
- **Android:** AAB, R8 on by Flutter's default.
- **iOS:** Firebase through Swift Package Manager (Pods only for non-SPM plugins).
- **Web / desktop:** not released.

## Constraints, risks & tech debt
- `altool` is deprecated by Apple. Switch to Transporter / `iTMSTransporter` if it disappears.
- From April 2027, Apple requires the iOS 27 SDK (Xcode 27+); Apple warned about this on the first upload.
- Flutter warns that Gradle 8.12, AGP 8.9.1 and Kotlin 2.1.0 will soon be unsupported. Upgrading is a separate task.
- The iOS `upload-symbols` lookup depends on Flutter's `build/ios/SourcePackages` layout.
