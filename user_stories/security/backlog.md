# Security — Change Backlog

> Running log of changes to this feature. Every change is one dated line, newest first.
> Format: `- YYYY-MM-DD — <what changed>` (one or two lines max).

## Changes

- 2026-11-28 — Play App Signing SHA-256 (`C4:A3:F8:…:42:E3`, generated on the first Play upload) registered on the Firebase Android app (read from Play's Asset Links snippet for com.megz.zakio); App Check's Play Integrity lists it. Not yet checked with a Play-installed copy.
- 2026-11-28 — Story renamed from `app_check` to `security` so it holds every security capability of the app; App Check (genuine-app protection) is its first part.
- 2026-11-28 — iOS minimum raised 13.0 → 15.0 (Firebase iOS packages require 15; the iOS build failed without it).
- 2026-11-28 — Initial user-story documentation authored (business + technical) while implementing Firebase App Check for Android + iOS (Play Integrity / App Attest, debug providers in debug builds, 12 h tokens), release signing with the shared upload key, and the store apps on Google Play and the App Store. Not enforced yet.
