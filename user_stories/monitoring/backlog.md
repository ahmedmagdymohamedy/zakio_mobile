# Monitoring — Change Backlog

> Running log of changes to this feature. Every change is one dated line, newest first.
> Format: `- YYYY-MM-DD — <what changed>` (one or two lines max).

## Changes

- 2026-11-28 — Crashlytics confirmed enabled in the Firebase console for both apps (Android + iOS show "App detected and we're waiting for a crash").
- 2026-11-28 — `CrashlyticsManager.init()` wrapped in try/catch: a setup failure is logged and never blocks app start (ships with the next build; 1.0.0+1 has the unguarded version).
- 2026-11-28 — Initial user-story documentation authored (business + technical) while adding Firebase Crashlytics (Android + iOS, release builds only, all uncaught errors fatal) as the prerequisite for uploading the obfuscation symbols on every release.
