#!/usr/bin/env bash
#
# Zakio — one-command release to Google Play (internal testing) + TestFlight.
#
#   ./scripts/deploy_stores.sh
#
# Each platform is built and shipped before the next one starts:
#   AAB → Play  →  IPA → TestFlight
#
# Both builds use the LIVE entrypoint (lib/live_main.dart), never the dev flavor.
#
# The version is NEVER modified by this script. Both stores permanently burn a
# build number once it is uploaded, so bumping it is a deliberate decision you
# make by hand, in pubspec.yaml, before running this.
#
# Preflight runs first and gates everything: if any check fails, the run stops
# there and nothing is built or uploaded. `--check` is that same preflight,
# stopping on success too.
#
# Both builds are OBFUSCATED (--obfuscate --split-debug-info). The Dart symbol
# files land in build_symbols/<version>+<build>/{android,ios} — outside build/,
# so `flutter clean` cannot wipe them. Crashlytics gets them right after each
# build, BEFORE that platform's store upload. Keep that folder: without it no
# obfuscated stack trace from that release can ever be read again.
#
# Secrets come from the environment — nothing is stored in this repo:
#   APPLE_APP_SPECIFIC_PASSWORD   exported from ~/.zshrc
#   PLAY_SERVICE_ACCOUNT_JSON     defaults to android/play-service-account.json
# Neither is ever echoed. Setup and details: scripts/README_release.md
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck source=release/common.sh
source "$ROOT/scripts/release/common.sh"
# shellcheck source=release/crashlytics_symbols.sh
source "$ROOT/scripts/release/crashlytics_symbols.sh"
# shellcheck source=release/play_upload.sh
source "$ROOT/scripts/release/play_upload.sh"

TARGET="lib/live_main.dart"
APP_NAME="Zakio - Kids Brain Games"

# ---------------------------------------------------------------- options ---
DO_ANDROID=1
DO_IOS=1
DO_BUILD=1
CHECK_ONLY=0
TRACK="internal"
RELEASE_NOTES="Automated build."

usage() {
  cat <<'EOF'
Usage: ./scripts/deploy_stores.sh [options]

Builds and ships one platform at a time: AAB → Play, then IPA → TestFlight.
Always builds -t lib/live_main.dart. The version is never changed — bump it
yourself in pubspec.yaml beforehand.

Preflight always runs first and gates the whole run: any failed check stops
it before anything is built or uploaded.

  --android-only      Build + upload the AAB only
  --ios-only          Build + upload the IPA only
  --skip-build        Upload the artifacts already in build/ (no rebuild)
  --check             Run ONLY preflight, then stop even if it passes.
  --track <name>      Play track: internal (default) | alpha | beta | production
  --notes "<text>"    Play release notes (default: "Automated build.")
  -h, --help          Show this help

Environment (override by exporting before the run):
  APPLE_APP_SPECIFIC_PASSWORD   required for TestFlight (lives in ~/.zshrc)
  APPLE_ID                      defaults to ahmedmagdymohamedy@gmail.com
  PLAY_SERVICE_ACCOUNT_JSON     defaults to android/play-service-account.json
  ASC_PROVIDER                  only if your Apple ID has multiple teams

Both builds are obfuscated; their Dart symbols are kept in
build_symbols/<version>+<build>/ and uploaded to Crashlytics before the store
upload. Android needs the firebase CLI (logged in) and a working java.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --android-only) DO_IOS=0 ;;
    --ios-only)     DO_ANDROID=0 ;;
    --skip-build)   DO_BUILD=0 ;;
    --check)        CHECK_ONLY=1 ;;
    --track)        TRACK="${2:?--track needs a value}"; shift ;;
    --notes)        RELEASE_NOTES="${2:?--notes needs a value}"; shift ;;
    -h|--help)      usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

START_TS=$(date +%s)

# ---------------------------------------------------------------- secrets ---
: "${APPLE_ID:=ahmedmagdymohamedy@gmail.com}"
: "${APPLE_APP_SPECIFIC_PASSWORD:=}"
: "${PLAY_SERVICE_ACCOUNT_JSON:=$ROOT/android/play-service-account.json}"
: "${ASC_PROVIDER:=}"

AAB="build/app/outputs/bundle/release/app-release.aab"
ANDROID_DONE=""

# --------------------------------------------------------------- preflight --
# Everything both platforms need is checked up front, so a missing iOS
# credential cannot surface only after the Android half has already shipped.
step "Preflight"

need flutter "Install Flutter and put it on PATH." || true
[[ -f "$TARGET" ]] || fail "Entrypoint $TARGET not found — are you in the right repo?"

# `|| true` so a miss reaches the fail() below instead of silently ending the
# run (set -e + pipefail).
PKG=$(grep -Eo 'applicationId[[:space:]]*=.*"[^"]+"' android/app/build.gradle.kts 2>/dev/null \
      | head -1 | sed -E 's/.*"([^"]+)".*/\1/' || true)
[[ -n "$PKG" ]] || fail "Could not read applicationId from android/app/build.gradle.kts"

if (( DO_ANDROID )); then
  # Crashlytics symbol upload: the firebase CLI uploads the obfuscation
  # symbols and shells out to `java` to do it.
  SYMBOL_PROBLEMS_BEFORE=$PROBLEM_COUNT
  if need firebase "npm install -g firebase-tools"; then
    if [[ -z "${FIREBASE_TOKEN:-}" && -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]] \
       && ! firebase login:list 2>/dev/null | grep -q 'Logged in as'; then
      fail "The firebase CLI is not logged in — the Crashlytics symbol upload would fail.
     Run: firebase login"
    fi
  fi
  java -version >/dev/null 2>&1 || fail \
    "No working java on PATH — firebase crashlytics:symbols:upload runs a Java tool.
     Install a JDK (e.g. Zulu 17) or put the Gradle JDK on PATH."
  (( PROBLEM_COUNT > SYMBOL_PROBLEMS_BEFORE )) || ok "Crashlytics symbol upload ready · firebase CLI logged in · java"

  need jq "brew install jq" || true
  need openssl "brew install openssl" || true
  need curl "curl ships with macOS; check your PATH." || true

  if [[ ! -f "$PLAY_SERVICE_ACCOUNT_JSON" ]]; then
    fail "Play service-account JSON not found at:
       $PLAY_SERVICE_ACCOUNT_JSON
     Create it by following scripts/README_release.md, or export
     PLAY_SERVICE_ACCOUNT_JSON=<path>"
  elif command -v jq >/dev/null 2>&1; then
    jq -e '.client_email and .private_key' "$PLAY_SERVICE_ACCOUNT_JSON" >/dev/null 2>&1 \
      || fail "$PLAY_SERVICE_ACCOUNT_JSON is not a valid service-account key
     (no client_email / private_key). Re-download it from Google Cloud."
  fi

  [[ -f android/key.properties ]] || fail \
    "android/key.properties missing — the AAB would be signed with debug keys
     and Play would reject it."

  # The Crashlytics app the Android symbols belong to: the google-services.json
  # client whose package is this build's applicationId.
  ANDROID_FIREBASE_APP=""
  if command -v jq >/dev/null 2>&1 && [[ -n "$PKG" ]]; then
    ANDROID_FIREBASE_APP=$(jq -r --arg p "$PKG" \
      '.client[] | select(.client_info.android_client_info.package_name == $p)
                 | .client_info.mobilesdk_app_id' android/app/google-services.json 2>/dev/null | head -1)
  fi
  [[ -n "$ANDROID_FIREBASE_APP" ]] || fail \
    "No Firebase app for $PKG in android/app/google-services.json — the
     Crashlytics symbol upload needs it. Re-download the file from the console."

  (( PROBLEM_COUNT )) || ok "Play credentials present · package $PKG · track $TRACK"
fi

if (( DO_IOS )); then
  IOS_OK=1
  [[ "$(uname -s)" == "Darwin" ]] || { fail "iOS builds require macOS."; IOS_OK=0; }
  if need xcrun "Install Xcode and run: xcode-select --install"; then
    xcrun --find altool >/dev/null 2>&1 || { IOS_OK=0; fail \
      "xcrun altool is unavailable in this Xcode. Upload manually with Transporter,
     or switch this script to iTMSTransporter."; }
    # Matches the archive's dSYM to this version's kept symbols by UUID.
    xcrun --find dwarfdump >/dev/null 2>&1 || { IOS_OK=0; fail \
      "xcrun dwarfdump is unavailable — reinstall the Xcode command-line tools."; }
  else
    IOS_OK=0
  fi
  [[ -n "$APPLE_APP_SPECIFIC_PASSWORD" ]] || { IOS_OK=0; fail \
    "APPLE_APP_SPECIFIC_PASSWORD is not exported in this shell.
     It lives in ~/.zshrc — open a new terminal, or run:
         export APPLE_APP_SPECIFIC_PASSWORD='xxxx-xxxx-xxxx-xxxx'"; }

  # Signing: AUTOMATIC, with no ios/ExportOptions.plist — `flutter build ipa`
  # exports app-store on its own. If one is ever added it is picked up here,
  # and its team must match the project's or the export fails AFTER the whole
  # archive has built.
  PROJ_TEAM=$(grep -m1 -oE 'DEVELOPMENT_TEAM = [A-Z0-9]+' ios/Runner.xcodeproj/project.pbxproj 2>/dev/null \
              | awk '{print $3}')
  [[ -n "$PROJ_TEAM" ]] || { IOS_OK=0; fail \
    "No DEVELOPMENT_TEAM in ios/Runner.xcodeproj — open Xcode → Runner → Signing
     and pick the team, or the archive cannot be signed."; }

  USE_EXPORT_OPTS=0
  if [[ -f ios/ExportOptions.plist ]]; then
    EXP_TEAM=$(/usr/libexec/PlistBuddy -c 'Print :teamID' ios/ExportOptions.plist 2>/dev/null || true)
    if [[ -n "$EXP_TEAM" && -n "$PROJ_TEAM" && "$EXP_TEAM" != "$PROJ_TEAM" ]]; then
      IOS_OK=0
      fail "Team ID mismatch — the archive would build and then fail to export.
       ios/ExportOptions.plist : $EXP_TEAM
       Runner.xcodeproj        : $PROJ_TEAM
     Set them to the same team."
    fi
    USE_EXPORT_OPTS=1
    info "using ios/ExportOptions.plist"
  fi

  # The Crashlytics app the iOS symbols belong to — the same file the app
  # initialises Firebase from (upload-symbols reads it with -gsp).
  IOS_FIREBASE_APP=$(/usr/libexec/PlistBuddy -c 'Print :GOOGLE_APP_ID' \
                     ios/Runner/GoogleService-Info.plist 2>/dev/null || true)
  [[ -n "$IOS_FIREBASE_APP" ]] || { IOS_OK=0; fail \
    "No GOOGLE_APP_ID in ios/Runner/GoogleService-Info.plist — the Crashlytics
     symbol upload needs it. Re-download the file from the console."; }

  (( IOS_OK )) && ok "Apple credentials present · $APPLE_ID · team $PROJ_TEAM"
fi

# ----------------------------------------------------------------- version --
# Read only. pubspec.yaml is the ONLY source of truth: `flutter build` rewrites
# android/local.properties' version keys from it before Gradle reads them.
VERSION_LINE=$(grep -E '^version:' pubspec.yaml 2>/dev/null | head -1 | sed -E 's/^version:[[:space:]]*//')
if [[ "$VERSION_LINE" != *+* ]]; then
  fail "pubspec.yaml version must look like 1.0.0+1 (found: ${VERSION_LINE:-<none>})"
  VERSION_LINE="0.0.0+0"
fi
VERSION_NAME="${VERSION_LINE%%+*}"
BUILD_NUMBER="${VERSION_LINE##*+}"

step "Version"
info "pubspec.yaml  ${B}${VERSION_NAME}+${BUILD_NUMBER}${N}  (the single source — both stores get this)"

# Per release, outside build/ (flutter clean must never take them) and
# gitignored. Kept after upload: they are the only key to that release's
# obfuscated stack traces.
SYMBOLS_ROOT="build_symbols/${VERSION_NAME}+${BUILD_NUMBER}"
info "symbols       $SYMBOLS_ROOT/{android,ios}"

# ─────────────────────────────────────────────────────────────────────────────
# Nothing below this line runs unless every check above passed.
enforce_preflight

if (( DO_BUILD )); then
  flutter pub get >/dev/null
  # Flutter's incremental build tracks only app.so as the AOT step's output —
  # the .symbols files --split-debug-info writes are untracked side effects.
  # With unchanged Dart sources the AOT step is skipped and the fresh symbol
  # dirs stay EMPTY. Dropping this cache forces a real compile (~30 s); never
  # `flutter clean` here — that costs minutes.
  rm -rf .dart_tool/flutter_build
fi

# =========================================================== ANDROID PHASE ===
# Built and shipped completely before iOS begins.
if (( DO_ANDROID )); then
  step "Android · build"
  ANDROID_SYMBOLS="$SYMBOLS_ROOT/android"
  if (( DO_BUILD )); then
    # Fresh dir: a re-build of the same version must not upload stale files.
    rm -rf "$ANDROID_SYMBOLS"
    flutter build appbundle --release -t "$TARGET" \
      --obfuscate --split-debug-info="$ANDROID_SYMBOLS"
  else
    info "skipped (--skip-build)"
  fi
  [[ -f "$AAB" ]] || die "Expected $AAB but it does not exist."
  ok "$AAB ($(du -h "$AAB" | cut -f1))"

  step "Android · Crashlytics symbols"
  upload_android_symbols "$ANDROID_FIREBASE_APP" "$ANDROID_SYMBOLS"

  step "Android · Google Play → $TRACK"
  play_upload_bundle "$AAB" "$TRACK" "$RELEASE_NOTES"
  ANDROID_DONE=1
fi

# =============================================================== iOS PHASE ===
if (( DO_IOS )); then
  step "iOS · build"
  IOS_SYMBOLS="$SYMBOLS_ROOT/ios"
  if (( DO_BUILD )); then
    rm -rf "$IOS_SYMBOLS"
    OBFUSCATE=(--obfuscate --split-debug-info="$IOS_SYMBOLS")
    if (( ${USE_EXPORT_OPTS:-0} )); then
      flutter build ipa --release -t "$TARGET" "${OBFUSCATE[@]}" \
        --export-options-plist=ios/ExportOptions.plist
    else
      flutter build ipa --release -t "$TARGET" "${OBFUSCATE[@]}"
    fi
  else
    info "skipped (--skip-build)"
  fi
  IPA=$(ls -t build/ios/ipa/*.ipa 2>/dev/null | head -1 || true)
  [[ -n "$IPA" ]] || die "No .ipa found in build/ios/ipa/ — run without --skip-build.
  ${ANDROID_DONE:+The Android release already shipped; re-run with --ios-only once fixed.}"
  ok "$(basename "$IPA") ($(du -h "$IPA" | cut -f1))"

  step "iOS · Crashlytics symbols"
  upload_ios_dsyms "$IOS_FIREBASE_APP" "$IOS_SYMBOLS"

  step "iOS · TestFlight"
  ALTOOL_ARGS=(--upload-app --type ios -f "$IPA"
               --username "$APPLE_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD")
  [[ -n "$ASC_PROVIDER" ]] && ALTOOL_ARGS+=(--asc-provider "$ASC_PROVIDER")

  info "validating…"
  if ! xcrun altool --validate-app --type ios -f "$IPA" \
        --username "$APPLE_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD" 2>&1 \
        | sed 's/^/      /'; then
    die "Validation failed — see the errors above. Nothing was uploaded to TestFlight.
  ${ANDROID_DONE:+The Android release already shipped; re-run with --ios-only once fixed.}"
  fi
  ok "validated"

  info "uploading (this is the slow part)…"
  xcrun altool "${ALTOOL_ARGS[@]}" 2>&1 | sed 's/^/      /'
  ok "delivered — Apple emails you when processing finishes"
fi

# ------------------------------------------------------------------ done ----
ELAPSED=$(( $(date +%s) - START_TS ))
echo
echo "${B}${G}Done${N} in $(( ELAPSED / 60 ))m $(( ELAPSED % 60 ))s — ${B}${VERSION_NAME}+${BUILD_NUMBER}${N}"
if (( DO_ANDROID )); then
  echo "  Play       https://play.google.com/console  →  $APP_NAME → Test and release → Internal testing"
fi
if (( DO_IOS )); then
  echo "  TestFlight https://appstoreconnect.apple.com → Apps → $APP_NAME → TestFlight"
fi
echo "  Symbols    $SYMBOLS_ROOT — keep this folder (Crashlytics already has a copy)"
echo
