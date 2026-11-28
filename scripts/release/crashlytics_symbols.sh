# shellcheck shell=bash
#
# Crashlytics symbol uploads for scripts/deploy_stores.sh — sourced, never run on its own.
#
# Each platform's symbols go up right after its build and BEFORE its store
# upload, and a failure stops the run: an obfuscated release whose symbols
# never reached Crashlytics shows only unreadable stack traces, and nobody
# notices until the first real crash. The files stay on disk either way, so a
# failure is always recoverable.

require_symbols() { # platform dir
  compgen -G "$2/*.symbols" >/dev/null || die \
    "No Dart symbol files in $2 — this $1 artifact's symbols were never
  written here (built outside this script, or the folder was deleted after the
  build). Run again without --skip-build; the script forces a fresh compile."
}

# Android: the firebase CLI turns the ELF .symbols files into Breakpad symbols.
upload_android_symbols() { # firebase-app-id dir
  local app="$1" dir="$2"
  require_symbols android "$dir"
  info "uploading $(ls "$dir"/*.symbols | wc -l | tr -d ' ') symbol file(s) from ${dir}…"
  if ! firebase crashlytics:symbols:upload --app="$app" "$dir" 2>&1 | sed 's/^/      /'; then
    die "Crashlytics symbol upload failed for android — nothing was sent to the store for it.
  The symbols are kept in $dir. Fix the cause, then either retry by hand:
      firebase crashlytics:symbols:upload --app=$app $dir
  or re-run with --skip-build --android-only."
  fi
  ok "symbols uploaded to Crashlytics ($app)"
}

# iOS: NOT the firebase CLI. Its Breakpad dump_syms reads Android's ELF files
# but fails on the Mach-O file --split-debug-info writes for iOS ("Breakpad
# symbol generation failed" — learned on sweetgathering 2.1.60). Crashlytics
# symbolicates iOS by dSYM UUID instead, and the archive's App.framework.dSYM
# carries the same Dart DWARF under the shipped binary's UUID. The whole dSYMs
# folder goes up so plugin frames resolve too. The .symbols file stays the key
# for `flutter symbolize`.
IOS_ARCHIVE="build/ios/archive/Runner.xcarchive"

# Zakio pulls Firebase through Swift Package Manager, so the Crashlytics SDK's
# own uploader lives in the package checkout; CocoaPods is the fallback.
ios_upload_symbols_tool() {
  local candidate
  for candidate in \
    build/ios/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols \
    ios/Pods/FirebaseCrashlytics/upload-symbols; do
    [[ -x "$candidate" ]] && { echo "$candidate"; return 0; }
  done
  return 1
}

macho_uuid() { # file-or-dSYM -> arm64 UUID, lowercase, no dashes
  xcrun dwarfdump --uuid "$1" 2>/dev/null | awk '/\(arm64\)/ { print $2; exit }' \
    | tr -d '-' | tr '[:upper:]' '[:lower:]'
}

upload_ios_dsyms() { # firebase-app-id symbols-dir
  local app="$1" dir="$2"
  local dsyms="$IOS_ARCHIVE/dSYMs" tool
  require_symbols ios "$dir"
  [[ -d "$dsyms/App.framework.dSYM" ]] || die \
    "No $dsyms/App.framework.dSYM — the archive is missing or was not built by
  \`flutter build ipa\`. Run again without --skip-build."
  tool=$(ios_upload_symbols_tool) || die \
    "Crashlytics' upload-symbols was not found (Swift package checkout or Pods).
  Run \`flutter build ipa\` once so the Firebase packages are fetched, then
  re-run with --skip-build --ios-only."
  local retry="$tool -gsp ios/Runner/GoogleService-Info.plist -p ios $dsyms"

  # The archive in build/ and the symbols kept for this version must be the
  # same compile, or Crashlytics gets dSYMs for a binary that never shipped.
  local want got
  want=$(macho_uuid "$(ls "$dir"/*.symbols | head -1)")
  got=$(macho_uuid "$dsyms/App.framework.dSYM")
  [[ -n "$want" && "$want" == "$got" ]] || die \
    "App.framework.dSYM in $IOS_ARCHIVE (UUID ${got:-?}) is not the build whose
  symbols are kept in $dir (UUID ${want:-?}). Run again without --skip-build."

  info "uploading $(ls -d "$dsyms"/*.dSYM | wc -l | tr -d ' ') dSYM(s) from $dsyms (App $want)…"
  local log
  log=$(mktemp)
  if ! "$tool" -gsp ios/Runner/GoogleService-Info.plist -p ios "$dsyms" >"$log" 2>&1 \
     || ! grep -q "with UUID $want" "$log"; then
    tail -20 "$log" | sed 's/^/      /'
    rm -f "$log"
    die "Crashlytics dSYM upload failed for ios — nothing was sent to the store for it.
  The dSYMs are in $dsyms. Fix the cause, then either retry by hand:
      $retry
  or re-run with --skip-build --ios-only.
  ${ANDROID_DONE:+The Android release already shipped.}"
  fi
  # The *Interop packages ship no code, so their "invalid dSYM" warnings are noise.
  rm -f "$log"
  ok "dSYMs uploaded to Crashlytics ($app) · App.framework $want"
}
