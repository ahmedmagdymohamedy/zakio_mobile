# Store release automation

One command builds and ships both stores:

```sh
./scripts/deploy_stores.sh
```

It ships one platform at a time:

1. Build the AAB.
2. Send its symbols to Crashlytics.
3. Upload it to **Google Play internal testing**.
4. Build the IPA.
5. Send its dSYMs to Crashlytics.
6. Upload it to **TestFlight**.

Both builds use `-t lib/live_main.dart`, never the dev flavor. If the iOS half fails, the Android release has already landed — fix it and re-run with `--ios-only`.

```
--android-only     --ios-only     --check
--skip-build       --track beta   --notes "Fixed the startup crash"
```

**Preflight always runs first and gates the whole run.**
- `--check` is the same preflight, stopping on success too: no build, no network calls, nothing uploaded.
- If any check fails, nothing is built and nothing is uploaded, and **every** problem is listed at once.
- There is no bypass flag.
- `--skip-build` is **not** a dry run. It skips compiling but still uploads what is already in `build/`.

1.0.0+1 shipped as separate `--android-only` (≈5 min build + upload) and `--ios-only` (≈7 min) runs; TestFlight processing continues after delivery.

## Files

| File | Role |
|------|------|
| `scripts/deploy_stores.sh` | Entry point: options, preflight, the two phases |
| `scripts/release/common.sh` | Output helpers and the preflight gate |
| `scripts/release/crashlytics_symbols.sh` | Android symbols (firebase CLI) and iOS dSYMs (Crashlytics `upload-symbols`) |
| `scripts/release/play_upload.sh` | Google Play Developer API upload (curl + openssl + jq) |

---

## Bump the version FIRST — in `pubspec.yaml`

The script **never** writes a version. Both stores permanently burn a build number the moment it is uploaded to any track, so raising it is your deliberate decision:

```yaml
version: 1.0.1+2   # the single source of truth for BOTH stores
```

`android/local.properties` also has version keys. It is a generated cache that `flutter build` rewrites from `pubspec.yaml` — never edit it.

---

## Obfuscation + Crashlytics symbols

Both builds run with `--obfuscate --split-debug-info=…`. Class and function names are scrambled, so a crash's stack trace is unreadable without the matching **symbol files**. The script handles them:

- **Where they go:** `build_symbols/<version>+<build>/android` and `…/ios`. That is outside `build/` (so `flutter clean` cannot delete it), and gitignored.
- **When they are sent:** right after each build, **before** that platform's store upload.
  - **Android:** `firebase crashlytics:symbols:upload --app=<Firebase app id>`. The app ID comes from `android/app/google-services.json`.
  - **iOS:** the archive's dSYMs go up through the Crashlytics SDK's own `upload-symbols`. The firebase CLI cannot read iOS symbol files. Zakio gets Firebase through **Swift Package Manager**, so the tool is in `build/ios/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols`; `ios/Pods/FirebaseCrashlytics/` is the fallback.
  - **iOS check:** the script verifies that the archive's `App.framework.dSYM` has the same UUID as the kept symbols, and that Crashlytics confirmed it.
- **If the symbol upload fails,** the run **stops** before the store upload and prints the retry command.
- **Every build first deletes `.dart_tool/flutter_build`** (~30 s). Without that, an unchanged Dart compile is skipped and the symbol folder stays empty.

**Never delete `build_symbols/`.** It is the only way to decode an obfuscated trace by hand:
`flutter symbolize -i <trace> -d build_symbols/<ver>/android/app.android-arm64.symbols`.

---

## One-time setup (already done on this machine)

| Need | Where |
|------|-------|
| Upload key | `android/key.properties` → the keystore shared with sweetgathering (gitignored) |
| Play service account | `android/play-service-account.json` — the same key sweetgathering uses (gitignored) |
| Play access | Play Console (Megz Games) → Users and permissions → `la3bangy-play-deploy@…` → app **Zakio - Kids Brain Games**: *Release to testing tracks* + *View app information* |
| Apple password | `APPLE_APP_SPECIFIC_PASSWORD`, exported in `~/.zshrc` |
| Apple ID | `ahmedmagdymohamedy@gmail.com` (override with `APPLE_ID`) |
| iOS signing | Automatic, team `7TR5648CPX` (Ahmed Magdy); no `ios/ExportOptions.plist` |
| Tools | `flutter`, `firebase` CLI (logged in), `java`, `jq`, `openssl`, `curl`, Xcode (`altool`, `dwarfdump`) |

`--check` validates all of it in seconds.

### If Play answers "The caller does not have permission"

The service account has no access to the app. Grant it in Play Console → **Users and permissions** → the service account → **App permissions** → **Add app**:
- *Release to testing tracks*;
- *View app information*.

Add *Release to production* only if you ever want `--track production`.

### A new machine or a rotated key

- **Play key:** create the JSON in Google Cloud (project `sweet-gathering-99f2b`, *Google Play Android Developer API* enabled), save it as `android/play-service-account.json`, and grant it access as above.
- **Apple password:** <https://account.apple.com> → Sign-In and Security → App-Specific Passwords. Then add `export APPLE_APP_SPECIFIC_PASSWORD='…'` to `~/.zshrc`.

---

## Notes

- **Play version codes are permanent.** Once a code is uploaded to any track, Play refuses it forever.
- **`status: "completed"`** releases to internal testers immediately. Use `"draft"` in `play_upload.sh` to review in the console first.
- **Secrets are never echoed.** The service-account private key lives only in a `chmod 600` temp file, deleted before the upload.
- **`altool` is on its way out.** If a future Xcode drops it, preflight says so; switch to Transporter / `iTMSTransporter`.
- **Apple SDK deadline:** from April 2027, uploads must be built with the iOS 27 SDK (Xcode 27+). Apple warned about this on 1.0.0+1.
- **Play App Signing:** Play re-signs installed copies with its own key.
  - Its SHA-256 (`C4:A3:F8:…:42:E3`) is registered in Firebase beside the upload key's, for App Check / Play Integrity.
  - If Play ever rotates the signing key, add the new fingerprint there too.
