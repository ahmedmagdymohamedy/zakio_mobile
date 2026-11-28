# Monitoring — Technical
_Every monitoring mechanism of the app. Today: Firebase Crashlytics crash reporting on Android and iOS, with obfuscation symbols uploaded per release._

## How it works
**Crash reporting (Crashlytics).** At startup, `AppInitialization._initFirebase()` runs `Firebase.initializeApp` → `AppCheckManager.init()` → `CrashlyticsManager.init()`. On Android and iOS (`Utils.isMobileApp`), `CrashlyticsManager` does three things:
- turns collection on for non-debug builds only (`setCrashlyticsCollectionEnabled(!kDebugMode)`);
- routes `FlutterError.onError` to `recordFlutterFatalError`;
- routes uncaught async errors (`PlatformDispatcher.instance.onError`) to `recordError(fatal: true)`.

Release builds are obfuscated, so traces are symbolicated from the symbols that `scripts/deploy_stores.sh` uploads before each store upload:
- Android: `.symbols` files through the firebase CLI;
- iOS: dSYMs through `upload-symbols`.

## Key components
- `CrashlyticsManager` (`lib/data/firebase/managers/crashlytics_manager.dart`) — the only place Crashlytics is configured.
- `Utils.isMobileApp` (`lib/core/utils/utils.dart`) — the shared Android/iOS check, also used by `AppCheckManager`.
- The Android Crashlytics Gradle plugin `com.google.firebase.crashlytics` **2.8.1** (`android/settings.gradle.kts`, applied in `android/app/build.gradle.kts`). It uploads the R8 mapping during release builds.
- `scripts/release/crashlytics_symbols.sh` — the per-release symbol upload.

## Data & state
- Crash reports live in Crashlytics, project `zakio-2e280`:
  - Android app `1:1088704205561:android:d7e5…0828`;
  - iOS app `1:1088704205561:ios:7f7c…0828`.
- Symbols are kept locally in `build_symbols/<version>+<build>/` (gitignored, never deleted).
- Nothing is cached in the app.

## Important flows
1. **Startup:** Firebase → App Check → Crashlytics handlers.
2. **Error in a release build:** the handler records it as fatal and Crashlytics sends it on the next launch.
3. **Release:** build with `--obfuscate --split-debug-info` → upload symbols → store upload (`user_stories/release`).

## Integrations & dependencies
- `firebase_crashlytics` 5.4.1 — compatible with `firebase_core` 4.x; 6.x needs core 5.
- Firebase CLI and the iOS `upload-symbols` tool, for symbols.

## Edge cases & failure handling
- **Debug builds** record nothing; errors still print to the console.
- **Every caught error counts as fatal.** sweetgathering later had to downgrade survivable framework noise (image-load failures, platform-channel teardown) to non-fatal, because it inflated the crash rate. Port that policy when real traffic shows the same noise.
- **Missing symbols for a version:** its traces stay unreadable. The release script refuses to ship without uploading them.

## Security & permissions
- Never log personal data (tokens, emails, anything about a child) — `.ai/rules/performance_and_logic.md`.
- Crash reports carry only what the SDK collects by default.

## Platform notes
- **Android and iOS** only. Web, macOS and Windows skip `init()`.
- **iOS:** Firebase comes through Swift Package Manager. The Xcode project has no dSYM upload build phase; the release script uploads the dSYMs.

## Constraints, risks & tech debt
- The Crashlytics Gradle plugin is pinned at 2.8.1, because 3.x needs Google Services ≥ 4.4.1. Bump both together.
- `LoggerManager.error` does not forward to Crashlytics yet (non-fatal reporting).
- There is no survivable-noise classifier yet (see Edge cases).
